#!/bin/bash

###########################################################################
#  Change values here
#  Use xcode-select --install to install command line tools
SDKVERSION=$(xcrun -sdk iphoneos --show-sdk-version)
#
###########################################################################
#
# Don't change anything here
WORKING_DIR="$(pwd)"

ARCHS="arm64" # i386 x86_64 armv7 armv7s arm64
DEVELOPER_ROOT=$(xcode-select -print-path)
BUILD_WITH_EMBED_BITCODE="off"
SOURCE_DIR="$PWD"
BUILD_TYPE="RelWithDebInfo"
OTHER_CFLAGS="-fPIC"
DEPLOYMENT_TARGET=$(xcrun -sdk iphoneos --show-sdk-platform-version)

# ======================= options =======================
while getopts "a:b:d:hi:r:s:t:-" OPTION; do
  case $OPTION in
    a)
      ARCHS="$OPTARG"
      ;;
    b)
      BUILD_TYPE="$OPTARG"
      ;;
    d)
      DEVELOPER_ROOT="$OPTARG"
      ;;
    h)
      echo "usage: $0 [options] -r SOURCE_DIR [-- [cmake options]]"
      echo "options:"
      echo "-a [archs]                    which arch need to built, multiple values must be split by space(default: $ARCHS, available: i386 x86_64 armv7 armv7s arm64)"
      echo "-b [build type]               build type(default: $BUILD_TYPE, available: Debug, Release, RelWithDebInfo, MinSizeRel)"
      echo "-d [developer root directory] developer root directory, we use xcode-select -print-path to find default value.(default: $DEVELOPER_ROOT)"
      echo "-h                            help message."
      echo "-i [option]                   bitcode option(default: $BUILD_WITH_EMBED_BITCODE, available: off, all, bitcode, marker)"
      echo "-s [sdk version]              sdk version, we use xcrun -sdk iphoneos --show-sdk-version to find default value.(default: $SDKVERSION)"
      echo "-t [deployment target]        deployment target. (default: 8.0)"
      echo "-r [source dir]               root directory of this library"
      exit 0
      ;;
    i)
      BUILD_WITH_EMBED_BITCODE="-fembed-bitcode=$OPTARG"
      ;;
    r)
      SOURCE_DIR="$OPTARG"
      ;;
    s)
      SDKVERSION="$OPTARG"
      ;;
    t)
      DEPLOYMENT_TARGET="$OPTARG"
      ;;
    -)
      break
      break
      ;;
    ?) #当有不认识的选项的时候arg为?
      echo "unkonw argument detected"
      exit 1
      ;;
  esac
done

shift $(($OPTIND - 1))

echo "Ready to build for ios"
echo "WORKING_DIR=${WORKING_DIR}"
echo "ARCHS=${ARCHS}"
echo "DEVELOPER_ROOT=${DEVELOPER_ROOT}"
echo "SDKVERSION=${SDKVERSION}"
echo "DEPLOYMENT_TARGET=${DEPLOYMENT_TARGET}"
echo "cmake options=$@"
echo "SOURCE=$SOURCE_DIR"

##########
if [ ! -e "$SOURCE_DIR/CMakeLists.txt" ]; then
  echo "$SOURCE_DIR/CMakeLists.txt not found"
  exit -2
fi

SOURCE_DIR="$(cd $SOURCE_DIR && pwd)"
mkdir -p "$WORKING_DIR/lib"

for ARCH in ${ARCHS}; do
  echo "================== Compling $ARCH =================="
  EXT_OPTIONS="-DCMAKE_SYSTEM_NAME=iOS"

  if [[ "${ARCH}" == "i386" ]]; then
    PLATFORM="iPhoneSimulator"
    EXT_OPTIONS="$EXT_OPTIONS -DCMAKE_SYSTEM_PROCESSOR=i386"
  elif [[ "${ARCH}" == "x86_64" ]]; then
    PLATFORM="iPhoneSimulator"
    EXT_OPTIONS="$EXT_OPTIONS -DCMAKE_SYSTEM_PROCESSOR=x86_64"
  else
    PLATFORM="iPhoneOS"
    if [[ "${ARCH}" == "armv7" ]] || [[ "${ARCH}" == "armv7s" ]]; then
      EXT_OPTIONS="$EXT_OPTIONS -DCMAKE_SYSTEM_PROCESSOR=arm"
    else
      EXT_OPTIONS="$EXT_OPTIONS -DCMAKE_SYSTEM_PROCESSOR=aarch64"
    fi
  fi

  echo "Building for ${PLATFORM} ${SDKVERSION} ${ARCH}"
  echo "Please stand by..."

  export DEVROOT="${DEVELOPER_ROOT}/Platforms/${PLATFORM}.platform/Developer"
  export SDKROOT="${DEVROOT}/SDKs/${PLATFORM}${SDKVERSION}.sdk"
  mkdir -p "$WORKING_DIR/build_jobs_$ARCH"
  cd "$WORKING_DIR/build_jobs_$ARCH"

  # For openssl
  export CROSS_TOP="${DEVROOT}"
  export CROSS_SDK="${PLATFORM}${SDKVERSION}.sdk"

  if [[ $(echo $DEPLOYMENT_TARGET | cut -d. -f 1) -lt 11 ]]; then
    EXT_OPTIONS="$EXT_OPTIONS -DCMAKE_CXX_STANDARD=14"
  fi

  # for CACHE_SRC in $(find "$SOURCE_DIR/protocol" -name "*.pb.h") ; do
  #     rm -f "$CACHE_SRC";
  # done

  # add -DCMAKE_OSX_DEPLOYMENT_TARGET=7.1 to specify the min SDK version
  # export IPHONEOS_DEPLOYMENT_TARGET=${DEPLOYMENT_TARGET}
  cmake "$SOURCE_DIR" -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
    -DCMAKE_OSX_SYSROOT=$SDKROOT -DCMAKE_SYSROOT=$SDKROOT \
    -DCMAKE_OSX_ARCHITECTURES=$ARCH \
    -DCMAKE_CXX_FLAGS="$OTHER_CFLAGS -fembed-bitcode=$BUILD_WITH_EMBED_BITCODE" \
    -DCMAKE_C_FLAGS="$OTHER_CFLAGS -fembed-bitcode=$BUILD_WITH_EMBED_BITCODE" \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=${DEPLOYMENT_TARGET} \
    -DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM=NEVER \
    -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY \
    -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY \
    -DCMAKE_FIND_ROOT_PATH_MODE_PACKAGE=ONLY \
    -DCMAKE_FIND_ROOT_PATH=${SDKROOT} \
    "-DATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HOST_BUILD_DIR=$WORKING_DIR/build_jobs_host" \
    $EXT_OPTIONS "$@"
  if [[ $LAST_EXIT_CODE -ne 0 ]]; then
    echo "run cmake failed"
    exit $LAST_EXIT_CODE
  fi
done

# Run lipo -create SRCS -output DST to archive all .a into one
