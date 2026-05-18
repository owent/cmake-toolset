# Repository Maintenance Guidelines

Use this reference when editing cmake-toolset port files, patch files, test integration, CI entrypoints, or GitHub
workflow matrices. These rules replace tool-specific `.github/instructions/*.instructions.md` mirrors; keep this file as
English-only shared guidance for all agents.

## Port CMake Files

Apply these rules to `ports/**/*.cmake`.

### Structure

Standard ports usually follow this sequence:

1. `include_guard(DIRECTORY)`.
2. Port header comments with the upstream URL.
3. A `PROJECT_THIRD_PARTY_<PORT>_IMPORT` macro that imports existing targets and sets the link-name variable.
4. Try system or prebuilt packages first with `find_package(... QUIET)` plus the import macro.
5. Declare the fallback source build with `project_third_party_port_declare()`.
6. Append shared/static selection through project helper macros.
7. Resolve and append patch files with `project_third_party_try_patch_file()`.
8. Build and install through `find_configure_package()`.
9. Re-run the import macro after the fallback build is declared.

### Rules

- Use `PORT_PREFIX` when the port belongs to a dependency group, for example `"GRPC"` for abseil-cpp, re2, protobuf,
  and grpc.
- Keep patch files in the same directory as the related port CMake file.
- Patch names are `{port-name}-{version}.patch` or `{port-name}-{version}.cross.patch`; use the version where the patch
  was generated or verified.
- Set versions as overridable defaults so users can override them with `-D` flags.
- Use `project_third_party_append_build_shared_lib_var()` and related helpers for `BUILD_SHARED_LIBS`; never hardcode
  shared/static choices. The underlying `project_third_party_check_build_shared_lib()` resolves shared/static mode with
  this priority:
  1. `${FULL_PORT_NAME}_USE_SHARED` from CMake or environment: build shared.
  2. `${FULL_PORT_NAME}_USE_STATIC` from CMake or environment: build static.
  3. `BUILD_SHARED_LIBS` or `ATFRAMEWORK_USE_DYNAMIC_LIBRARY`: build shared.
  4. Otherwise: build static.
- Use `project_third_party_port_add_build_options()` to append extra flags after `project_third_party_port_declare()`.
- `find_configure_package()` is defined in `modules/FindConfigurePackage.cmake`, not in `ports/`.

### Truth Sources

- Use the upstream repository at the target tag for dependency pins, tag naming, and option changes.
- Use `ports/Configure.cmake` for macro behavior, patch matching, shared/static helpers, and cross-compiling host
  helpers.
- Use `test/CMakeLists.txt` for repository include order and compatibility guards.

### Special Patterns

- `import.cmake` files coordinate grouped includes and ordering; do not treat them as simple single-port files.
- Orchestrators such as `ssl/port.cmake` select among multiple backends and may not call the standard template directly.
- Complex ports such as `protobuf/protobuf.cmake` may manage hosted tools, RTTI, visibility, or version-conditional
  logic.
- Ports with `crosscompiling-host/` assets may require host-side validation and `.cross.patch` handling in addition to
  the target build.

## Patch Files

Apply these rules to `ports/**/*.patch`.

- Patch files are consumed by `project_third_party_try_patch_file()` in `ports/Configure.cmake`.
- Keep patches in the same directory as the related port CMake file.
- Use names `{port}-{version}.patch` or `{port}-{version}.cross.patch`.
- Exact match wins first. Otherwise the same minor prefix chooses the highest patch version `<=` the target version.
- The version in the patch filename should be the version where the patch was generated or verified.
- Do not create a new patch when an existing same-minor patch still applies cleanly and produces the same behavior.
- `.cross.patch` files are for cross-compiling-specific fixes and must be tested separately from normal patches.
- Generate patches from an upstream source tree with standard `git diff` output.

## Test Integration

Apply these rules to `test/CMakeLists.txt`.

- Treat this file as the repository source of truth for port include order and conditional enablement.
- Existing guards encode compatibility knowledge. Do not simplify or delete them unless you verify the affected platform,
  compiler, backend, or feature combination.
- When adding, removing, or upgrading ports:
  - Keep dependency order valid.
  - Update `target_link_libraries()` and generated-tool tests together.
  - Review conditions for exceptions, RTTI, compiler version, SSL backend, and cross-compiling behavior.
- Preserve backend-specific constraints already in this file, such as skipping `libevent` when BoringSSL or LibreSSL is
  selected and skipping `libwebsockets` when BoringSSL is selected.
- If this file changes, review `.github/workflows/` and affected skill references for any required sync.

## CI Entrypoints

Apply these rules to `ci/do_ci.*`.

- Keep script behavior aligned with `.github/workflows/build.yaml` job names and expected environment variables.
- Preserve platform wrappers, backend switches, and low-memory or cleanup flags unless you validate the changed CI
  behavior.
- When adding or removing a validation path, update both the workflow file and these entrypoint scripts.
- If a change affects cross-compiling, SSL backend selection, or compiler feature toggles, review `test/CMakeLists.txt`
  to keep repository rules aligned.

## CI Workflow Matrix

Apply these rules to `.github/workflows/*.yaml`.

- Workflow jobs are the canonical list of validated platform, toolchain, backend, and build-mode combinations.
- Keep job names stable when practical because project docs and team habits may reference them.
- When port behavior changes, review whether the affected jobs still cover the important combinations:
  - No-RTTI and no-exceptions builds.
  - Static and shared builds.
  - SSL backend variants.
  - Android and iOS cross builds.
  - Compiler-specific gates.
- Preserve cleanup and cache-related environment settings unless you intentionally change CI behavior.
- If a port is intentionally skipped in some configs, make sure the workflow and `test/CMakeLists.txt` describe the same
  compatibility story.
