# Deprecated Build Options Analysis

## Procedure

When upgrading a port version, check for deprecated
or removed CMake options.

### Step 1: Read Upstream Changelog

For each updated port, check:

- `CHANGES.md`, `CHANGELOG.md`, `NEWS`, or
  `RELEASE_NOTES.md` in the upstream repo
- GitHub release notes between old and new version
- Migration guides if the major version changed

### Step 2: Compare CMake Option Definitions

```bash
# In the cloned new version repo
grep -r "option(" CMakeLists.txt cmake/ \
  --include="*.cmake" | sort > /tmp/new-options.txt

# Compare with old version (if available)
# Look for options that were removed or renamed
```

### Step 3: Check for Deprecated Warnings

Search for deprecation markers in the new version:

```bash
grep -ri "deprecat\|obsolete\|removed\|no.longer" \
  CMakeLists.txt cmake/ --include="*.cmake"
```

### Step 4: Known Deprecated Patterns

**zlib >= 1.3.2**: Uses `ZLIB_BUILD_SHARED` and
`ZLIB_BUILD_STATIC` instead of `BUILD_SHARED_LIBS`.

**cmake range syntax**: `VERSION X...Y` needs
cmake >= 3.12. Use single version for older cmake.

For other libraries, always check the upstream
changelog rather than relying on a static table.

### Step 5: Implement Version-Conditional Removal

When a build option is deprecated in a new version,
implement version-conditional logic in the port
cmake file:

```cmake
# Example: option renamed in v2.0
if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_EXAMPLE_VERSION
    VERSION_LESS "2.0.0")
  list(APPEND
    ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_EXAMPLE_BUILD_OPTIONS
    "-DOLD_OPTION=value")
else()
  list(APPEND
    ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_EXAMPLE_BUILD_OPTIONS
    "-DNEW_OPTION=value")
endif()
```

### Step 6: Report to User

When deprecated options are found, report clearly:

- Which option is deprecated
- In which version it was deprecated
- What the replacement is (if any)
- Whether the port cmake file handles it

## Known Version-Sensitive Options

Track options that change across versions here as
they are discovered.

- **zlib >= 1.3.2**: CMake completely rewritten.
  Uses `ZLIB_BUILD_SHARED`/`ZLIB_BUILD_STATIC`
  instead of always building both.
- **yaml-cpp >= 0.9.0**: Tag format reverted from
  bare version (e.g., `0.8.0`) to prefixed
  (e.g., `yaml-cpp-0.9.0`).
- **opentelemetry-cpp >= 1.22**: Many fixes from
  v1.21 patch were upstreamed. Only GCC 4.8
  compatibility patches remain needed.
- **grpc >= 1.54**: Requires abseil-cpp >= 20230125
  and protobuf >= v22. Older compiler path uses
  grpc v1.54.3.
