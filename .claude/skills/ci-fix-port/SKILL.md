---
name: ci-fix-port
description: >-
  Fetch CI build failure logs from GitHub Actions or
  PRs, diagnose the root cause, and fix the failing
  port or patch. Use when: a CI job fails after a
  port upgrade, a patch no longer applies, or a build
  option changed upstream.
argument-hint: >-
  pr=<number|url>; run=<id|url>; job=<name>;
  port=<name>; mode=diagnose|fix
---

# CI Fix Port Workflow

Use this skill to pull build failure information from
GitHub Actions, diagnose the cause, and fix the
affected port or patch.

Repository: `atframework/cmake-toolset`

## Prerequisites

The agent needs access to GitHub data. Use one of:

- **GitHub MCP tools** (`mcp_github_*`) if available
- **`gh` CLI** via terminal if installed and
  authenticated
- **`fetch_webpage`** tool to read GitHub web pages
- **`Invoke-RestMethod`** (PowerShell) or **`curl`**
  for the GitHub REST API

Check tool availability in order and use the first
that works.

## Workflow

### Phase 1: Identify the Failure

Parse user input for:

- `pr=` — PR number or URL
- `run=` — Actions run ID or URL
- `job=` — job name filter (e.g., `gcc.no-rtti.test`)
- `port=` — port name hint (optional)
- `mode=` — `diagnose` (read-only) or `fix` (default)

If the user gives a PR URL or number:

1. Fetch PR checks/status to find failing runs.
2. Fetch the failing job logs.

If the user gives a run ID or URL:

1. Fetch the run's job list.
2. Filter by `job=` if provided, otherwise pick all
   failed jobs.
3. Fetch the failing job logs.

### Phase 2: Fetch Logs

#### Option A: `gh` CLI

```bash
# List failed jobs in a run
gh run view <run-id> --repo atframework/cmake-toolset

# Get specific job log
gh run view <run-id> --repo atframework/cmake-toolset \
  --log-failed
```

#### Option B: GitHub REST API

```powershell
# List jobs for a workflow run
$owner = "atframework/cmake-toolset"
$base = "https://api.github.com/repos/$owner"
Invoke-RestMethod `
  "$base/actions/runs/<run-id>/jobs" |
  Select-Object -ExpandProperty jobs |
  Where-Object { $_.conclusion -eq "failure" } |
  Select-Object name, conclusion, html_url

# Download job log (needs auth token)
Invoke-RestMethod `
  "$base/actions/jobs/<job-id>/logs" `
  -Headers @{
    Authorization = "Bearer $env:GITHUB_TOKEN"
  }
```

#### Option C: `fetch_webpage`

Use `fetch_webpage` with the job URL from the Actions
UI to read the log output directly.

### Phase 3: Diagnose the Failure

Parse the log output and classify the failure:

| Pattern | Likely Cause |
| ------- | ------------ |
| `error: patch failed` / `git apply` error | Patch no longer applies cleanly |
| `Unknown CMake command` / option error | Deprecated or renamed build option |
| `fatal error: … not found` | Missing dependency or include order |
| `undefined reference` / link error | ABI or library mismatch |
| `FAILED: … test` | Runtime test regression |
| `Could not find … package` | `find_package` failure, version mismatch |
| Cross-compile host tool error | Host-tool not built or not found |

Record:

- failing job name and platform
- exact error message(s)
- which port and version is involved
- which patch file (if any) was being applied

### Phase 4: Fix the Port

Based on diagnosis, apply the appropriate fix:

#### Patch failure

Follow
[patch-workflow.md](../port-upgrade/references/patch-workflow.md):

1. Clone the target upstream version into
   `test/third_party/packages/`.
2. Test if the existing patch applies:
   `git apply --check <patch>`.
3. If it fails, inspect the conflict and create a new
   patch for the target version.
4. If cross-compiling patch, test `.cross.patch`
   separately.
5. Clean up `test/third_party/packages/` afterward.

#### Deprecated build option

Follow
[deprecated-options.md](../port-upgrade/references/deprecated-options.md):

1. Identify the removed/renamed option from upstream
   changelog or CMake files.
2. Add version-conditional logic in the port cmake
   file.

#### Dependency or include-order issue

1. Check `test/CMakeLists.txt` for correct include
   order.
2. Check upstream `MODULE.bazel` / `CMakeLists.txt`
   for changed dependency pins.
3. Update the port's version pin or dependency order.

#### Cross-compilation failure

Follow
[cross-compilation.md](../port-upgrade/references/cross-compilation.md).

### Phase 5: Verify the Fix

1. If the fix is a patch, test it locally:

   ```bash
   cd test/third_party/packages/<port>-<version>
   git apply --check <new-patch>
   ```

2. Review `test/CMakeLists.txt`,
   `.github/workflows/build.yaml`, and `ci/do_ci.*`
   for related job combinations that may be affected.
3. Summarize: what failed, root cause, files changed,
   and any remaining risks.

## Important Rules

- **Pre-commit formatting is mandatory.** Before
  committing, run `cmake-format -i` on every modified
  `.cmake`, `.cmake.in`, and `CMakeLists.txt` file
  (excluding `test/third_party/` and
  `test/build_jobs_*/`). Alternatively run
  `bash ci/format.sh` to format the entire tree.
  CI will reject unformatted files.
- **Always fetch actual logs.** Do not guess the
  failure cause from the job name alone.
- **Match the exact failing platform and compiler.**
  A fix for GCC may not apply to MSVC or
  cross-compile jobs.
- **Reuse existing patches** when the same-minor
  patch still applies. Only create a new patch file
  when content actually differs.
- **Test `.cross.patch` separately** from normal
  patches.
- **Clean up** `test/third_party/packages/` after
  patch testing.
- **Do not remove repository-specific guards** (RTTI,
  exceptions, compiler-version, backend exclusions)
  when fixing a build failure — they encode real
  compatibility constraints.
