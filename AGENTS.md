# cmake-toolset Agent Guide

This is the canonical, self-contained cross-agent guide for this repository. Keep it short: put repeatable workflows in
`.agents/skills/*/SKILL.md`, keep `CLAUDE.md` and `.clinerules` as lightweight bridges, and avoid redundant
tool-specific prompt copies. This repository manages its own AI agent prompts and skills; it must not depend on a parent
or sibling repository guide. All checked-in AI guidance in this repository must be English-only.

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
- `.agents/skills/port-upgrade/references/`: on-demand port, patch, test, and CI maintenance references.

## Always-On Rules

- Respect the user's dirty workspace: inspect current file contents before editing and avoid unrelated reformatting.
- Read the matching `.agents/skills/*/SKILL.md` before port upgrade, patch, dependency, or CI-failure work.
- Treat `ports/Configure.cmake`, `test/CMakeLists.txt`, `.github/workflows/build.yaml`, `ci/do_ci.*`, and upstream repo
  metadata as source of truth; do not rely on historical dependency chains alone.
- For edits under `ports/`, `test/CMakeLists.txt`, `ci/do_ci.*`, `.github/workflows/*.yaml`, or patch files, also follow
  `.agents/skills/port-upgrade/references/repository-maintenance-guidelines.md`.
- Before committing CMake edits, run `cmake-format -i` on modified `.cmake`, `.cmake.in`, and `CMakeLists.txt` files
  (excluding `test/third_party/` and `test/build_jobs_*/`), or run `bash ci/format.sh` for the whole tree.

## Task Triage

Match process intensity to risk:

| Task type | Default process |
| --- | --- |
| Small, well-bounded edit (docs, comments, formatting, single-file tweak) | Read the nearest rules, make the minimal change, run the matching check |
| Defect fix | Reproduce and find the root cause first, add a failing regression test, apply the minimal fix, verify the original symptom |
| New feature, behavior change, cross-module refactor, or CI/contract change | Agree on a written design contract before implementing, then follow the change discipline below |

## Change Discipline

For non-trivial changes (third triage row):

- Clarify intent, scope, and acceptance criteria first. Do not code from an ambiguous request, and never record the
  agent's own guesses as approved requirements.
- Write the agreed plan to a file with small, independently verifiable tasks (exact paths, expected outcome, how to
  verify). Keep one authoritative artifact per change; link to it instead of copying it into chat, docs, or issues.
- Implement test-first when practical: write the failing test, watch it fail, implement the minimum to pass, then
  refactor.
- Review in two stages: conformance to the agreed plan, then code quality. Fix plan-level deviations by updating the
  plan artifact, not by silently rewriting both plan and code.
- When reality diverges from the plan, update the same artifact while intent holds; start a fresh one only when
  intent or most of the scope changed.
- Declare completion only with evidence: the tests, lint, and builds you claim actually ran.

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
| `ai-agent-maintenance` | Auditing or optimizing AI agent prompts, bridge files, skills, and cross-tool compatibility |

## Agent File Compatibility

- `AGENTS.md` is canonical for tools that support hierarchical agent instructions.
- Do not maintain `.github/copilot-instructions.md`, `.github/prompts/*.prompt.md`, or
  `.github/instructions/*.instructions.md` AI customization copies when `AGENTS.md` and `.agents/skills/` cover the same
  rules. Keep `.github/workflows/*.yaml` because those files are real CI configuration.
- `CLAUDE.md` exists only to point Claude-compatible tools at this guide and `.agents/skills/`.
- `.clinerules` exists only as a lightweight compatibility bridge for tools that read it.
- Zoo Code (the community continuation of Roo Code) reads this `AGENTS.md` directly. Its official config paths still
  use historical `.roo*` names (`.roo/rules/`, `.roorules`, `roo-cline.*` settings); do not rename them to `.zoo*`,
  and do not add Zoo-specific files here.
- Pi reads `AGENTS.md`/`CLAUDE.md` and `.agents/skills/`. Its core has no subagents, plan mode, or MCP, so shared
  guidance must state goals and constraints without assuming harness-specific features.
- Do not create or restore `.claude/skills` mirrors; local skills live under `.agents/skills/`.
- Keep skill folder names and frontmatter `name` values identical; descriptions are the discovery surface.
