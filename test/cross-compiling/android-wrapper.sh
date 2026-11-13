#!/bin/bash
set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEST_DIR="$1"
CMAKE_BIN="$2"
# Native CMake paths passed by CTest must be usable as bash paths too.
if command -v cygpath >/dev/null 2>&1; then
  TEST_DIR="$(cygpath -u "$TEST_DIR")"
  CMAKE_BIN="$(cygpath -u "$CMAKE_BIN")"
fi
mkdir -p "$TEST_DIR/source" "$TEST_DIR/ndk/prebuilt/host/bin" "$TEST_DIR/ndk/build/cmake"
printf 'cmake_minimum_required(VERSION 3.16)\nproject(wrapper-fixture LANGUAGES NONE)\n' >"$TEST_DIR/source/CMakeLists.txt"
printf '\n' >"$TEST_DIR/ndk/build/cmake/android.toolchain.cmake"
# Deliberately not Ninja: passing this to a Ninja generator must fail its version check.
printf '#!/bin/sh\necho "GNU Make 4.4.1"\n' >"$TEST_DIR/ndk/prebuilt/host/bin/make"
chmod +x "$TEST_DIR/ndk/prebuilt/host/bin/make"

export NO_INTERACTIVE=1
unset CMAKE_HOME
export PATH="$(dirname "$CMAKE_BIN"):$PATH"

run_case() {
  local name="$1" expected="$2" generator="$3"
  shift 3
  mkdir -p "$TEST_DIR/$name"
  rm -f "$TEST_DIR/$name/build_jobs_arm64-v8a/CMakeCache.txt"
  (
    cd "$TEST_DIR/$name"
    if [[ -n "$generator" ]]; then
      export CMAKE_GENERATOR="$generator"
    else
      unset CMAKE_GENERATOR
    fi
    bash "$SCRIPT_DIR/../../ci/cmake_android_wrapper.sh" -n "$TEST_DIR/ndk" -r "$TEST_DIR/source" -- "$@"
  )
  local cache="$TEST_DIR/$name/build_jobs_arm64-v8a/CMakeCache.txt"
  if ! grep -Fx "CMAKE_GENERATOR:INTERNAL=$expected" "$cache"; then
    echo "Wrong generator in $name" >&2
    exit 1
  fi
}

run_case explicit Ninja "" -G Ninja
run_case attached Ninja "" -GNinja
run_case environment Ninja Ninja
run_case override Ninja "Unix Makefiles" -G Ninja
if "$CMAKE_BIN" --help | grep -q 'Ninja Multi-Config'; then
  run_case multi "Ninja Multi-Config" "Ninja Multi-Config"
fi
run_case make "Unix Makefiles" "" -G "Unix Makefiles"
rm -f "$TEST_DIR/ndk/prebuilt/host/bin/make"
run_case no-bundled-make Ninja Ninja
run_case system-make "Unix Makefiles" "" -G "Unix Makefiles"
