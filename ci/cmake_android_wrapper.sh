#!/bin/bash

ARCHS="arm64-v8a" # x86 x86_64 armeabi armeabi-v7a arm64-v8a
ANDROID_NDK_ROOT=$ANDROID_NDK_ROOT
SOURCE_DIR="$PWD"

# https://source.android.com/docs/setup/reference/build-numbers?hl=zh-cn
CONF_ANDROID_NATIVE_API_LEVEL=24 # latest
ANDROID_TOOLCHAIN=clang
ANDROID_STL=c++_shared #
BUILD_TYPE="RelWithDebInfo"
# OTHER_CFLAGS="-fPIC" ; # Android使用-DANDROID_PIE=YES
OTHER_LD_FLAGS="-llog -lc" # protobuf依赖liblog.so

# ======================= options =======================
while getopts "a:b:c:n:hl:r:t:-" OPTION; do
  case $OPTION in
    a)
      ARCHS="$OPTARG"
      ;;
    b)
      BUILD_TYPE="$OPTARG"
      ;;
    c)
      ANDROID_STL="$OPTARG"
      ;;
    n)
      ANDROID_NDK_ROOT="$OPTARG"
      ;;
    h)
      echo "usage: $0 [options] -n ANDROID_NDK_ROOT -r SOURCE_DIR [-- [cmake options]]"
      echo "options:"
      echo "-a [archs]                    which arch need to built, multiple values must be split by space(default: $ARCHS)"
      echo "-b [build type]               build type(default: $BUILD_TYPE, available: Debug, Release, RelWithDebInfo, MinSizeRel)"
      echo "-c [android stl]              stl used by ndk(default: $ANDROID_STL, available: system, stlport_static, stlport_shared, gnustl_static, gnustl_shared, c++_static, c++_shared, none)"
      echo "-n [ndk root directory]       ndk root directory.(default: $ANDROID_NDK_ROOT)"
      echo "-l [api level]                API level, see $ANDROID_NDK_ROOT/platforms for detail.(default: $CONF_ANDROID_NATIVE_API_LEVEL)"
      echo "-r [source dir]               root directory of this library"
      echo "-t [toolchain]                ANDROID_TOOLCHAIN.(gcc version/clang, default: $ANDROID_TOOLCHAIN, @see CMAKE_ANDROID_NDK_TOOLCHAIN_VERSION in cmake)"
      echo "-h                            help message."
      exit 0
      ;;
    r)
      SOURCE_DIR="$OPTARG"
      ;;
    t)
      ANDROID_TOOLCHAIN="$OPTARG"
      ;;
    l)
      CONF_ANDROID_NATIVE_API_LEVEL=$OPTARG
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

# Extract the user specified generator(-G <name> or -G<name>)
USER_GENERATOR=""
NEXT_IS_GENERATOR=0
for CMAKE_OPTION in "$@"; do
  if [[ $NEXT_IS_GENERATOR -eq 1 ]]; then
    USER_GENERATOR="$CMAKE_OPTION"
    break
  fi
  if [[ "x$CMAKE_OPTION" == "x-G" ]]; then
    NEXT_IS_GENERATOR=1
  elif [[ "$CMAKE_OPTION" == -G* ]]; then
    USER_GENERATOR="${CMAKE_OPTION#-G}"
    break
  fi
done
unset NEXT_IS_GENERATOR CMAKE_OPTION

IS_WINDOWS_HOSTED_BASH=0
case "$(uname -s)" in
  MINGW* | MSYS* | CYGWIN*)
    IS_WINDOWS_HOSTED_BASH=1
    ;;
esac

# cmake
printf "Checking cmake ...              "
if [[ -z "$CMAKE_HOME" ]]; then
  CMAKE_BIN="$(which cmake 2>&1)"
  if [[ $? -eq 0 ]]; then
    CMAKE_HOME="$(dirname "$(dirname "$CMAKE_BIN")")"
  else
    if [[ "x${NO_INTERACTIVE}" == "x" ]]; then
      echo "Executable cmake not found ,please input the CMAKE_HOME(which contains bin/cmake) and then press ENTER."
      read -r -p "CMAKE_HOME: " CMAKE_HOME
      CMAKE_HOME="${CMAKE_HOME//\\/\/}"
      export PATH="$CMAKE_HOME/bin;$PATH"
    else
      echo "can not find cmake , dependency error."
      exit 1
    fi
  fi
