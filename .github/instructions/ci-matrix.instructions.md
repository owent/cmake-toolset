---
description: >-
  Use when editing GitHub workflow files for cmake-
  toolset. These workflows define the validated CI
  matrix for compiler, platform, backend, and build
  mode combinations.
applyTo: ".github/workflows/*.yaml"
---

# CI Matrix Guidelines

- Workflow jobs are the canonical list of validated
  platform, toolchain, backend, and build-mode
  combinations.
- Keep job names stable when practical because project
  docs and team habits may reference them.
- When port behavior changes, review whether the
  affected jobs still cover the important combinations:
  - no-rtti and no-exceptions builds
  - static and shared builds
  - SSL backend variants
  - Android and iOS cross builds
  - compiler-specific gates
- Preserve cleanup and cache-related environment
  settings unless you intentionally change CI behavior.
- If a port is intentionally skipped in some configs,
  make sure the workflow and `test/CMakeLists.txt`
  describe the same compatibility story.
