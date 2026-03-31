---
name: "Upgrade Port"
description: >-
  Upgrade one or more cmake-toolset ports with a
  structured form-like input for ports, mode,
  validation, and notes.
argument-hint: >-
  ports=<names|all>; mode=analyze|update;
  validate=patch|build|ci|full; notes=<optional>
agent: "agent"
---

# Upgrade Port

Use the
[port-upgrade workflow](../skills/port-upgrade/SKILL.md)
and the project rules in [AGENTS.md](../../AGENTS.md).

Parse the user's input with this form:

- `ports=` required; one or more port names, or `all`
- `mode=` `analyze` or `update` (default: `update`)
- `validate=` `patch`, `build`, `ci`, or `full`
  (default: `patch`)
  - `patch` = Phase 5 only
  - `build` = Phase 4–6
  - `ci` = Phase 7
  - `full` = Phase 4–7
- `notes=` optional extra constraints

If a field is missing, infer safe defaults and ask only
for missing blocking information.

For this task:

1. Classify each requested port as a standard port,
   aggregator, orchestrator, complex port, or
   cross-compiling host port.
2. Query upstream metadata for dependency pins, tag
   naming, and build-option changes. Do not assume
   pins from memory.
3. Use `test/CMakeLists.txt` for repository include
   order and `.github/workflows/build.yaml` plus
   `ci/do_ci.*` for validation scope.
4. Perform the analysis or update according to `mode`.
5. Validate patches, `.cross.patch`, hosted tools, and
   repository-specific guards when relevant.

Return:

- requested scope
- dependency resolution
- files changed or proposed
- validation performed
- risks and follow-ups
