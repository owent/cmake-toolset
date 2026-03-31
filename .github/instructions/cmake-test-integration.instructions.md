---
description: >-
  Use when editing test/CMakeLists.txt. This file is the
  canonical integration include order and compatibility
  matrix for ports, generated-tool tests, compiler
  feature guards, and SSL backend exclusions.
applyTo: "test/CMakeLists.txt"
---

# Test Integration Guidelines

- Treat this file as the repository source of truth for
  port include order and conditional enablement.
- Existing guards encode compatibility knowledge. Do not
  simplify or delete them unless you verify the affected
  platform, compiler, backend, or feature combination.
- When adding, removing, or upgrading ports:
  - keep dependency order valid
  - update `target_link_libraries()` and generated-tool
    tests together
  - review conditions for exceptions, RTTI, compiler
    version, SSL backend, and cross-compiling behavior
- Preserve backend-specific constraints already in this
  file, such as skipping `libevent` when BoringSSL or
  LibreSSL is selected and skipping `libwebsockets`
  when BoringSSL is selected.
- If this file changes, review `.github/workflows/`
  and affected skill references for any required sync.
