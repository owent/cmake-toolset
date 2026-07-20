---
name: ai-agent-maintenance
description: "Use when: auditing or optimizing AI agent prompts, bridge files, skills, SKILL.md metadata, and cross-tool compatibility."
---

# AI Agent Maintenance

Use this skill when updating AI-agent guidance for this repository or subproject.

## Required Outcomes

- Deeply research the current prompt/skill layout and current AI-agent customization practices before editing.
- Keep always-on guidance compact, actionable, and non-redundant.
- Preserve compatibility across AGENTS-aware tools, VS Code Copilot, Codex, Claude Code, Kilo Code/CLI, Zoo Code, Pi,
  and OpenCode where the repository intentionally supports them.
- Discover the current harness's actual capabilities before writing tool-specific guidance; never document features
  that another tool has but the target tool does not.
- Keep this repository independent from parent or sibling repository prompt files.
- Keep all checked-in AI guidance in this repository English-only.
- Merge improvements into existing prompt and skill content; do not leave old versions, migration notes, changelog notes,
  or historical comparison sections.

## Compatibility Model

- Prefer `AGENTS.md` as the canonical repository or subproject guide; nested `AGENTS.md` files should be specific to the
  subtree they govern.
- Do not maintain `.github/copilot-instructions.md`, `.github/prompts/*.prompt.md`, or
  `.github/instructions/*.instructions.md` copies when `AGENTS.md` and `.agents/skills/` cover the same rules.
- Keep `CLAUDE.md` as a thin Claude Code bridge that imports `AGENTS.md` and the skills index with `@...` references.
- Keep `.clinerules` as a lightweight compatibility bridge that points to `AGENTS.md` and local skills.
- Keep repeatable workflows in `.agents/skills/<name>/SKILL.md`; bridge files should not duplicate full skill bodies.
- Do not create or restore `.claude/skills` mirrors; Claude-compatible tools should use the canonical guide and local
  `.agents/skills` content.
- For Zoo Code, Kilo, Pi, and OpenCode compatibility, preserve the `AGENTS.md` path first. Add tool-specific files
  (`.roo/rules/`, `.kilo/`, `.pi/`, `opencode.json`) only when the repository already uses them or the task explicitly
  asks for tool-specific config, and keep them thin diffs that link the shared rules.
- Zoo Code is the community continuation of the discontinued Roo Code. Its official config paths still
  use historical `.roo*` names (`.roo/rules/`, `.roorules`, `roo-cline.*` settings); do not rename them to `.zoo*`.
  Zoo reads `AGENTS.md` directly, so this repository needs no Zoo-specific files.
- Pi reads `AGENTS.md`/`CLAUDE.md` and `.agents/skills/`; use `.pi/SYSTEM.md` or `APPEND_SYSTEM.md` only for
  system-prompt overrides. Pi's core ships no subagents, plan mode, MCP, or permission gates — those arrive via
  extensions or packages, so shared guidance must state goals and constraints without assuming them, and plans belong
  in files rather than a built-in plan mode.
- Tool compatibility facts are volatile: verify them against current official docs before changing guidance, and keep
  verified conclusions in [references/tool-compatibility-sources.md](references/tool-compatibility-sources.md).

## Procedure

1. **Research first**
   - Read the nearest `AGENTS.md`, `CLAUDE.md`, `.clinerules`, `.agents/skills/README.md`, and any relevant `SKILL.md`
     files before editing. Read legacy `.github` AI customization files only when migrating or deleting them.
   - If compatibility behavior may change, re-verify the volatile entries in
     `references/tool-compatibility-sources.md` against current official docs or maintained references for the
     affected tools, and update that index with the new conclusion and the reason for the change.
   - Respect dirty workspaces: preserve unrelated user or formatter edits and avoid broad reformatting.

2. **Choose the right surface**
   - Put facts that apply to nearly every task in `AGENTS.md`.
   - Put path-specific rules in `AGENTS.md` or skill reference files when they need to be reusable across tools.
   - Put multi-step, task-specific, or rarely used guidance in skills.
   - Put invocation templates and argument parsing directly in the relevant `.agents/skills/<name>/SKILL.md`.
   - Prefer links to existing docs or skills over copying long reference material into always-on prompts.

3. **Write compact, discoverable skills**
   - Keep skill folder names and frontmatter `name` values identical; use lowercase hyphenated names.
   - Quote descriptions that contain colons and start them with `Use when:` plus concrete trigger words.
   - Front-load the most important trigger phrases; some tools truncate skill descriptions in listings.
   - Keep each `SKILL.md` focused. Move bulky examples, scripts, or reference material into sibling files when needed.

4. **Validate before finishing**
   - Check markdown/frontmatter diagnostics for changed prompt and skill files.
   - Run a scoped whitespace check for changed prompt and skill files.
   - Confirm no redundant `.github` AI customization files or `.claude/skills` mirrors remain.
   - Confirm this repository's AI guidance stays English-only.
   - Re-read representative files to ensure bridge files stay thin and skill routing points to the current skill.
   - For nested Git repositories, run status and whitespace checks from each affected repository root.

5. **Summarize clearly**
   - Report the files changed, compatibility surfaces preserved, and validations run.
   - Call out skipped build/test work when the change is documentation-only.
