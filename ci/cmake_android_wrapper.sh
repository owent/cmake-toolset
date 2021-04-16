#!/bin/bash

ARCHS="arm64-v8a"; # x86 x86_64 armeabi armeabi-v7a arm64-v8a
ANDROID_NDK_ROOT=$ANDROID_NDK_ROOT;
SOURCE_DIR="$PWD";
CONF_ANDROID_NATIVE_API_LEVEL=21 ;
ANDROID_TOOLCHAIN=clang ;
ANDROID_STL=c++_shared ; #
BUILD_TYPE="RelWithDebInfo" ;
# OTHER_CFLAGS="-fPIC" ; # Android使用-DANDROID_PIE=YES
OTHER_LD_FLAGS="-llog -lc";  # protobuf依赖liblog.so

# ======================= options ======================= 
while getopts "a:b:c:n:hl:r:t:-" OPTION; do
    case $OPTION in
        a)
            ARCHS="$OPTARG";
        ;;
        b)
            BUILD_TYPE="$OPTARG";
        ;;
        c)
            ANDROID_STL="$OPTARG";
        ;;
        n)
            ANDROID_NDK_ROOT="$OPTARG";
        ;;
        h)
            echo "usage: $0 [options] -n ANDROID_NDK_ROOT -r SOURCE_DIR [-- [cmake options]]";
            echo "options:";
            echo "-a [archs]                    which arch need to built, multiple values must be split by space(default: $ARCHS)";
            echo "-b [build type]               build type(default: $BUILD_TYPE, available: Debug, Release, RelWithDebInfo, MinSizeRel)";
            echo "-c [android stl]              stl used by ndk(default: $ANDROID_STL, available: system, stlport_static, stlport_shared, gnustl_static, gnustl_shared, c++_static, c++_shared, none)";
            echo "-n [ndk root directory]       ndk root directory.(default: $ANDROID_NDK_ROOT)";
            echo "-l [api level]                API level, see $ANDROID_NDK_ROOT/platforms for detail.(default: $CONF_ANDROID_NATIVE_API_LEVEL)";
            echo "-r [source dir]               root directory of this library";
            echo "-t [toolchain]                ANDROID_TOOLCHAIN.(gcc version/clang, default: $ANDROID_TOOLCHAIN, @see CMAKE_ANDROID_NDK_TOOLCHAIN_VERSION in cmake)";
            echo "-h                            help message.";
            exit 0;
        ;;
        r)
            SOURCE_DIR="$OPTARG";
        ;;
        t)
            ANDROID_TOOLCHAIN="$OPTARG";
        ;;
        l)
            CONF_ANDROID_NATIVE_API_LEVEL=$OPTARG;
        ;;
        -) 
            break;
            break;
        ;;
        ?)  #当有不认识的选项的时候arg为?
            echo "unkonw argument detected";
            exit 1;
        ;;
    esac
done

shift $(($OPTIND-1));

# cmake
printf "Checking cmake ...              ";
if [[ -z "$CMAKE_HOME" ]]; then
    CMAKE_BIN="$(which cmake 2>&1)";
    if [[ $? -eq 0 ]]; then
        CMAKE_HOME="$(dirname "$(dirname "$CMAKE_BIN")")" ;
    else
        if [[ "x${NO_INTERACTIVE}" == "x" ]]; then
            echo "Executable cmake not found ,please input the CMAKE_HOME(which contains bin/cmake) and then press ENTER.";
            read -r -p "CMAKE_HOME: " CMAKE_HOME;
            CMAKE_HOME="${CMAKE_HOME//\\/\/}";
            export PATH="$CMAKE_HOME/bin;$PATH";
        else
            echo "can not find cmake , dependency error." ;
            exit 1 ;
        fi
    fi
fi

# android ndk
if [[ -z "$ANDROID_NDK_ROOT" ]]; then
    if [[ "x${NO_INTERACTIVE}" == "x" ]]; then
        echo "ANDROID_NDK_ROOT is not set ,please input the ANDROID_NDK_ROOT(which contains build/cmake/android.toolchain.cmake) and then press ENTER.";
        read -r -p "ANDROID_NDK_ROOT: " ANDROID_NDK_ROOT;
        ANDROID_NDK_ROOT="${ANDROID_NDK_ROOT//\\/\/}";
    else
        echo "ANDROID_NDK_ROOT is not set , dependency error." ;
        exit 1 ;
    fi
