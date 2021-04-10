#!/bin/bash

find . -type f -name "*.cmake" -print -o -name "*.cmake.in" -print \
  -o -name 'CMakeLists.txt' -print | xargs cmake-format -i
