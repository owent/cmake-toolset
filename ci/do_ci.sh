#!/bin/bash

cd "$(cd "$(dirname $0)" && pwd)/.."

set -ex

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8

if [[ "x$CI_BUILD_CONFIGURE_TYPE" == "x" ]]; then
  export CI_BUILD_CONFIGURE_TYPE="Release"
fi

if [[ ! -z "$CI" ]] || [[ ! -z "$CI_NAME" ]]; then
  export ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CI_MODE="true"
  export ATFRAMEWORK_CMAKE_TOOLSET_VERBOSE="TRUE"
fi

ATFRAMEWORK_CMAKE_TOOLSET_CI_OPTIONS=("-DATFRAMEWORK_CMAKE_TOOLSET_VERBOSE=TRUE")
if [[ ! -z "$CMAKE_FIND_ROOT_PATH_MODE_PROGRAM" ]]; then
  ATFRAMEWORK_CMAKE_TOOLSET_CI_OPTIONS+=("-DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM=$CMAKE_FIND_ROOT_PATH_MODE_PROGRAM")
fi
if [[ ! -z "$CMAKE_FIND_ROOT_PATH_MODE_LIBRARY" ]]; then
  ATFRAMEWORK_CMAKE_TOOLSET_CI_OPTIONS+=("-DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=$CMAKE_FIND_ROOT_PATH_MODE_LIBRARY")
fi
if [[ ! -z "$CMAKE_FIND_ROOT_PATH_MODE_INCLUDE" ]]; then
  ATFRAMEWORK_CMAKE_TOOLSET_CI_OPTIONS+=("-DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=$CMAKE_FIND_ROOT_PATH_MODE_INCLUDE")
fi
if [[ ! -z "$CMAKE_FIND_ROOT_PATH_MODE_PACKAGE" ]]; then
  ATFRAMEWORK_CMAKE_TOOLSET_CI_OPTIONS+=("-DCMAKE_FIND_ROOT_PATH_MODE_PACKAGE=$CMAKE_FIND_ROOT_PATH_MODE_PACKAGE")
fi
if [[ ! -z "$ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_WITH_SYSTEM" ]]; then
  ATFRAMEWORK_CMAKE_TOOLSET_CI_OPTIONS+=("-DATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_WITH_SYSTEM=$ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_WITH_SYSTEM")
fi

CMAKE_CONFIGURE_EXIT_CODE=0
if [[ "$1" == "format" ]]; then
  python3 -m pip install --user -r ./ci/requirements.txt
  bash ./ci/format.sh
  CHANGED="$(git ls-files --modified)"
  if [[ ! -z "$CHANGED" ]]; then
    echo "The following files have changes:"
    echo "$CHANGED"
    git diff
    exit 1
  fi
  exit 0
