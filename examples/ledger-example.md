# Example ledger

> Invented for illustration. This is the shape of what the curator reports after a sync, so you
> know what you're reading the first time. Yours will name your own rules and files.

**Source:** a session building a billing dashboard · 17 candidates: 1 added, 3 into a new guide,
2 merged, 10 rejected, 1 flagged to mechanize

**Added**
- `global/CLAUDE.md:22`: "Ask before installing a new dependency; name what it replaces."
- `guides/customer-writing.md`: new guide. Three candidates shared one situation, which is the
  minimum for a guide.

**Merged into existing**
- "Re-run the tests after a fix" → sharpened the seed *Verify before claiming it's done* (added
  "the test that failed, not just the build"). Seed tag removed: it's been applied twice now.
- "Don't guess API field names" → folded into *Never state a fact stronger than you have it*.

**Rejected** (10)
- "Use the staging database for the demo": project-specific → that project's `CLAUDE.md`.
- "Prefer tables over bullet lists": one session's taste, no repeat → logged.
- "Be concise": default model behavior; costs words, changes nothing.
- 7 more, each with its reason in `notes/rejected-candidates.log`.

**Pruned**
- Seed *Push back*: cut. Four audits, never named. If you miss it, it'll come back with evidence.
- Trimmed guide `guides/code-review.md` (the curator rereads one older guide each sync): two
  rules merged into one; one cut because the linter already enforces it.

**Mechanized** (better as a hook or script than as a rule)
- "Run the type check before committing" → flagged **Mechanize**: belongs in the project's own
  pre-commit hook. The flag names the project and the setting; nothing goes into a guide.

**Check:** PASS · global 612 / 1,050 words · 21 / 30 rules

---

What to read first: **Rejected**. The reasons tell you more about your setup than the additions
do. If one is wrong, say so on your next sync and the curator will reconsider it with your reason.
