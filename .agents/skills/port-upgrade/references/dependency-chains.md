# Dependency Chains

## How to Discover Dependencies

**Do NOT rely on hardcoded dependency lists.**
Always query upstream repositories to discover
the actual dependency relationships and pinned
versions for the target release.

### General Procedure

1. **Read the port cmake file** in this repo to
   identify known dependency groups (look for
   `PORT_PREFIX` usage and `find_package()` calls).
2. **Read `test/CMakeLists.txt`** to confirm the
   repository's canonical include order and local
   compatibility guards.
3. **Fetch the upstream repo** at the target version
   tag.
4. **Inspect build metadata** for dependency pins.
   Common locations by build system:
   - Bazel: `MODULE.bazel`, `WORKSPACE`,
     `bazel/deps.bzl`, or `*_deps.bzl`
   - CMake: `CMakeLists.txt`, `cmake/` directory,
     `FetchContent` calls
   - Other: `vcpkg.json`, `conanfile.py`,
     `third_party/` directory
5. **Extract pinned versions** for each dependency.
6. **Resolve conflicts**: when multiple ports pin
   the same dependency at different versions, use
   the highest commonly supported version. If
   incompatible, report the conflict to the user.

### Where to Look for Dependency Pins

| Build System | Files to Check |
| ------------ | -------------- |
| Bazel | `MODULE.bazel`, `WORKSPACE` |
| CMake | `CMakeLists.txt`, `cmake/*.cmake` |
| Meson | `subprojects/*.wrap` |
| pkg-config | `*.pc.in` |
| General | `third_party/`, `vendor/` dirs |

### Conflict Resolution

When port A pins dependency D at version X, and
port B pins D at version Y:

1. Check if the higher version is backward-compatible
   with both A and B.
2. If yes, use the higher version.
3. If no, check whether either A or B has a newer
   release that aligns versions.
4. If unresolvable, report the conflict and let the
   user decide.

## Known Dependency Groups in This Repo

The port cmake files in `ports/` use `PORT_PREFIX`
to group related ports. Read those files to discover
current groups. Some historically known groups
include:

- **GRPC group** (`PORT_PREFIX "GRPC"`):
  abseil-cpp, re2, protobuf, grpc. These share the
  `ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_*`
  variable namespace.
- **SSL group**: zlib, openssl (or alternatives),
  libcurl, nghttp2, ngtcp2, nghttp3, libwebsockets.
  These have implicit ordering dependencies.
- **Telemetry group**: depends on protobuf and
  abseil-cpp; includes opentelemetry-cpp and
  optionally prometheus-cpp.

**Always verify** these groups by reading the current
port cmake files and `test/CMakeLists.txt`. Groups and
their members may change over time.

## Port Include Order

The `test/CMakeLists.txt` file defines the canonical
include order. Read it to determine the correct
dependency ordering when adding or reordering ports.
