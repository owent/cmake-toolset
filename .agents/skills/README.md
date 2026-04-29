# Skills (Agent Playbooks)

This folder contains subproject workflows that agents load on demand. Keep `AGENTS.md` small; put task-specific steps,
commands, caveats, and examples here.

## Contents

| Skill | Description |
| --- | --- |
| `port-upgrade/` | Upgrade ports, resolve dependency pins, and validate patches |
| `ci-fix-port/` | Diagnose and fix CI failures after port or patch changes |
| `ai-agent-maintenance/` | Audit and optimize AI agent prompts, bridge files, and skills |

## When to read what

- If you are upgrading a port or dependency pin: start with `port-upgrade/SKILL.md`.
- If CI fails after a port or patch change: start with `ci-fix-port/SKILL.md`.
- If you are updating AI agent prompts or skills: see `ai-agent-maintenance/SKILL.md`.

## Maintenance rules

- Folder name and frontmatter `name` must match.
- `description` is the discovery surface: start with `Use when:` and include concrete trigger words.
- Keep each `SKILL.md` focused; move bulky examples or reference material into sibling files when needed.