fi

MAKE_EXEC_PATH=$(find "$ANDROID_NDK_ROOT/prebuilt" -name "*make*" | grep "bin/") ;

if [[ "x${MAKE_EXEC_PATH}" != "x" ]]; then
    export PATH="$(dirname "$MAKE_EXEC_PATH"):$PATH";
fi

##########
if [[ ! -e "$SOURCE_DIR/CMakeLists.txt" ]]; then
    echo "$SOURCE_DIR/CMakeLists.txt not found" ;
    exit 2 ;
fi
SOURCE_DIR="$(cd "$SOURCE_DIR" && pwd)";

mkdir -p "$WORKING_DIR/lib";

CMAKE_ANDROID_NDK_TOOLCHAIN_VERSION=$ANDROID_TOOLCHAIN;
if [[ "${ANDROID_TOOLCHAIN:0:5}" != "clang" ]]; then
    ANDROID_TOOLCHAIN="gcc";
fi

for ARCH in ${ARCHS}; do
    echo "================== Compling $ARCH ==================";
    echo "Building libmt_core for android-$CONF_ANDROID_NATIVE_API_LEVEL ${ARCH}"
    
    # sed -i.bak '4d' Makefile;
    echo "Please stand by..."
    mkdir -p "$WORKING_DIR/build_jobs_$ARCH";
    cd "$WORKING_DIR/build_jobs_$ARCH";
    
    mkdir -p "$WORKING_DIR/lib/$ARCH";

    EXT_OPTIONS="";
    # 64 bits must at least using android-21
    # @see $ANDROID_NDK_ROOT/build/cmake/android.toolchain.cmake
    echo $ARCH | grep -E '64(-v8a)?$' ;
    if [[ $? -eq 0 ]] && [[ $CONF_ANDROID_NATIVE_API_LEVEL -lt 21 ]]; then
        ANDROID_NATIVE_API_LEVEL=21 ;
    else
        ANDROID_NATIVE_API_LEVEL=$CONF_ANDROID_NATIVE_API_LEVEL ;
    fi

    # for CACHE_SRC in $(find "$SOURCE_DIR/protocol" -name "*.pb.h") ; do
    #     rm -f "$CACHE_SRC";
    # done
    
    # add -DCMAKE_OSX_DEPLOYMENT_TARGET=7.1 to specify the min SDK version
    # -DANDROID_NDK="$ANDROID_NDK_ROOT" -DCMAKE_ANDROID_NDK="$ANDROID_NDK_ROOT"   \
    "$CMAKE_BIN" "$SOURCE_DIR" -DCMAKE_BUILD_TYPE=$BUILD_TYPE "-DCMAKE_MAKE_PROGRAM=$MAKE_EXEC_PATH"  \
        -DCMAKE_LIBRARY_OUTPUT_DIRECTORY="$WORKING_DIR/lib/$ARCH" -DCMAKE_ARCHIVE_OUTPUT_DIRECTORY="$WORKING_DIR/lib/$ARCH" \
        -DCMAKE_TOOLCHAIN_FILE="$ANDROID_NDK_ROOT/build/cmake/android.toolchain.cmake" \
        -DANDROID_NATIVE_API_LEVEL=$ANDROID_NATIVE_API_LEVEL -DCMAKE_ANDROID_API=$ANDROID_NATIVE_API_LEVEL \
        -DANDROID_TOOLCHAIN=$ANDROID_TOOLCHAIN -DCMAKE_ANDROID_NDK_TOOLCHAIN_VERSION=$CMAKE_ANDROID_NDK_TOOLCHAIN_VERSION \
        -DANDROID_ABI=$ARCH -DCMAKE_ANDROID_ARCH_ABI=$ARCH \
        -DANDROID_STL=$ANDROID_STL -DCMAKE_ANDROID_STL_TYPE=$ANDROID_STL \
        -DANDROID_PIE=YES \
        -DCMAKE_C_STANDARD_LIBRARIES="$OTHER_LD_FLAGS" -DCMAKE_CXX_STANDARD_LIBRARIES="$OTHER_LD_FLAGS" $EXT_OPTIONS "$@";
    
    LAST_EXIT_CODE=$? ;
    if [[ $LAST_EXIT_CODE -ne 0 ]]; then
        echo "run cmake failed"
        exit $LAST_EXIT_CODE;
    fi
done