fi

# android ndk
if [[ -z "$ANDROID_NDK_ROOT" ]]; then
  if [[ "x${NO_INTERACTIVE}" == "x" ]]; then
    echo "ANDROID_NDK_ROOT is not set ,please input the ANDROID_NDK_ROOT(which contains build/cmake/android.toolchain.cmake) and then press ENTER."
    read -r -p "ANDROID_NDK_ROOT: " ANDROID_NDK_ROOT
    ANDROID_NDK_ROOT="${ANDROID_NDK_ROOT//\\/\/}"
  else
    echo "ANDROID_NDK_ROOT is not set , dependency error."
    exit 1
  fi
fi

MAKE_EXEC_PATH=""
if [[ -d "$ANDROID_NDK_ROOT/prebuilt" ]]; then
  MAKE_EXEC_PATH=$(find "$ANDROID_NDK_ROOT/prebuilt" -name "*make*" | grep "bin/")
fi

if [[ "x${MAKE_EXEC_PATH}" != "x" ]]; then
  export PATH="$(dirname "$MAKE_EXEC_PATH"):$PATH"
fi

# Select the generator and the make program. On Windows hosted bash(Git Bash/MSYS2/Cygwin), CMake defaults to
# the Visual Studio generator which can not drive the NDK clang toolchain. Prefer the make bundled with the
# NDK(all Windows NDKs ship prebuilt/windows-x86_64/bin/make.exe), ninja is used only when the NDK does not
# provide make.
CMAKE_GENERATOR_ARGS=()
CMAKE_MAKE_PROGRAM_ARGS=("-DCMAKE_MAKE_PROGRAM=$MAKE_EXEC_PATH")
GENERATOR_IS_NINJA=0
if [[ "x$USER_GENERATOR" != "x" ]] && [[ "$USER_GENERATOR" == *Ninja* ]]; then
  GENERATOR_IS_NINJA=1
fi
if [[ $IS_WINDOWS_HOSTED_BASH -eq 1 ]] && [[ "x$USER_GENERATOR" == "x" ]]; then
  if [[ "x$MAKE_EXEC_PATH" != "x" ]]; then
    CMAKE_GENERATOR_ARGS=(-G "Unix Makefiles")
  elif [[ "x$(command -v ninja)" != "x" ]]; then
    CMAKE_GENERATOR_ARGS=(-G "Ninja")
    GENERATOR_IS_NINJA=1
  else
    echo "Can not find a build program for the NDK clang toolchain: neither the NDK bundled make"
    echo "($ANDROID_NDK_ROOT/prebuilt/*/bin/make.exe) nor ninja is available."
    exit 1
  fi
fi
if [[ $GENERATOR_IS_NINJA -eq 1 ]]; then
  # The ninja generator can not use the NDK bundled GNU make as CMAKE_MAKE_PROGRAM, let cmake find ninja itself.
  CMAKE_MAKE_PROGRAM_ARGS=()
fi

##########
if [[ ! -e "$SOURCE_DIR/CMakeLists.txt" ]]; then
  echo "$SOURCE_DIR/CMakeLists.txt not found"
  exit 2
fi
SOURCE_DIR="$(cd "$SOURCE_DIR" && pwd)"
WORKING_DIR="$PWD"

mkdir -p "$WORKING_DIR/lib"

CMAKE_ANDROID_NDK_TOOLCHAIN_VERSION=$ANDROID_TOOLCHAIN
if [[ "${ANDROID_TOOLCHAIN:0:5}" != "clang" ]]; then
  ANDROID_TOOLCHAIN="gcc"
fi

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

