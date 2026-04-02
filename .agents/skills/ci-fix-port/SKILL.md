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
(remote may be `owent/cmake-toolset`)

## Prerequisites

The agent needs access to GitHub data. Try these
sources **in order** and use the first that works:

1. **GitHub MCP tools** (`mcp_github_*`) — search
   for `mcp_github` with `tool_search_tool_regex`
2. **`gh` CLI** — run `gh --version` to test
3. **GitHub REST API (unauthenticated)** — works for
   public repos, job metadata and annotations; log
   download needs a token
4. **`fetch_webpage`** — read job HTML pages or API
   JSON directly

> **Fallback strategy:** When log download returns
> 403 or "Sign in to view logs", switch to the
> indirect diagnosis methods in Phase 3 instead of
> retrying. Do not waste time on blocked endpoints.

## Workflow

### Phase 1: Identify the Failure

Parse user input for:

- `pr=` — PR number or URL
- `run=` — Actions run ID or URL
- `job=` — job name filter (e.g., `gcc.no-rtti.test`)
- `port=` — port name hint (optional)
- `mode=` — `diagnose` (read-only) or `fix` (default)

If no input is given, auto-detect:

1. Check the current branch and its remote tracking.
2. Find the latest PR targeting `main` from that
   branch, or the latest CI run on that branch.
3. Use `fetch_webpage` with the GitHub API:
   ```
   https://api.github.com/repos/{owner}/{repo}/actions/runs?branch={branch}&per_page=5
   ```

**Gather job data:**

1. Fetch the run's job list via API:
   ```
   /actions/runs/{run_id}/jobs?per_page=30
   ```
2. Classify each job by `status` and `conclusion`.
3. For failed jobs, record: name, duration
   (`started_at` to `completed_at`), runner labels.
4. Also fetch the **last successful run on `main`**
   for the same jobs — this confirms whether the
   failure is a regression.

### Phase 2: Fetch Logs

Try to get actual log text using the methods below.
If all fail, proceed to Phase 3 with indirect methods.

#### Option A: `gh` CLI

```bash
gh run view <run-id> --repo owent/cmake-toolset \
  --log-failed
```

#### Option B: GitHub REST API (authenticated)

```powershell
Invoke-RestMethod `
  "$base/actions/jobs/<job-id>/logs" `
  -Headers @{
    Authorization = "Bearer $env:GITHUB_TOKEN"
  }
```

#### Option C: Check-run annotations

Even without log access, annotations contain error
summaries:
```
/repos/{owner}/{repo}/check-runs/{job-id}/annotations
```
These are usually just "Process completed with exit
code 1" but occasionally contain cmake error lines.

#### Option D: `fetch_webpage` on job HTML

```
https://github.com/{owner}/{repo}/actions/runs/{run_id}/job/{job_id}
```
Note: This often returns "Sign in to view logs" for
private repos or when unauthenticated.

#### Efficient Log Reading

CI logs are very large. The build pipeline outputs
**all port build logs first**, then prints the
failing port's `CMakeConfigureLog.yaml` at the end.
Do not read the entire log sequentially — this
wastes context and tokens. Instead:

1. **Search for error locations first.** Use
   `Select-String` (PowerShell) or `grep` to find
   lines containing `error`, `FAILED`,
   `fatal error`, `CMake Error`, or
   `ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CI_MODE`
   in the downloaded log file.
2. **Read targeted sections** around the matched
   error positions (e.g., 50–100 lines of context
   before and after each error hit).
3. **Check the tail first** — the last 200–500 lines
   often contain the `CMakeConfigureLog.yaml` dump
   and the final error summary, which are the most
   diagnostic.
4. **Skip successful port output.** If the error is
   in port X, skip the build logs for ports A–W
   that succeeded. Search for the port name to jump
   directly to its section.
5. When using `gh run view --log-failed`, the output
   is already filtered to failed steps, but can
   still be large. Apply the same search-first
   strategy.

### Phase 3: Diagnose the Failure

#### With logs available

Parse the log output and classify the failure:

| Pattern | Likely Cause |
| ------- | ------------ |
| `error: patch failed` / `git apply` error | Patch no longer applies cleanly |
| `Unknown CMake command` / option error | Deprecated or renamed build option |
| `fatal error: … not found` | Missing dependency or include order |
| `undefined reference` / link error | ABI or library mismatch |
| `FAILED: … test` | Runtime test regression |
| `Could not find … package` / `include could not find` | Config-package bug or `find_package` failure |
| Cross-compile host tool error | Host-tool not built or not found |
| `-lc++abi` / compiler not found | CI environment change (runner OS update) |

#### Without logs (indirect diagnosis)

When logs are inaccessible, use these strategies:

1. **Timing analysis** — classify failures by
   duration:
   - **< 2 min**: configuration/cmake error or CI
     script error (compiler detection, environment)
   - **2–10 min**: early build failure (first port
     fails to configure or compile)
   - **10–30 min**: late build failure (port compiles
     but linking or later port fails)
   - **> 30 min**: test failure or final link stage

2. **Platform grouping** — if all MSVC jobs fail but
   Linux passes, the issue is platform-specific.
   Similarly for macOS-only failures.

3. **BUILD_SHARED_LIBS grouping** — if shared jobs
   fail but static passes (or vice versa), the issue
   involves library type handling (config packages,
   DLL exports, etc.). Note: the actual shared/static
   decision per port is resolved by
   `project_third_party_check_build_shared_lib()` in
   `ports/Configure.cmake`:
   `${FULL_PORT_NAME}_USE_SHARED` > `_USE_STATIC` >
   `BUILD_SHARED_LIBS` / `ATFRAMEWORK_USE_DYNAMIC_LIBRARY`
   > default static. A port may be static even when
   `BUILD_SHARED_LIBS=ON` if its `_USE_STATIC` is set.

