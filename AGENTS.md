# cmake-toolset Agent Guide

This is the canonical, cross-agent guide for this subproject. Keep it short: put repeatable workflows in
`.agents/skills/*/SKILL.md`, and keep `.github/copilot-instructions.md` / `CLAUDE.md` as lightweight bridges.

**cmake-toolset** is a CMake-based third-party dependency toolkit for fetching, patching, building, and installing
upstream libraries across platforms and toolchains.

- **Repository**: <https://github.com/atframework/cmake-toolset>
- **Languages**: CMake plus shell/PowerShell CI helpers

## Project Map

- `ports/`: standard ports, import aggregators, orchestrators, patches, and cross-compiling host assets.
- `modules/`: reusable CMake helper modules.
- `test/`: integration coverage and canonical include order.
- `ci/`, `.github/workflows/`: validated CI entrypoints and platform wrappers.
- `.agents/skills/`: port upgrade, CI-failure, and AI-agent maintenance playbooks.

## Always-On Rules

- Respect the user's dirty workspace: inspect current file contents before editing and avoid unrelated reformatting.
- Read the matching `.agents/skills/*/SKILL.md` before port upgrade, patch, dependency, or CI-failure work.
- Treat `ports/Configure.cmake`, `test/CMakeLists.txt`, `.github/workflows/build.yaml`, `ci/do_ci.*`, and upstream repo
  metadata as source of truth; do not rely on historical dependency chains alone.
- Before committing CMake edits, run `cmake-format -i` on modified `.cmake`, `.cmake.in`, and `CMakeLists.txt` files
  (excluding `test/third_party/` and `test/build_jobs_*/`), or run `bash ci/format.sh` for the whole tree.

## CMake Conventions

- Use 2-space indentation, lowercase function names, uppercase variables, `if(TARGET ...)`, and `echowithcolor()` for
  user-facing messages.
- Standard ports usually follow: `include_guard`, import macro, `find_package`, `project_third_party_port_declare`,
  patch lookup, then `find_configure_package`.
- Treat `ssl/port.cmake`, `grpc/import.cmake`, and `protobuf/protobuf.cmake` as special cases.
- Patch names are `{port}-{version}.patch` or `{port}-{version}.cross.patch`; same-minor matching picks the highest
  version `<=` target.
- Use `project_third_party_check_build_shared_lib()` for shared/static selection; do not hardcode `BUILD_SHARED_LIBS`
  directly in ports.

## Skill Routing

Read the matching `.agents/skills/*/SKILL.md` before specialized work:

| Skill | Use when |
| --- | --- |
| `port-upgrade` | Upgrading ports, resolving pins, validating patches, or reviewing CI impact |
| `ci-fix-port` | Diagnosing or fixing CI failures after port or patch changes |
| `ai-agent-maintenance` | Auditing or optimizing AI agent prompts, bridge files, and skills |

## Agent File Compatibility

- `AGENTS.md` is canonical for tools that support hierarchical agent instructions.
- `.github/copilot-instructions.md` exists only to point VS Code Copilot at this guide and `.agents/skills/`.
- `CLAUDE.md` exists only to point Claude-compatible tools at this guide and `.agents/skills/`.
- Keep skill folder names and frontmatter `name` values identical; descriptions are the discovery surface.