for ARCH in ${ARCHS}; do
  echo "================== Compling $ARCH =================="
  echo "Building libmt_core for android-$CONF_ANDROID_NATIVE_API_LEVEL ${ARCH}"

  # sed -i.bak '4d' Makefile;
  echo "Please stand by..."
  mkdir -p "$WORKING_DIR/build_jobs_$ARCH"
  cd "$WORKING_DIR/build_jobs_$ARCH"
  echo "PWD=$PWD"
  echo "HOST_BUILD_DIR=$WORKING_DIR/build_jobs_host"

  mkdir -p "$WORKING_DIR/lib/$ARCH"

  EXT_OPTIONS=""
  if [[ "${ANDROID_TOOLCHAIN:0:5}" == "clang" ]]; then
    EXT_OPTIONS="$EXT_OPTIONS -DANDROID_LD=lld"
  fi
  if [[ -e "$ANDROID_NDK_ROOT/build/core/version.mk" ]]; then
    ANDROID_NDK_MAJOR_VERSION=$(cat "$ANDROID_NDK_ROOT/build/core/version.mk" | awk '$0 ~ /NDK_MAJOR/ { print $NF }')
    if [[ ! -z "$ANDROID_NDK_MAJOR_VERSION" ]] && [[ $ANDROID_NDK_MAJOR_VERSION -ge 25 ]]; then
      EXT_OPTIONS="$EXT_OPTIONS -DANDROID_USE_LEGACY_TOOLCHAIN_FILE=OFF"
    fi
  fi

  # 64 bits must at least using android-21, and libuv needs at least android-24(Android 7.0)
  # @see $ANDROID_NDK_ROOT/build/cmake/android.toolchain.cmake
  echo $ARCH | grep -E '64(-v8a)?$'
  if [[ $? -eq 0 ]] && [[ $CONF_ANDROID_NATIVE_API_LEVEL -lt 24 ]]; then
    ANDROID_NATIVE_API_LEVEL=24
  else
    ANDROID_NATIVE_API_LEVEL=$CONF_ANDROID_NATIVE_API_LEVEL
  fi

  # for CACHE_SRC in $(find "$SOURCE_DIR/protocol" -name "*.pb.h") ; do
  #     rm -f "$CACHE_SRC";
  # done

  # add -DCMAKE_OSX_DEPLOYMENT_TARGET=7.1 to specify the min SDK version
  # -DANDROID_NDK="$ANDROID_NDK_ROOT" -DCMAKE_ANDROID_NDK="$ANDROID_NDK_ROOT"   \
  # Using -DANDROID_SANITIZE="" to patch "hwaddress" "IN_LIST" "ANDROID_SANITIZE" in NDK
  "$CMAKE_BIN" "$SOURCE_DIR" -DCMAKE_BUILD_TYPE=$BUILD_TYPE "${CMAKE_MAKE_PROGRAM_ARGS[@]}" \
    -DCMAKE_LIBRARY_OUTPUT_DIRECTORY="$WORKING_DIR/lib/$ARCH" -DCMAKE_ARCHIVE_OUTPUT_DIRECTORY="$WORKING_DIR/lib/$ARCH" \
    -DCMAKE_TOOLCHAIN_FILE="$ANDROID_NDK_ROOT/build/cmake/android.toolchain.cmake" \
    -DANDROID_PLATFORM=android-$ANDROID_NATIVE_API_LEVEL -DCMAKE_ANDROID_API=$ANDROID_NATIVE_API_LEVEL \
    -DANDROID_TOOLCHAIN=$ANDROID_TOOLCHAIN -DCMAKE_ANDROID_NDK_TOOLCHAIN_VERSION=$CMAKE_ANDROID_NDK_TOOLCHAIN_VERSION \
    -DANDROID_ABI=$ARCH -DCMAKE_ANDROID_ARCH_ABI=$ARCH \
    -DANDROID_STL=$ANDROID_STL -DCMAKE_ANDROID_STL_TYPE=$ANDROID_STL \
    -DANDROID_PIE=YES \
    -DCMAKE_POLICY_DEFAULT_CMP0057=NEW \
    -DANDROID_SANITIZE="" \
    "-DCMAKE_C_STANDARD_LIBRARIES=$OTHER_LD_FLAGS" "-DCMAKE_CXX_STANDARD_LIBRARIES=$OTHER_LD_FLAGS" \
    "-DATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HOST_BUILD_DIR=$WORKING_DIR/build_jobs_host" \
    "${CMAKE_GENERATOR_ARGS[@]}" $EXT_OPTIONS "$@"

  LAST_EXIT_CODE=$?
  if [[ $LAST_EXIT_CODE -ne 0 ]]; then
    echo "run cmake failed"
    exit $LAST_EXIT_CODE
  fi
done
