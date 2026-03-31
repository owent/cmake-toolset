# Patch Workflow

## Patch Matching Logic

The `project_third_party_try_patch_file()` macro in
`ports/Configure.cmake` matches patches as follows:

1. **Exact match**: Look for
   `{PORT_PREFIX}-{VERSION}.patch`
   (e.g., `grpc-v1.80.0.patch`)
2. **Minor version fallback**: Strip the last `.X`
   segment to get MINOR_VERSION, then glob
   `{PORT_PREFIX}-{MINOR_VERSION}*.patch`
3. **Best match selection**: Among glob results, pick
   the highest version that is `<=` the target version
   (using `VERSION_LESS_EQUAL`)

### Examples

| Target | Available Patches | Selected |
| ------ | ----------------- | -------- |
| v1.9.5 | v1.9, v1.9.4 | v1.9.4 |
| v1.9.4 | v1.9, v1.9.4 | v1.9.4 |
| v1.9.3 | v1.9, v1.9.4 | v1.9 |
| v1.22.0 | v1.18 | No match |

**Key insight**: Patches only match within the same
minor version prefix. A `v1.18` patch does NOT match
`v1.22`. When the minor version changes, a new patch
file is required if the fix is still needed.

## Cross-Compilation Patches

Files ending in `.cross.patch` are checked first when
`CMAKE_CROSSCOMPILING` is true. If found, they are
used instead of the regular patch. Test them as a
separate validation path.

## Testing Patches Against New Versions

### Step-by-step

The command snippets below are Bash examples. On
Windows, use the equivalent PowerShell commands.

```bash
# 1. Clone the new version
cd test/third_party/packages
git clone --depth 1 --branch <tag> <git-url> <name>
cd <name>

# 2. Test if existing patch applies
git apply --check /path/to/existing.patch

# 3a. If it applies cleanly
git apply /path/to/existing.patch
git diff > /path/to/new-version.patch

# 3b. If it fails — analyze failures
git apply --verbose /path/to/existing.patch 2>&1
# Check which hunks fail and why

# 4. Clean up
cd ..
rm -rf <name>
```

### When to Create a New Patch

Create a new version-specific patch when:

- The minor version changed (e.g., `v1.18` to
  `v1.22`) and the fix is still needed
- The patch content differs from the existing
  lower-version patch (different line numbers,
  surrounding context changed)

Do NOT create a new patch when:

- The version is within the same minor prefix and
  the existing patch applies cleanly
- The upstream incorporated all fixes from the patch

### Analyzing If Fixes Are Upstream

For each hunk in the patch, search the new version's
source for:

1. The exact change the patch makes — is it already
   present?
2. The problem the patch fixed — is it resolved
   differently?

Common patterns that get upstreamed:

- `cmake_minimum_required` version range syntax fixes
- Missing `#include` directives
- Compiler warning fixes

Patterns that rarely get upstreamed:

- `BUILD_SHARED_LIBS` support additions
- Warning-as-error (`/WX`, `-Werror`) removal
- Include path ordering (`BEFORE PUBLIC`)
- Cross-compilation workarounds

### Manual Patch Creation

When automatic application fails due to code
restructuring:

1. Read the old patch to understand what it fixes
2. Find the equivalent code in the new version
3. Apply changes manually using file editing tools
4. Generate the patch with
   `git diff > new-version.patch`
5. Verify: reset, re-apply, confirm it works

```bash
git checkout -- .
git apply --check new-version.patch
```
