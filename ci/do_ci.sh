#!/bin/bash

cd "$(cd "$(dirname $0)" && pwd)/..";

set -ex ;

if [[ "$1" == "format" ]]; then
  python3 -m pip install --user -r ./ci/requirements.txt ;
  bash ./ci/format.sh ;
  CHANGED="$(git ls-files --modified)" ;
  if [[ ! -z "$CHANGED" ]]; then
    echo "The following files have changes:" ;
    echo "$CHANGED" ;
    git diff ;
    exit 1 ;
  fi
  exit 0 ;
elif [[ "$1" == "gcc.static.test" ]]; then
  echo "$1";
  mkdir -p test/build_jobs_dir ;
  cd test/build_jobs_dir ;
  cmake .. -DBUILD_SHARED_LIBS=OFF;
  cmake --build . -j || cmake --build .;
elif [[ "$1" == "gcc.shared.test" ]]; then
  echo "$1";
  mkdir -p test/build_jobs_dir ;
  cd test/build_jobs_dir ;
  cmake .. -DBUILD_SHARED_LIBS=ON -DATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_USE_OPENSSL=ON;
  cmake --build . -j || cmake --build .;
elif [[ "$1" == "gcc.libressl.test" ]]; then
  echo "$1";
  mkdir -p test/build_jobs_dir ;
  cd test/build_jobs_dir ;
  cmake .. -DATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_USE_LIBRESSL=ON;
  cmake --build . -j || cmake --build .;
elif [[ "$1" == "gcc.mbedtls.test" ]]; then
  echo "$1";
  mkdir -p test/build_jobs_dir ;
  cd test/build_jobs_dir ;
  cmake .. -DATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_USE_MBEDTLS=ON;
  cmake --build . -j || cmake --build .;
elif [[ "$1" == "gcc.4.8.test" ]]; then
  echo "$1";
  mkdir -p test/build_jobs_dir ;
  cd test/build_jobs_dir ;
  cmake .. -DCMAKE_C_COMPILER=gcc-4.8 -DCMAKE_CXX_COMPILER=g++-4.8 ;
  cmake --build . -j || cmake --build .;
elif [[ "$1" == "clang.test" ]]; then
  echo "$1";
  mkdir -p test/build_jobs_dir ;
  cd test/build_jobs_dir ;
  cmake .. -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ ;
  cmake --build . -j || cmake --build .;
elif [[ "$1" == "gcc.vcpkg.test" ]]; then
  echo "$1";
  [ ! -z "$VCPKG_INSTALLATION_ROOT" ];
  vcpkg install --triplet=x64-linux fmt zlib lz4 zstd libuv openssl curl libwebsockets yaml-cpp rapidjson flatbuffers protobuf grpc gtest benchmark ;
  mkdir -p test/build_jobs_dir ;
  cd test/build_jobs_dir ;
  cmake .. -DCMAKE_TOOLCHAIN_FILE=$VCPKG_INSTALLATION_ROOT/scripts/buildsystems/vcpkg.cmake -DVCPKG_TARGET_TRIPLET=x64-linux ;
  cmake --build . -j || cmake --build . ;
elif [[ "$1" == "msys2.mingw.static.test" ]]; then
  echo "$1";
  echo "PATH=$PATH";
  pacman -S --needed --noconfirm mingw-w64-x86_64-cmake git mingw-w64-x86_64-git-lfs m4 curl wget tar autoconf automake mingw-w64-x86_64-toolchain mingw-w64-x86_64-libtool python || true;
  # Build protobuf may cause OOM on github hosted runner.
  export ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_ALLOW_LOCAL=1
  pacman -S --needed --noconfirm mingw-w64-x86_64-protobuf ;
  git config --global http.sslBackend openssl ;
  mkdir -p test/build_jobs_dir ;
  cd test/build_jobs_dir ;
  # export LDFLAGS="$LDFLAGS -ladvapi32 -liphlpapi -lpsapi -luser32 -luserenv -lws2_32 -lgcc"
  cmake .. -G "MinGW Makefiles" -DCMAKE_EXECUTE_PROCESS_COMMAND_ECHO=STDOUT -DBUILD_SHARED_LIBS=OFF 2>&1;
  cmake --build . -j || cmake --build . ;
  sleep 180
