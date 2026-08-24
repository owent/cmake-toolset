---
name: testing
description: "Use when: designing, reviewing, registering, or running cmake-toolset CTest cases, configure/module regressions, generated-tool checks, or dependency link/startup smoke tests. For port upgrades use port-upgrade; for CI failure diagnosis use ci-fix-port."
---

# Testing (cmake-toolset)

This repository's `test/` tree primarily validates CMake configure behavior, dependency import/build/link integration,
generated tools, and executable startup. Do not describe all of it as unit coverage.

Read [test design and acceptance](references/test-design-and-acceptance.md) when planning, writing, or reviewing tests.
It is not needed merely to run a known configured test.

## Choose the correct layer

- For a reusable module/helper regression, prefer the smallest fixture project or `cmake -P`-style check that invokes
  the real function/macro and asserts its observable configure result, generated artifact, property, or diagnostic.
- For a port/import change, test the contract cmake-toolset owns: package discovery, target availability/properties,
  generated-tool invocation, compile/link compatibility, and startup. Do not duplicate upstream library behavior tests.
- A trivial GTest/benchmark/main executable can prove that an imported target builds, links, and starts. It does not
  prove GTest discovery, benchmark semantics, or unrelated cmake-toolset behavior unless the registered command executes
  that target and asserts the claimed outcome.
- Cross-compiling paths may only build target artifacts when they cannot execute on the host. Report build-only evidence
  separately from executed tests and use `port-upgrade` for the affected platform/dependency matrix.

## Register what you intend to run

- For every `add_test`, verify `NAME`, `COMMAND`, target/file, arguments, working directory, configuration, platform
  guard, and expected observable result against current `test/CMakeLists.txt` and source. Building a test executable does
  not mean CTest executes it.
- Use `ctest --test-dir <BUILD_DIR> -N -V` to inspect the resolved command before claiming coverage. Keep names in the
  existing `cmake-toolset.<scenario>` style and make the scenario/result clear.
- A configure-failure case must fail for the intended contract violation and distinguish that diagnostic/result from an
  unrelated missing tool, download, compiler, or environment failure.
- Keep generated files and nested fixture build trees under the selected test build directory. Reuse the current
  generator, platform, toolset, cache options, and CI mode; do not write artifacts into the repository root.

## Run the narrowest evidence first

Reuse an existing configured tree such as the current `test/build_jobs_*` directory. When a new tree is required, match
the relevant `ci/do_ci.*` configuration rather than inventing options:

```bash
cmake -S test -B <BUILD_DIR> <verified-options>
cmake --build <BUILD_DIR> --config <CONFIG> --parallel
ctest --test-dir <BUILD_DIR> -C <CONFIG> -R "^cmake-toolset\.<case>$" --output-on-failure
```

Omit `-C` only for a verified single-config generator. After the focused case, run the affected CTest set and the
platform/backend matrix justified by risk. Configuration or dependency downloads may be expensive and network-backed;
report unavailable prerequisites and unrun matrix entries rather than treating them as green.

Apply `cmake-format` to changed CMake test/fixture files as required by `AGENTS.md`. For port/test integration, also
follow `port-upgrade/references/repository-maintenance-guidelines.md`.
