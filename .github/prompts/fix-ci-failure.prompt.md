---
name: "Fix CI Failure"
description: >-
  Fetch build failure logs from a GitHub Actions run
  or PR, diagnose the root cause, and fix the failing
  port or patch.
argument-hint: >-
  pr=<number|url>; run=<id|url>; job=<name>;
  port=<name>; mode=diagnose|fix
agent: "agent"
---

# Fix CI Failure

Use the
[ci-fix-port workflow](../skills/ci-fix-port/SKILL.md)
and the project rules in [AGENTS.md](../../AGENTS.md).

Parse the user's input with this form:

- `pr=` PR number or URL (optional if `run=` given)
- `run=` Actions run ID or URL (optional if `pr=`
  given)
- `job=` job name filter, e.g. `gcc.no-rtti.test`
  (optional)
- `port=` port name hint (optional)
- `mode=` `diagnose` or `fix` (default: `fix`)

If neither `pr=` nor `run=` is provided, ask the user.

For this task:

1. Fetch the failing CI run or PR checks.
2. Download and parse the failure logs.
3. Classify the failure (patch, build option,
   dependency, link, cross-compile).
4. If `mode=fix`, apply the appropriate fix following
   the skill workflow.
5. Verify the fix locally when possible.

Return:

- failing job(s) and platform
- root cause diagnosis
- files changed or proposed
- verification performed
- remaining risks