elif [[ "$1" == "msys2.mingw.shared.test" ]]; then
  echo "$1";
  echo "PATH=$PATH";
  pacman -S --needed --noconfirm mingw-w64-x86_64-cmake git mingw-w64-x86_64-git-lfs m4 curl wget tar autoconf automake mingw-w64-x86_64-toolchain mingw-w64-x86_64-libtool python || true;
  # Build protobuf may cause OOM on github hosted runner.
  export ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_ALLOW_LOCAL=1
  pacman -S --needed --noconfirm mingw-w64-x86_64-protobuf ;
  git config --global http.sslBackend openssl ;
  mkdir -p test/build_jobs_dir ;
  cd test/build_jobs_dir ;
  # export LDFLAGS="$LDFLAGS -ladvapi32 -liphlpapi -lpsapi -luser32 -luserenv -lws2_32 -lgcc"
  cmake .. -G "MinGW Makefiles" -DCMAKE_EXECUTE_PROCESS_COMMAND_ECHO=STDOUT -DBUILD_SHARED_LIBS=ON;
  cmake --build . -j || cmake --build .;
elif [[ "$1" == "msvc.static.test" ]]; then
  echo "$1";
  mkdir -p test/build_jobs_dir ;
  cd test/build_jobs_dir ;
  cmake .. -G "Visual Studio 16 2019" -A x64 -DBUILD_SHARED_LIBS=OFF ;
  cmake --build . -j || cmake --build . ;
elif [[ "$1" == "msvc.shared.test" ]]; then
  echo "$1";
  mkdir -p test/build_jobs_dir ;
  cd test/build_jobs_dir ;
  cmake .. -G "Visual Studio 16 2019" -A x64 -DBUILD_SHARED_LIBS=ON ;
  cmake --build . -j || cmake --build . ;
elif [[ "$1" == "msvc.vcpkg.test" ]]; then
  echo "$1";
  [ ! -z "$VCPKG_INSTALLATION_ROOT" ];
  vcpkg install --triplet=x64-windows fmt zlib lz4 zstd libuv openssl curl libwebsockets yaml-cpp rapidjson flatbuffers protobuf grpc gtest benchmark ;
  mkdir -p test/build_jobs_dir ;
  cd test/build_jobs_dir ;
  cmake .. -G "Visual Studio 16 2019" -A x64 -DCMAKE_TOOLCHAIN_FILE=$VCPKG_INSTALLATION_ROOT/scripts/buildsystems/vcpkg.cmake -DVCPKG_TARGET_TRIPLET=x64-windows;
  cmake --build . -j || cmake --build . ;
elif [[ "$1" == "msvc2017.test" ]]; then
  echo "$1";
  mkdir -p test/build_jobs_dir ;
  cd test/build_jobs_dir ;
  cmake .. -G "Visual Studio 15 2017" -A x64 ;
  cmake --build . -j || cmake --build .;
elif [[ "$1" == "android.test" ]]; then
  echo "$1";
  mkdir -p test/build_jobs_dir ;
  cd test/build_jobs_dir ;
  bash ../../ci/cmake_android_wrapper.sh -r .. -a arm64-v8a -- -DATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_USE_OPENSSL=YES ;
  cd build_jobs_arm64-v8a ;
  cmake --build . -j || cmake --build .;
elif [[ "$1" == "ios.test" ]]; then
  echo "$1";
  mkdir -p test/build_jobs_dir ;
  cd test/build_jobs_dir ;
  bash ../../ci/cmake_ios_wrapper.sh -r .. -a arm64 -- -DATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_USE_OPENSSL=YES ;
  cd build_jobs_arm64 ;
  cmake --build . -j || cmake --build .;
fi
