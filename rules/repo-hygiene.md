---
paths:
  - "**/CLAUDE.md"
  - "**/AGENTS.md"
  - "**/.claude/rules/*.md"
  - "**/agents/*.md"
  - "**/skills/*/SKILL.md"
---

# You are editing agent instructions

Instruction files are context, not enforced configuration. Claude Code delivers them as a user
message, so nothing guarantees they're followed. Anything that must hold no matter what belongs
in a hook or a check script, not in sterner prose.

- **Be specific enough to verify.** "Use 2-space indentation" beats "format properly."
- **Don't restate what a linter, formatter, or check already enforces.** It's the most common
  defect in real instruction files, and it costs context every session.
- **Watch for contradictions.** Two rules that disagree get resolved arbitrarily. State the
  tiebreaker where they conflict; a global priority order doesn't work.
- **Don't state a guess as evidence.** A number inside a rule reads as a citation. Source it or
  say you inferred it.
- **A bare path gets ignored.** Never reference a file without saying why and when to open it.
- **A `description:` says when to load the file, not what its steps are.** A workflow summary in
  the frontmatter becomes the shortcut the model follows instead of reading the body.
- **Under 200 lines**, and shorter is better.
- Changes to the global setup go through `/sync-learnings` and the curator, never ad hoc.
