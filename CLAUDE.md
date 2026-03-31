# cmake-toolset

CMake-based third-party dependency management toolkit
for cross-platform C/C++ projects.

## Truth Sources

- `ports/Configure.cmake`
- `test/CMakeLists.txt`
- `.github/workflows/build.yaml` and `ci/do_ci.*`
- upstream repo at the target tag

## Key Rules

- Standard ports use `include_guard`, import macro,
  `find_package`, patch lookup, and
  `find_configure_package`.
- `ssl/port.cmake`, `grpc/import.cmake`, and
  `protobuf/protobuf.cmake` need custom review.
- Patch matching uses same-minor fallback with the
  highest version `<=` target.
- `crosscompiling-host/` means host-side validation is
  required.
- Historical dependency chains are hints only. Use
  upstream metadata for pins and `test/CMakeLists.txt`
  for include order.

## Workflow

See `.github/skills/port-upgrade/` for the upgrade
workflow and `AGENTS.md` for the full rules.
