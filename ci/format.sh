#!/bin/bash

find . -type f -regex ".*test/third_party/.*" -prune -o -regex ".*test/build_jobs_.*" -prune -o \
  -name "*.cmake" -print -o -name "*.cmake.in" -print -o \
  -name 'CMakeLists.txt' -print | xargs cmake-format -i
