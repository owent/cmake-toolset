# Tool Compatibility Source Index

Verified sources behind this repository's cross-tool guidance. Re-verify volatile entries against the official
source before relying on them; when a conclusion changes, update this file with the new conclusion and the reason,
and delete superseded rows instead of keeping history. Last full verification: 2026-07-20.

| Topic | Source | Current conclusion | Re-verify when |
| --- | --- | --- | --- |
| `AGENTS.md` standard | <https://agents.md/> | `AGENTS.md` is the cross-tool canonical guide; nested files scope to their subtree. | Editing compatibility rules |
| Agent Skills standard | <https://agentskills.io/> and `/specification` | A skill is a directory with `SKILL.md`; `name` must match the folder; `description` drives discovery; load bodies on demand. | Creating or editing skills |
| Zoo Code (Roo continuation) | <https://docs.zoocode.dev/roo-to-zoo-migration>; <https://docs.zoocode.dev/features/custom-instructions> | Roo Code is discontinued and merged back into Cline; Zoo Code continues the VS Code extension and migrates settings via export/import. Official config paths remain `.roo/rules/`, `.roo/rules-{mode}/`, `.roorules`, and `roo-cline.*` settings; Zoo auto-loads workspace-root `AGENTS.md`/`AGENT.md` (`roo-cline.useAgentRules`, default on). | Any Zoo/Roo compatibility work |
| Pi harness | <https://pi.dev/>; <https://github.com/earendil-works/pi> (`packages/coding-agent`) | Pi loads `AGENTS.md`/`CLAUDE.md` from `~/.pi/agent/`, parent dirs, and cwd; system prompt override is `.pi/SYSTEM.md` or `APPEND_SYSTEM.md`; skills live in `.agents/skills/` or `.pi/skills/`. Core has no subagents, plan mode, MCP, or permission gates; those are extensions/packages. Audit third-party packages: they run with full system access. | Any Pi compatibility work |
| Superpowers methodology | <https://github.com/obra/superpowers> | Composable skills enforce: brainstorm and approve the design before code, write plans as small verifiable tasks, RED-GREEN-REFACTOR TDD, two-stage review (spec conformance then code quality), verify with evidence before finishing. Do not install it here without user approval; absorb the discipline into local rules instead. | Updating change-discipline rules |
| OpenSpec (OPSX) | <https://github.com/Fission-AI/OpenSpec>; `docs/opsx.md` | OPSX is the standard workflow: fluid actions (`propose`, `explore`, `apply`, `update`, `sync`, `archive`; expanded profile adds `new`, `continue`, `ff`, `verify`). `openspec/specs/` holds current truth; `openspec/changes/<name>/` holds the authoritative proposal/delta-specs/design/tasks contract. Update the same change while intent holds; start a new change when intent or most of the scope shifts. This repository has not adopted OpenSpec; do not initialize it without user approval. | Adopting or referencing OpenSpec |

Maintenance rules:

- Record only current conclusions, never dated version snapshots; note the verification date once at the top.
- Treat AI-tool compatibility, Superpowers, and OpenSpec as volatile: re-check before related tasks and during
  periodic maintenance, then refresh this index in the same change.
