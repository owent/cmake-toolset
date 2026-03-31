---
description: >-
  Use when editing ci/do_ci.* scripts. These scripts are
  the workflow entrypoints that translate job names into
  concrete build, test, and platform-specific commands.
applyTo: "ci/do_ci.*"
---

# CI Entrypoint Guidelines

- Keep script behavior aligned with
  `.github/workflows/build.yaml` job names and expected
  environment variables.
- Preserve platform wrappers, backend switches, and
  low-memory or cleanup flags unless you validate the
  changed CI behavior.
- When adding or removing a validation path, update both
  the workflow file and these entrypoint scripts.
- If a change affects cross-compiling, SSL backend
  selection, or compiler feature toggles, review
  `test/CMakeLists.txt` to keep repository rules aligned.