4. **Diff analysis** — compare `main..dev` changes:
   - Which ports were upgraded?
   - Which patches were added/modified?
   - Were CI scripts changed?
   - Were core modules (`ProjectBuildTools.cmake`,
     `FindConfigurePackage.cmake`) changed?

5. **Local reproduction** — the most powerful tool
   when logs are unavailable. Build the suspected
   port locally and test `find_package`:
   ```powershell
   # Example: test a port's config package
   cmake -S <upstream-src> -B build `
     -DBUILD_SHARED_LIBS=OFF `
     -DCMAKE_INSTALL_PREFIX=install
   cmake --build build --target install
   # Then test find_package:
   cmake -S test_project -B test_build `
     -DCMAKE_PREFIX_PATH=install
   ```

6. **CI script analysis** — read `ci/do_ci.sh` and
   `ci/do_ci.ps1` for the failing job's configuration.
   Check for:
   - Combined `-D` flags in a single quoted string
     (PowerShell bug)
   - Platform-specific detection logic (e.g., clang
     version loops on macOS)
   - Environment assumptions that may break with
     runner OS updates

7. **Compare with last main CI** — fetch the last
   successful `main` run's jobs to confirm the same
   jobs passed before. This isolates regressions
   from pre-existing flakiness.

Record for each failure:

- failing job name, platform, and runner labels
- failure duration (fast vs slow)
- exact error message (if available)
- which port and version is involved
- which patch file (if any) was being applied
- `BUILD_SHARED_LIBS` value for the job
- whether the same job passed on `main`

### Phase 4: Fix the Port

Based on diagnosis, apply the appropriate fix:

#### Config-package bug

This is a common issue when upstream cmake config
files (`<Pkg>Config.cmake`) have bugs:

1. Build the port locally with the same
   `BUILD_SHARED_LIBS` setting as the failing CI job.
2. Inspect the installed cmake config files
   (usually in `lib/cmake/<Pkg>/`).
3. Look for unconditional `include()` without
   `OPTIONAL`, missing target aliases, or assumptions
   about which components are installed.
4. Add fixes to the port's patch file — patch the
   upstream `*Config.cmake.in` template.
5. Test by running `find_package(<Pkg> REQUIRED)` in
   a minimal test cmake project.

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

#### CI environment issue

When the failure is caused by runner OS changes, not
port code:

1. Check the failing CI script section
   (`do_ci.sh` / `do_ci.ps1`) for the affected job.
2. Identify environment assumptions (e.g.,
   `-lc++abi` on macOS, versioned compiler binaries,
   SDK paths).
3. Add fallback logic to handle both old and new
   environments. For example:
   ```bash
   # Fallback: try without -lc++abi (macOS bundles
   # it into libc++)
   cmd1 || cmd1_without_abi || FAIL=1
   ```
4. Verify the fix doesn't break the corresponding
   Linux job that uses the same CI script section.

#### Cross-compilation failure

Follow
[cross-compilation.md](../port-upgrade/references/cross-compilation.md).

### Phase 5: Verify the Fix

1. If the fix is a patch, test it locally:
   ```bash
   cd test/third_party/packages/<port>-<version>
   git -c "core.autocrlf=input" apply --check <patch>
   ```

2. If the fix touches a config package, do a full
   local verification:
   - Build the port with the patched source
   - Install it to a temp prefix
   - Run `find_package()` in a test cmake project
   - Test with both `BUILD_SHARED_LIBS=ON` and `OFF`
     if both variants are used in CI

3. Review `test/CMakeLists.txt`,
   `.github/workflows/build.yaml`, and `ci/do_ci.*`
   for related job combinations that may be affected.

4. Clean up all local test artifacts:
   - `test/third_party/packages/<port>-*`
   - `test/build_*` temp directories

5. Summarize: what failed, root cause, files changed,
   and any remaining risks.

## Important Rules

- **Pre-commit formatting is mandatory.** Before
  committing, run `cmake-format -i` on every modified
  `.cmake`, `.cmake.in`, and `CMakeLists.txt` file
  (excluding `test/third_party/` and
  `test/build_jobs_*/`). Alternatively run
  `bash ci/format.sh` to format the entire tree.
  CI will reject unformatted files.
- **Always fetch actual logs first.** If unavailable,
  use indirect diagnosis (timing, platform grouping,
  local reproduction). Do not guess from job name.
- **Match the exact failing platform and compiler.**
  A fix for GCC may not apply to MSVC or
  cross-compile jobs.
- **Reuse existing patches** when the same-minor
  patch still applies. Only create a new patch file
  when content actually differs.
- **Test `.cross.patch` separately** from normal
  patches.
- **Clean up** `test/third_party/packages/` and any
  temp build directories after testing.
- **Do not remove repository-specific guards** (RTTI,
  exceptions, compiler-version, backend exclusions)
  when fixing a build failure — they encode real
  compatibility constraints.
- **Config packages are a common failure mode.** When
  `CMAKE_FIND_PACKAGE_PREFER_CONFIG=TRUE` is set
  (as in this repo), all `find_package` calls prefer
  config mode. Upstream `*Config.cmake` bugs surface
  immediately.
- **Always test patches with `core.autocrlf=input`**
  since the repo uses this setting.
- **Runner OS updates** can break CI scripts without
  any code changes. Always compare with the last
  successful main CI run to distinguish environment
  regressions from code regressions.
