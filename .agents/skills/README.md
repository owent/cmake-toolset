# Skills (Agent Playbooks)

This folder contains subproject workflows that agents load on demand. Keep `AGENTS.md` small; put task-specific steps,
commands, caveats, and examples here.

## Contents

| Skill | Description |
| --- | --- |
| `testing/` | Use when designing, reviewing, registering, or running CTest/configure/link-smoke coverage |
| `port-upgrade/` | Use when upgrading ports, resolving dependency pins, validating patches, or reviewing CI impact |
| `ci-fix-port/` | Use when diagnosing and fixing CI failures after port or patch changes |
| `ai-agent-maintenance/` | Use when auditing and optimizing AI agent prompts, bridge files, skills, and compatibility |

## When to read what

- If you are designing, reviewing, registering, or running tests: start with `testing/SKILL.md`.
- If you are upgrading a port or dependency pin: start with `port-upgrade/SKILL.md`.
- If CI fails after a port or patch change: start with `ci-fix-port/SKILL.md`.
- If you are updating AI agent prompts or skills: see `ai-agent-maintenance/SKILL.md`.

## Maintenance rules

- Folder name and frontmatter `name` must match.
- `description` is the discovery surface: start with `Use when:` and include concrete trigger words.
- Keep each `SKILL.md` focused; move bulky examples or reference material into sibling files when needed.
