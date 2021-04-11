#!/bin/bash

cd "$(cd "$(dirname $0)" && pwd)";

set -e ;

if [[ "$1" == "format" ]]; then
  ./format.sh ;
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
elif [[ "$1" == "gcc.shared.test" ]]; then
  echo "$1";
elif [[ "$1" == "gcc.libressl.test" ]]; then
  echo "$1";
elif [[ "$1" == "gcc.mbedtls.test" ]]; then
  echo "$1";
elif [[ "$1" == "gcc.4.8.test" ]]; then
  echo "$1";
elif [[ "$1" == "clang.test" ]]; then
  echo "$1";
elif [[ "$1" == "gcc.vcpkg.test" ]]; then
  echo "$1";
elif [[ "$1" == "mingw.static.test" ]]; then
  echo "$1";
elif [[ "$1" == "mingw.shared.test" ]]; then
  echo "$1";
elif [[ "$1" == "msvc.static.test" ]]; then
  echo "$1";
elif [[ "$1" == "msvc.shared.test" ]]; then
  echo "$1";
elif [[ "$1" == "msvc.vcpkg.shared.test" ]]; then
  echo "$1";
elif [[ "$1" == "msvc.vcpkg.static.test" ]]; then
  echo "$1";
elif [[ "$1" == "msvc2017.vcpkg.test" ]]; then
  echo "$1";
elif [[ "$1" == "android.gcc.test" ]]; then
  echo "$1";
elif [[ "$1" == "android.clang.test" ]]; then
  echo "$1";
elif [[ "$1" == "ios.clang.test" ]]; then
  echo "$1";
fi