elif [[ "$1" == "gcc.no-rtti.test" ]]; then
  echo "$1"
  mkdir -p test/build_jobs_dir
  cd test/build_jobs_dir
  cmake .. -DBUILD_SHARED_LIBS=OFF -DATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LOW_MEMORY_MODE=ON -DCOMPILER_OPTION_DEFAULT_ENABLE_RTTI=OFF \
    ${ATFRAMEWORK_CMAKE_TOOLSET_CI_OPTIONS[@]} || CMAKE_CONFIGURE_EXIT_CODE=$?
  if [[ $CMAKE_CONFIGURE_EXIT_CODE -ne 0 ]]; then
    if [[ -e "CMakeFiles/CMakeConfigureLog.yaml" ]]; then
      cat "CMakeFiles/CMakeConfigureLog.yaml"
    elif [[ -e "CMakeFiles/CMakeOutput.log" ]]; then
      cat "CMakeFiles/CMakeOutput.log"
    fi
    exit $CMAKE_CONFIGURE_EXIT_CODE
  fi
  cmake --build . -j || cmake --build . || cmake --build . --verbose
  THIRD_PARTY_PREBUILT_DIR=$(ls -d $PWD/../third_party/install/*)
  export LD_LIBRARY_PATH="$THIRD_PARTY_PREBUILT_DIR/lib64:$THIRD_PARTY_PREBUILT_DIR/lib"
  ctest . -V
elif [[ "$1" == "gcc.no-exceptions.test" ]]; then
  echo "$1"
  mkdir -p test/build_jobs_dir
  cd test/build_jobs_dir
  cmake .. -DBUILD_SHARED_LIBS=OFF -DATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LOW_MEMORY_MODE=ON -DCOMPILER_OPTION_DEFAULT_ENABLE_EXCEPTION=OFF \
    ${ATFRAMEWORK_CMAKE_TOOLSET_CI_OPTIONS[@]} || CMAKE_CONFIGURE_EXIT_CODE=$?
  if [[ $CMAKE_CONFIGURE_EXIT_CODE -ne 0 ]]; then
    if [[ -e "CMakeFiles/CMakeConfigureLog.yaml" ]]; then
      cat "CMakeFiles/CMakeConfigureLog.yaml"
    elif [[ -e "CMakeFiles/CMakeOutput.log" ]]; then
      cat "CMakeFiles/CMakeOutput.log"
    fi
    exit $CMAKE_CONFIGURE_EXIT_CODE
  fi
  cmake --build . -j || cmake --build . || cmake --build . --verbose
  THIRD_PARTY_PREBUILT_DIR=$(ls -d $PWD/../third_party/install/*)
  export LD_LIBRARY_PATH="$THIRD_PARTY_PREBUILT_DIR/lib64:$THIRD_PARTY_PREBUILT_DIR/lib"
  ctest . -V
elif [[ "$1" == "gcc.static.test" ]]; then
  echo "$1"
  mkdir -p test/build_jobs_dir
  cd test/build_jobs_dir
  cmake .. -DBUILD_SHARED_LIBS=OFF -DATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LOW_MEMORY_MODE=ON \
    ${ATFRAMEWORK_CMAKE_TOOLSET_CI_OPTIONS[@]} || CMAKE_CONFIGURE_EXIT_CODE=$?
  if [[ $CMAKE_CONFIGURE_EXIT_CODE -ne 0 ]]; then
    if [[ -e "CMakeFiles/CMakeConfigureLog.yaml" ]]; then
      cat "CMakeFiles/CMakeConfigureLog.yaml"
    elif [[ -e "CMakeFiles/CMakeOutput.log" ]]; then
      cat "CMakeFiles/CMakeOutput.log"
    fi
    exit $CMAKE_CONFIGURE_EXIT_CODE
  fi
  cmake --build . -j || cmake --build . || cmake --build . --verbose
  THIRD_PARTY_PREBUILT_DIR=$(ls -d $PWD/../third_party/install/*)
  export LD_LIBRARY_PATH="$THIRD_PARTY_PREBUILT_DIR/lib64:$THIRD_PARTY_PREBUILT_DIR/lib"
  ctest . -V
elif [[ "$1" == "gcc.shared.test" ]]; then
  echo "$1"
  mkdir -p test/build_jobs_dir
  cd test/build_jobs_dir
  cmake .. -DBUILD_SHARED_LIBS=ON -DATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_USE_OPENSSL=ON -DATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LOW_MEMORY_MODE=ON \
    ${ATFRAMEWORK_CMAKE_TOOLSET_CI_OPTIONS[@]} || CMAKE_CONFIGURE_EXIT_CODE=$?
  if [[ $CMAKE_CONFIGURE_EXIT_CODE -ne 0 ]]; then
    if [[ -e "CMakeFiles/CMakeConfigureLog.yaml" ]]; then
      cat "CMakeFiles/CMakeConfigureLog.yaml"
    elif [[ -e "CMakeFiles/CMakeOutput.log" ]]; then
      cat "CMakeFiles/CMakeOutput.log"
    fi
    exit $CMAKE_CONFIGURE_EXIT_CODE
  fi
  cmake --build . -j || cmake --build . || cmake --build . --verbose
  THIRD_PARTY_PREBUILT_DIR=$(ls -d $PWD/../third_party/install/*)
  export LD_LIBRARY_PATH="$THIRD_PARTY_PREBUILT_DIR/lib64:$THIRD_PARTY_PREBUILT_DIR/lib"
  ctest . -V
elif [[ "$1" == "gcc.libressl.test" ]]; then
  echo "$1"
  mkdir -p test/build_jobs_dir
  cd test/build_jobs_dir
  cmake .. -DATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_USE_LIBRESSL=ON -DATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LOW_MEMORY_MODE=ON \
    ${ATFRAMEWORK_CMAKE_TOOLSET_CI_OPTIONS[@]} || CMAKE_CONFIGURE_EXIT_CODE=$?
  if [[ $CMAKE_CONFIGURE_EXIT_CODE -ne 0 ]]; then
    if [[ -e "CMakeFiles/CMakeConfigureLog.yaml" ]]; then
      cat "CMakeFiles/CMakeConfigureLog.yaml"
    elif [[ -e "CMakeFiles/CMakeOutput.log" ]]; then
      cat "CMakeFiles/CMakeOutput.log"
    fi
    exit $CMAKE_CONFIGURE_EXIT_CODE
  fi
  cmake --build . -j || cmake --build . || cmake --build . --verbose
  THIRD_PARTY_PREBUILT_DIR=$(ls -d $PWD/../third_party/install/*)
  export LD_LIBRARY_PATH="$THIRD_PARTY_PREBUILT_DIR/lib64:$THIRD_PARTY_PREBUILT_DIR/lib"
  ctest . -V
elif [[ "$1" == "gcc.boringssl.test" ]]; then
  echo "$1"
  mkdir -p test/build_jobs_dir
  cd test/build_jobs_dir
  cmake .. -DATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_USE_BORINGSSL=ON -DATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LOW_MEMORY_MODE=ON \
    ${ATFRAMEWORK_CMAKE_TOOLSET_CI_OPTIONS[@]} || CMAKE_CONFIGURE_EXIT_CODE=$?
  if [[ $CMAKE_CONFIGURE_EXIT_CODE -ne 0 ]]; then
    if [[ -e "CMakeFiles/CMakeConfigureLog.yaml" ]]; then
      cat "CMakeFiles/CMakeConfigureLog.yaml"
    elif [[ -e "CMakeFiles/CMakeOutput.log" ]]; then
      cat "CMakeFiles/CMakeOutput.log"
    fi
    exit $CMAKE_CONFIGURE_EXIT_CODE
  fi
  cmake --build . -j || cmake --build . || cmake --build . --verbose
  THIRD_PARTY_PREBUILT_DIR=$(ls -d $PWD/../third_party/install/*)
  export LD_LIBRARY_PATH="$THIRD_PARTY_PREBUILT_DIR/lib64:$THIRD_PARTY_PREBUILT_DIR/lib"
  ctest . -V
elif [[ "$1" == "gcc.mbedtls.test" ]]; then
  echo "$1"
  mkdir -p test/build_jobs_dir
  cd test/build_jobs_dir
  cmake .. -DATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_USE_MBEDTLS=ON -DATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LOW_MEMORY_MODE=ON \
    ${ATFRAMEWORK_CMAKE_TOOLSET_CI_OPTIONS[@]} || CMAKE_CONFIGURE_EXIT_CODE=$?
  if [[ $CMAKE_CONFIGURE_EXIT_CODE -ne 0 ]]; then
    if [[ -e "CMakeFiles/CMakeConfigureLog.yaml" ]]; then
      cat "CMakeFiles/CMakeConfigureLog.yaml"
    elif [[ -e "CMakeFiles/CMakeOutput.log" ]]; then
      cat "CMakeFiles/CMakeOutput.log"
    fi
    exit $CMAKE_CONFIGURE_EXIT_CODE
  fi
  cmake --build . -j || cmake --build . || cmake --build . --verbose
  THIRD_PARTY_PREBUILT_DIR=$(ls -d $PWD/../third_party/install/*)
  export LD_LIBRARY_PATH="$THIRD_PARTY_PREBUILT_DIR/lib64:$THIRD_PARTY_PREBUILT_DIR/lib"
  ctest . -V
elif [[ "$1" == "gcc.4.8.test" ]]; then
  echo "$1"
  mkdir -p test/build_jobs_dir
  cd test/build_jobs_dir
  cmake .. -DCMAKE_C_COMPILER=gcc-4.8 -DCMAKE_CXX_COMPILER=g++-4.8 -DATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LOW_MEMORY_MODE=ON \
    ${ATFRAMEWORK_CMAKE_TOOLSET_CI_OPTIONS[@]} || CMAKE_CONFIGURE_EXIT_CODE=$?
  if [[ $CMAKE_CONFIGURE_EXIT_CODE -ne 0 ]]; then
    if [[ -e "CMakeFiles/CMakeConfigureLog.yaml" ]]; then
      cat "CMakeFiles/CMakeConfigureLog.yaml"
    elif [[ -e "CMakeFiles/CMakeOutput.log" ]]; then
      cat "CMakeFiles/CMakeOutput.log"
    fi
    exit $CMAKE_CONFIGURE_EXIT_CODE
  fi
  cmake --build . -j || cmake --build . || cmake --build . --verbose
  THIRD_PARTY_PREBUILT_DIR=$(ls -d $PWD/../third_party/install/*)
  export LD_LIBRARY_PATH="$THIRD_PARTY_PREBUILT_DIR/lib64:$THIRD_PARTY_PREBUILT_DIR/lib"
  ctest . -V
elif [[ "$1" == "gcc.standalone-upb.test" ]]; then
  echo "$1"
  mkdir -p test/build_jobs_dir
  cd test/build_jobs_dir
  cmake ../upb -DBUILD_SHARED_LIBS=OFF -DATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LOW_MEMORY_MODE=ON \
    ${ATFRAMEWORK_CMAKE_TOOLSET_CI_OPTIONS[@]} || CMAKE_CONFIGURE_EXIT_CODE=$?
  if [[ $CMAKE_CONFIGURE_EXIT_CODE -ne 0 ]]; then
    if [[ -e "CMakeFiles/CMakeConfigureLog.yaml" ]]; then
      cat "CMakeFiles/CMakeConfigureLog.yaml"
    elif [[ -e "CMakeFiles/CMakeOutput.log" ]]; then
      cat "CMakeFiles/CMakeOutput.log"
    fi
    exit $CMAKE_CONFIGURE_EXIT_CODE
  fi
  cmake --build . -j || cmake --build . || cmake --build . --verbose
  THIRD_PARTY_PREBUILT_DIR=$(ls -d $PWD/third_party/install/*)
elif [[ "$1" == "clang.test" ]]; then
  echo "$1"
  mkdir -p test/build_jobs_dir
  cd test/build_jobs_dir
  echo '#include <iostream>
  int main() { std::cout<<"Hello"; }' >test-libc++.cpp
  SELECT_CLANG_VERSION=""
  SELECT_CLANG_HAS_LIBCXX=1
  clang -x c++ -stdlib=libc++ test-libc++.cpp -lc++ -lc++abi || SELECT_CLANG_HAS_LIBCXX=0
  if [[ $SELECT_CLANG_HAS_LIBCXX -eq 0 ]]; then
    CURRENT_CLANG_VERSION=$(clang -x c /dev/null -dM -E | grep __clang_major__ | awk '{print $NF}')
    for ((i = $CURRENT_CLANG_VERSION + 3; $i >= $CURRENT_CLANG_VERSION - 3; --i)); do
      SELECT_CLANG_HAS_LIBCXX=1
      SELECT_CLANG_VERSION="-$i"
      clang$SELECT_CLANG_VERSION -x c++ -stdlib=libc++ test-libc++.cpp -lc++ -lc++abi || SELECT_CLANG_HAS_LIBCXX=0
      if [[ $SELECT_CLANG_HAS_LIBCXX -eq 1 ]]; then
        break
      fi
    done
  fi
  SELECT_CLANGPP_BIN=clang++$SELECT_CLANG_VERSION
  LINK_CLANGPP_BIN=0
  which $SELECT_CLANGPP_BIN || LINK_CLANGPP_BIN=1
  if [[ $LINK_CLANGPP_BIN -eq 1 ]]; then
    mkdir -p .local/bin
    ln -s "$(which "clang$SELECT_CLANG_VERSION")" "$PWD/.local/bin/clang++$SELECT_CLANG_VERSION"
    export PATH="$PWD/.local/bin:$PATH"
  fi
  cmake .. -DCMAKE_C_COMPILER=clang$SELECT_CLANG_VERSION -DCMAKE_CXX_COMPILER=clang++$SELECT_CLANG_VERSION -DATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LOW_MEMORY_MODE=ON \
    ${ATFRAMEWORK_CMAKE_TOOLSET_CI_OPTIONS[@]} || CMAKE_CONFIGURE_EXIT_CODE=$?
  if [[ $CMAKE_CONFIGURE_EXIT_CODE -ne 0 ]]; then
    if [[ -e "CMakeFiles/CMakeConfigureLog.yaml" ]]; then
      cat "CMakeFiles/CMakeConfigureLog.yaml"
    elif [[ -e "CMakeFiles/CMakeOutput.log" ]]; then
      cat "CMakeFiles/CMakeOutput.log"
    fi
    exit $CMAKE_CONFIGURE_EXIT_CODE
  fi
  cmake --build . -j || cmake --build . || cmake --build . --verbose
  THIRD_PARTY_PREBUILT_DIR=$(ls -d $PWD/../third_party/install/*)
  export LD_LIBRARY_PATH="$THIRD_PARTY_PREBUILT_DIR/lib64:$THIRD_PARTY_PREBUILT_DIR/lib"
  ctest . -V
elif [[ "$1" == "gcc.vcpkg.test" ]]; then
  echo "$1"
  [ ! -z "$VCPKG_INSTALLATION_ROOT" ]
  vcpkg install --triplet=x64-linux fmt zlib lz4 zstd libuv openssl curl libwebsockets yaml-cpp rapidjson flatbuffers protobuf grpc gtest benchmark civetweb prometheus-cpp mimalloc
  if [ -e "$VCPKG_INSTALLATION_ROOT/buildtrees" ]; then
    rm -rf "$VCPKG_INSTALLATION_ROOT/buildtrees"
  fi
  if [ -e "$VCPKG_INSTALLATION_ROOT/packages" ]; then
    rm -rf "$VCPKG_INSTALLATION_ROOT/packages"
  fi
  mkdir -p test/build_jobs_dir
  cd test/build_jobs_dir
  cmake .. -DCMAKE_TOOLCHAIN_FILE=$VCPKG_INSTALLATION_ROOT/scripts/buildsystems/vcpkg.cmake -DVCPKG_TARGET_TRIPLET=x64-linux -DATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LOW_MEMORY_MODE=ON \
    --debug-find-pkg=gRPC --debug-find-var=ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_CPP_PLUGIN_EXECUTABLE \
    ${ATFRAMEWORK_CMAKE_TOOLSET_CI_OPTIONS[@]} || CMAKE_CONFIGURE_EXIT_CODE=$?
  if [[ $CMAKE_CONFIGURE_EXIT_CODE -ne 0 ]]; then
    if [[ -e "CMakeFiles/CMakeConfigureLog.yaml" ]]; then
      cat "CMakeFiles/CMakeConfigureLog.yaml"
    elif [[ -e "CMakeFiles/CMakeOutput.log" ]]; then
      cat "CMakeFiles/CMakeOutput.log"
    fi
    exit $CMAKE_CONFIGURE_EXIT_CODE
  fi
  cmake --build . -j || cmake --build . || cmake --build . --verbose
  THIRD_PARTY_PREBUILT_DIR=$(ls -d $PWD/../third_party/install/*)
  export LD_LIBRARY_PATH="$THIRD_PARTY_PREBUILT_DIR/lib64:$THIRD_PARTY_PREBUILT_DIR/lib"
  ctest . -V
elif [[ "$1" == "msys2.mingw.static.test" ]]; then
  echo "$1"
  echo "PATH=$PATH"
  pacman -S --needed --noconfirm mingw-w64-x86_64-cmake git mingw-w64-x86_64-git-lfs m4 curl wget tar autoconf automake mingw-w64-x86_64-toolchain mingw-w64-x86_64-libtool python || true
  # Build protobuf may cause OOM on github hosted runner.
  export ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_ALLOW_LOCAL=1
  pacman -S --needed --noconfirm mingw-w64-x86_64-protobuf
  git config --global http.sslBackend openssl
  mkdir -p test/build_jobs_dir
  cd test/build_jobs_dir
  # export LDFLAGS="$LDFLAGS -ladvapi32 -liphlpapi -lpsapi -luser32 -luserenv -lws2_32 -lgcc"
  cmake .. -G "MinGW Makefiles" -DCMAKE_EXECUTE_PROCESS_COMMAND_ECHO=STDOUT -DBUILD_SHARED_LIBS=OFF -DATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LOW_MEMORY_MODE=ON \
    ${ATFRAMEWORK_CMAKE_TOOLSET_CI_OPTIONS[@]} || CMAKE_CONFIGURE_EXIT_CODE=$?
  if [[ $CMAKE_CONFIGURE_EXIT_CODE -ne 0 ]]; then
    if [[ -e "CMakeFiles/CMakeConfigureLog.yaml" ]]; then
      cat "CMakeFiles/CMakeConfigureLog.yaml"
    elif [[ -e "CMakeFiles/CMakeOutput.log" ]]; then
      cat "CMakeFiles/CMakeOutput.log"
    fi
    exit $CMAKE_CONFIGURE_EXIT_CODE
  fi
  cmake --build . -j || cmake --build . || cmake --build . --verbose
  THIRD_PARTY_PREBUILT_DIR=$(ls -d $PWD/../third_party/install/*)
  export LD_LIBRARY_PATH="$THIRD_PARTY_PREBUILT_DIR/lib64:$THIRD_PARTY_PREBUILT_DIR/lib"
  export PATH="$PATH:$THIRD_PARTY_PREBUILT_DIR/bin"
  ctest . -V
elif [[ "$1" == "msys2.mingw.shared.test" ]]; then
  echo "$1"
  echo "PATH=$PATH"
  pacman -S --needed --noconfirm mingw-w64-x86_64-cmake git mingw-w64-x86_64-git-lfs m4 curl wget tar autoconf automake mingw-w64-x86_64-toolchain mingw-w64-x86_64-libtool python || true
  # Build protobuf may cause OOM on github hosted runner.
  export ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_ALLOW_LOCAL=1
  pacman -S --needed --noconfirm mingw-w64-x86_64-protobuf
  git config --global http.sslBackend openssl
  mkdir -p test/build_jobs_dir
  cd test/build_jobs_dir
  # export LDFLAGS="$LDFLAGS -ladvapi32 -liphlpapi -lpsapi -luser32 -luserenv -lws2_32 -lgcc"
  cmake .. -G "MinGW Makefiles" -DCMAKE_EXECUTE_PROCESS_COMMAND_ECHO=STDOUT -DBUILD_SHARED_LIBS=ON -DATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LOW_MEMORY_MODE=ON \
    -DATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_USE_OPENSSL=ON \
    ${ATFRAMEWORK_CMAKE_TOOLSET_CI_OPTIONS[@]} || CMAKE_CONFIGURE_EXIT_CODE=$?
  if [[ $CMAKE_CONFIGURE_EXIT_CODE -ne 0 ]]; then
    if [[ -e "CMakeFiles/CMakeConfigureLog.yaml" ]]; then
      cat "CMakeFiles/CMakeConfigureLog.yaml"
    elif [[ -e "CMakeFiles/CMakeOutput.log" ]]; then
      cat "CMakeFiles/CMakeOutput.log"
    fi
    exit $CMAKE_CONFIGURE_EXIT_CODE
  fi
  cmake --build . -j || cmake --build . || cmake --build . --verbose
  THIRD_PARTY_PREBUILT_DIR=$(ls -d $PWD/../third_party/install/*)
  export LD_LIBRARY_PATH="$THIRD_PARTY_PREBUILT_DIR/lib64:$THIRD_PARTY_PREBUILT_DIR/lib"
  export PATH="$PATH:$THIRD_PARTY_PREBUILT_DIR/bin"
  ctest . -V
elif [[ "$1" == "msvc.static.test" ]]; then
  echo "$1"
  mkdir -p test/build_jobs_dir
  cd test/build_jobs_dir
  echo "<Project>
   <PropertyGroup>
      <UseStructuredOutput>false</UseStructuredOutput>
   </PropertyGroup>
</Project>" > Directory.Build.props
  if [[ "x$CMAKE_GENERATOR" == "x" ]]; then
    CMAKE_GENERATOR="Visual Studio 17 2022"
  fi
  cmake .. -G "$CMAKE_GENERATOR" -A x64 -DBUILD_SHARED_LIBS=OFF -DCMAKE_BUILD_TYPE=$CI_BUILD_CONFIGURE_TYPE -DATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LOW_MEMORY_MODE=ON \
    "-DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY" "-DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY" "-DCMAKE_FIND_ROOT_PATH_MODE_PACKAGE=ONLY" \
    -DVS_GLOBAL_VcpkgEnabled=OFF \
    ${ATFRAMEWORK_CMAKE_TOOLSET_CI_OPTIONS[@]} || CMAKE_CONFIGURE_EXIT_CODE=$?
  if [[ $CMAKE_CONFIGURE_EXIT_CODE -ne 0 ]]; then
    if [[ -e "CMakeFiles/CMakeConfigureLog.yaml" ]]; then
      cat "CMakeFiles/CMakeConfigureLog.yaml"
    elif [[ -e "CMakeFiles/CMakeOutput.log" ]]; then
      cat "CMakeFiles/CMakeOutput.log"
    fi
    exit $CMAKE_CONFIGURE_EXIT_CODE
  fi
  cmake --build . -j --config $CI_BUILD_CONFIGURE_TYPE || cmake --build . --config $CI_BUILD_CONFIGURE_TYPE
  THIRD_PARTY_PREBUILT_DIR=$(ls -d $PWD/../third_party/install/*)
  export LD_LIBRARY_PATH="$THIRD_PARTY_PREBUILT_DIR/lib64:$THIRD_PARTY_PREBUILT_DIR/lib"
  export PATH="$PATH:$THIRD_PARTY_PREBUILT_DIR/bin"
  ctest . -V -C $CI_BUILD_CONFIGURE_TYPE
elif [[ "$1" == "msvc.shared.test" ]]; then
  echo "$1"
  mkdir -p test/build_jobs_dir
  cd test/build_jobs_dir
  echo "<Project>
   <PropertyGroup>
      <UseStructuredOutput>false</UseStructuredOutput>
   </PropertyGroup>
</Project>" > Directory.Build.props
  if [[ "x$CMAKE_GENERATOR" == "x" ]]; then
    CMAKE_GENERATOR="Visual Studio 17 2022"
  fi
  cmake .. -G "$CMAKE_GENERATOR" -A x64 -DBUILD_SHARED_LIBS=ON -DCMAKE_BUILD_TYPE=$CI_BUILD_CONFIGURE_TYPE -DATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LOW_MEMORY_MODE=ON \
    "-DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY" "-DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY" "-DCMAKE_FIND_ROOT_PATH_MODE_PACKAGE=ONLY" \
    -DVS_GLOBAL_VcpkgEnabled=OFF \
    ${ATFRAMEWORK_CMAKE_TOOLSET_CI_OPTIONS[@]} || CMAKE_CONFIGURE_EXIT_CODE=$?
  if [[ $CMAKE_CONFIGURE_EXIT_CODE -ne 0 ]]; then
    if [[ -e "CMakeFiles/CMakeConfigureLog.yaml" ]]; then
      cat "CMakeFiles/CMakeConfigureLog.yaml"
    elif [[ -e "CMakeFiles/CMakeOutput.log" ]]; then
      cat "CMakeFiles/CMakeOutput.log"
    fi
    exit $CMAKE_CONFIGURE_EXIT_CODE
  fi
  cmake --build . -j --config $CI_BUILD_CONFIGURE_TYPE || cmake --build . --config $CI_BUILD_CONFIGURE_TYPE
  THIRD_PARTY_PREBUILT_DIR=$(ls -d $PWD/../third_party/install/*)
  export LD_LIBRARY_PATH="$THIRD_PARTY_PREBUILT_DIR/lib64:$THIRD_PARTY_PREBUILT_DIR/lib"
  export PATH="$PATH:$THIRD_PARTY_PREBUILT_DIR/bin"
  ctest . -V
elif [[ "$1" == "msvc.vcpkg.test" ]]; then
  echo "$1"
  [ ! -z "$VCPKG_INSTALLATION_ROOT" ]
  # benchmark 1.7.0 has linking problems
  vcpkg install --triplet=x64-windows-static-md fmt zlib lz4 zstd libuv openssl curl libwebsockets yaml-cpp rapidjson flatbuffers protobuf grpc gtest civetweb prometheus-cpp mimalloc
  mkdir -p test/build_jobs_dir
  echo "<Project>
   <PropertyGroup>
      <UseStructuredOutput>false</UseStructuredOutput>
   </PropertyGroup>
</Project>" > Directory.Build.props
  if [ -e "$VCPKG_INSTALLATION_ROOT/buildtrees" ]; then
    rm -rf "$VCPKG_INSTALLATION_ROOT/buildtrees"
  fi
  if [ -e "$VCPKG_INSTALLATION_ROOT/packages" ]; then
    rm -rf "$VCPKG_INSTALLATION_ROOT/packages"
  fi
  cd test/build_jobs_dir
  if [[ "x$CMAKE_GENERATOR" == "x" ]]; then
    CMAKE_GENERATOR="Visual Studio 17 2022"
  fi
  cmake .. -G "$CMAKE_GENERATOR" -A x64 -DCMAKE_TOOLCHAIN_FILE=$VCPKG_INSTALLATION_ROOT/scripts/buildsystems/vcpkg.cmake -DVCPKG_TARGET_TRIPLET=x64-windows-static-md \
    -DCMAKE_BUILD_TYPE=$CI_BUILD_CONFIGURE_TYPE -DATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LOW_MEMORY_MODE=ON \
    "-DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY" "-DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY" "-DCMAKE_FIND_ROOT_PATH_MODE_PACKAGE=ONLY" \
    --debug-find-pkg=gRPC --debug-find-var=ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_CPP_PLUGIN_EXECUTABLE \
    ${ATFRAMEWORK_CMAKE_TOOLSET_CI_OPTIONS[@]} || CMAKE_CONFIGURE_EXIT_CODE=$?
  if [[ $CMAKE_CONFIGURE_EXIT_CODE -ne 0 ]]; then
    if [[ -e "CMakeFiles/CMakeConfigureLog.yaml" ]]; then
      cat "CMakeFiles/CMakeConfigureLog.yaml"
    elif [[ -e "CMakeFiles/CMakeOutput.log" ]]; then
      cat "CMakeFiles/CMakeOutput.log"
    fi
    exit $CMAKE_CONFIGURE_EXIT_CODE
  fi
  cmake --build . -j --config $CI_BUILD_CONFIGURE_TYPE || cmake --build . --config $CI_BUILD_CONFIGURE_TYPE
  THIRD_PARTY_PREBUILT_DIR=$(ls -d $PWD/../third_party/install/*)
  export LD_LIBRARY_PATH="$THIRD_PARTY_PREBUILT_DIR/lib64:$THIRD_PARTY_PREBUILT_DIR/lib"
  export PATH="$PATH:$THIRD_PARTY_PREBUILT_DIR/bin"
  ctest . -V -C $CI_BUILD_CONFIGURE_TYPE
elif [[ "$1" == "msvc2017.test" ]]; then
  echo "$1"
  mkdir -p test/build_jobs_dir
  cd test/build_jobs_dir
  cmake .. -G "Visual Studio 15 2017" -A x64 -DCMAKE_BUILD_TYPE=$CI_BUILD_CONFIGURE_TYPE -DATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LOW_MEMORY_MODE=ON \
    "-DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY" "-DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY" "-DCMAKE_FIND_ROOT_PATH_MODE_PACKAGE=ONLY" \
    -DVS_GLOBAL_VcpkgEnabled=OFF \
    ${ATFRAMEWORK_CMAKE_TOOLSET_CI_OPTIONS[@]} || CMAKE_CONFIGURE_EXIT_CODE=$?
  if [[ $CMAKE_CONFIGURE_EXIT_CODE -ne 0 ]]; then
    if [[ -e "CMakeFiles/CMakeConfigureLog.yaml" ]]; then
      cat "CMakeFiles/CMakeConfigureLog.yaml"
    elif [[ -e "CMakeFiles/CMakeOutput.log" ]]; then
      cat "CMakeFiles/CMakeOutput.log"
    fi
    exit $CMAKE_CONFIGURE_EXIT_CODE
  fi
  cmake --build . -j --config $CI_BUILD_CONFIGURE_TYPE || cmake --build . --config $CI_BUILD_CONFIGURE_TYPE
  THIRD_PARTY_PREBUILT_DIR=$(ls -d $PWD/../third_party/install/*)
  export LD_LIBRARY_PATH="$THIRD_PARTY_PREBUILT_DIR/lib64:$THIRD_PARTY_PREBUILT_DIR/lib"
  export PATH="$PATH:$THIRD_PARTY_PREBUILT_DIR/bin"
  ctest . -V -C $CI_BUILD_CONFIGURE_TYPE
elif [[ "$1" == "android.arm64.test" ]]; then
  echo "$1"
  if [[ -z "$ANDROID_NDK_ROOT" ]] && [[ ! -z "$ANDROID_NDK_LATEST_HOME" ]]; then
    export ANDROID_NDK_ROOT="$ANDROID_NDK_LATEST_HOME"
  fi
  mkdir -p test/build_jobs_android
  cd test/build_jobs_android
  bash ../../ci/cmake_android_wrapper.sh -r .. -a arm64-v8a -- \
    -DATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_USE_OPENSSL=YES -DATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LOW_MEMORY_MODE=ON \
    ${ATFRAMEWORK_CMAKE_TOOLSET_CI_OPTIONS[@]} || CMAKE_CONFIGURE_EXIT_CODE=$?
  cd build_jobs_arm64-v8a
  if [[ $CMAKE_CONFIGURE_EXIT_CODE -ne 0 ]]; then
    if [[ -e "CMakeFiles/CMakeConfigureLog.yaml" ]]; then
      cat "CMakeFiles/CMakeConfigureLog.yaml"
    elif [[ -e "CMakeFiles/CMakeOutput.log" ]]; then
      cat "CMakeFiles/CMakeOutput.log"
    fi
    exit $CMAKE_CONFIGURE_EXIT_CODE
  fi
  cmake --build . -j || cmake --build . || cmake --build . --verbose
elif [[ "$1" == "android.x86_64.test" ]]; then
  echo "$1"
  if [[ -z "$ANDROID_NDK_ROOT" ]] && [[ ! -z "$ANDROID_NDK_LATEST_HOME" ]]; then
    export ANDROID_NDK_ROOT="$ANDROID_NDK_LATEST_HOME"
  fi
  mkdir -p test/build_jobs_android
  cd test/build_jobs_android
  bash ../../ci/cmake_android_wrapper.sh -r .. -a x86_64 -- \
    -DATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_USE_OPENSSL=YES -DATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LOW_MEMORY_MODE=ON \
    ${ATFRAMEWORK_CMAKE_TOOLSET_CI_OPTIONS[@]} || CMAKE_CONFIGURE_EXIT_CODE=$?
  cd build_jobs_x86_64
  if [[ $CMAKE_CONFIGURE_EXIT_CODE -ne 0 ]]; then
    if [[ -e "CMakeFiles/CMakeConfigureLog.yaml" ]]; then
      cat "CMakeFiles/CMakeConfigureLog.yaml"
    elif [[ -e "CMakeFiles/CMakeOutput.log" ]]; then
      cat "CMakeFiles/CMakeOutput.log"
    fi
    exit $CMAKE_CONFIGURE_EXIT_CODE
  fi
  cmake --build . -j || cmake --build . || cmake --build . --verbose
elif [[ "$1" == "ios.test" ]]; then
  echo "$1"
  mkdir -p test/build_jobs_ios
  cd test/build_jobs_ios
  bash ../../ci/cmake_ios_wrapper.sh -r .. -a arm64 -- \
    -DATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_USE_OPENSSL=YES -DATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LOW_MEMORY_MODE=ON \
    ${ATFRAMEWORK_CMAKE_TOOLSET_CI_OPTIONS[@]} || CMAKE_CONFIGURE_EXIT_CODE=$?
  cd build_jobs_arm64
  if [[ $CMAKE_CONFIGURE_EXIT_CODE -ne 0 ]]; then
    if [[ -e "CMakeFiles/CMakeConfigureLog.yaml" ]]; then
      cat "CMakeFiles/CMakeConfigureLog.yaml"
    elif [[ -e "CMakeFiles/CMakeOutput.log" ]]; then
      cat "CMakeFiles/CMakeOutput.log"
    fi
    exit $CMAKE_CONFIGURE_EXIT_CODE
  fi
  cmake --build . -j || cmake --build . || cmake --build . --verbose
elif [[ "$1" == "iphone_simulator.test" ]]; then
  echo "$1"
  mkdir -p test/build_jobs_iphone_simulator
  cd test/build_jobs_iphone_simulator
  bash ../../ci/cmake_ios_wrapper.sh -r .. -a x86_64 -- \
    -DATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_USE_OPENSSL=YES -DATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LOW_MEMORY_MODE=ON \
    ${ATFRAMEWORK_CMAKE_TOOLSET_CI_OPTIONS[@]} || CMAKE_CONFIGURE_EXIT_CODE=$?
  cd build_jobs_x86_64
  if [[ $CMAKE_CONFIGURE_EXIT_CODE -ne 0 ]]; then
    if [[ -e "CMakeFiles/CMakeConfigureLog.yaml" ]]; then
      cat "CMakeFiles/CMakeConfigureLog.yaml"
    elif [[ -e "CMakeFiles/CMakeOutput.log" ]]; then
      cat "CMakeFiles/CMakeOutput.log"
    fi
    exit $CMAKE_CONFIGURE_EXIT_CODE
  fi
  cmake --build . -j || cmake --build . || cmake --build . --verbose
fi
