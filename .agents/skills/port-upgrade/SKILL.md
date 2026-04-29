---
name: port-upgrade
description: "Use when: upgrading cmake-toolset ports, checking upstream releases, resolving dependency pins, validating patches, handling cross-compiling host tools, or reviewing CI impact."
argument-hint: >-
  ports=<names|all>; mode=analyze|update;
  validate=patch|build|ci|full
---

# Port Upgrade Workflow

Use this skill to upgrade one or more ports while
preserving dependency compatibility, patch behavior,
and repository-specific guards.

## Workflow

### Phase 0: Preflight Classification

- Classify the entry file as a standard port,
  aggregator, orchestrator, complex port, or
  cross-compiling host port.
- Read the truth sources:
  - upstream repo at the target tag
  - `ports/Configure.cmake`
  - `test/CMakeLists.txt`
  - `.github/workflows/build.yaml` and `ci/do_ci.*`
- Record compiler/version fallbacks, hosted tools,
  RTTI/visibility logic, cross-compiling support, and
  backend exclusions.

### Phase 1: Version Survey

- Find all current version declarations and related
  tag or compiler fallback logic.
- Fetch the latest stable upstream releases.
- Build a table of current vs target versions.

### Phase 2: Dependency Analysis

- Query upstream build metadata such as
  `MODULE.bazel`, `WORKSPACE`, `bazel/*_deps.bzl`,
  `CMakeLists.txt`, and `cmake/*.cmake`.
- Use `test/CMakeLists.txt` for repository include
  order and local compatibility guards.
- When multiple ports pin the same dependency
  differently, use the highest commonly supported
  version or report the conflict.
- See [dependency-chains.md](./references/dependency-chains.md).

### Phase 3: Special-Case Analysis

- Any `import.cmake` under `ports/` is an aggregator.
  Known aggregators: `compression/`, `algorithm/`,
  `grpc/`, `ngtcp2/`, `telemetry/`, `test/`, `web/`.
- Treat aggregators and orchestrators as grouped logic,
  not template-only edits.
- Preserve compiler fallbacks, backend exclusions,
  RTTI/visibility logic, and hosted-tool behavior unless
  validated.
- For `crosscompiling-host/`, hosted tools, or
  `.cross.patch`, follow
  [cross-compilation.md](./references/cross-compilation.md).
- Treat `ssl/port.cmake`, `grpc/import.cmake`, and
  `protobuf/protobuf.cmake` as custom logic.

### Phase 4: Version Updates

- Update all relevant version, tag, and conditional
  references.
- Check tag-format changes and multiple version sites.

### Phase 5: Patch Validation

- Reuse same-minor patch files when they still apply
  cleanly.
- Create a new patch only when the content differs.
- Validate `.cross.patch` separately when relevant.
- Use `--depth 1` for patch testing and clean up
  `test/third_party/packages/` afterward.
- See [patch-workflow.md](./references/patch-workflow.md).

### Phase 6: Deprecated Build Options

- Check upstream changelogs and CMake files for option
  removals or renames.
- See [deprecated-options.md](./references/deprecated-options.md).

### Phase 7: Integration and CI Verification

- Confirm versions, tags, build options, and patch names.
- Review `test/CMakeLists.txt`,
  `.github/workflows/build.yaml`, and `ci/do_ci.*` for
  impacted combinations.
- Summarize changes, validation, and remaining risks.

## Important Rules

- **Pre-commit formatting is mandatory.** Before
  committing, run `cmake-format -i` on every modified
  `.cmake`, `.cmake.in`, and `CMakeLists.txt` file
  (excluding `test/third_party/` and
  `test/build_jobs_*/`). Alternatively run
  `bash ci/format.sh` to format the entire tree.
  CI will reject unformatted files.
- **Never update a dependency without checking its
  dependents.** Always query upstream repos for actual
  version pins rather than assuming from memory.
- **Repository include order comes from
  `test/CMakeLists.txt`.**
- **Patch files are matched by minor version prefix.**
  A patch for `v1.9.4` will match `v1.9.5`
  automatically. Only create a new patch if the content
  actually differs.
- **Ports with `crosscompiling-host/` assets or hosted
  tools require host-side validation.**
- **Preserve repository-specific guards.** Existing
  no-exception, no-rtti, compiler-version, and backend
  exclusions are compatibility knowledge, not dead code.
- **Cross-compilation patches** (`.cross.patch`) are
  separate from regular patches and must be tested
  independently.

## Known Issues

- **c-ares**: Some versions have Windows build
  failures. Check CI notes before updating.
