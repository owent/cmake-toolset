---
description: >-
  Use when editing or creating patch files under ports/.
  Covers patch naming, matching behavior, cross-
  compilation patch handling, and redundancy checks.
applyTo: "ports/**/*.patch"
---

# Port Patch Guidelines

- Patch files are consumed by
  `project_third_party_try_patch_file()` in
  `ports/Configure.cmake`.
- Keep patches in the same directory as the related port
  cmake file.
- Use names `{port}-{version}.patch` or
  `{port}-{version}.cross.patch`.
- Exact match wins first. Otherwise the same minor
  prefix chooses the highest patch version `<=` the
  target version.
- The version in the patch filename should be the
  version at which the patch was generated or verified.
- Do not create a new patch when an existing same-minor
  patch still applies cleanly and produces the same
  behavior.
- `.cross.patch` files are for cross-compiling-specific
  fixes and must be tested separately from normal
  patches.
- Generate patches from an upstream source tree with
  standard `git diff` output.
