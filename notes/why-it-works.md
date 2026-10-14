# What the research says, and what it doesn't

The design choices in this kit, and the sources behind them. Citations were checked against the
sources in October 2026. Research in this area moves fast, so recheck a number before you lean
on it.

## Claude Code treats CLAUDE.md as guidance it may not follow

Claude Code delivers `CLAUDE.md` as a user message, not as system configuration, and its docs say
there's no guarantee of strict compliance, especially for vague or conflicting instructions. The
same docs suggest keeping each file **under 200 lines**.
([Claude Code memory docs](https://code.claude.com/docs/en/memory))

That's why the curator asks "can this be a mechanism?" before writing a rule as prose. A check
script or a hook holds whatever the model decides.

## More rules, quieter failures

- **Independent rules degrade slowly with count.** In IFScale, many models stayed above 90%
  adherence at 50 instructions, and the strongest reasoning models held up past 150.
  ([arXiv:2507.11538](https://arxiv.org/abs/2507.11538))
- **The failures are silent.** IFScale found models mostly *omit* instructions rather than visibly
  break them, by more than 30 to 1 at high instruction counts. A rule that looks like it's working
  may simply never have been tested.
- **Rules that interact break much sooner.** When constraints stack on each other, FollowBench
  found models top out at about two or three levels.
  ([arXiv:2310.20410](https://arxiv.org/abs/2310.20410))
- **Saying "A beats B" doesn't make it so.** Models don't reliably follow a declared priority
  between conflicting instructions ([Control Illusion, arXiv:2502.15851](https://arxiv.org/abs/2502.15851)),
  and they rarely tell you they spotted a conflict
  ([ConInstruct, arXiv:2511.14342](https://arxiv.org/abs/2511.14342)).

So the cap matters, but what matters more is how many rules have to be weighed against each other.
That's why the curator asks "does this need arbitrating against a rule already here?", and why
a tiebreaker goes at the point of conflict, not in a priority list.

The cap itself (1,050 words, 30 rules) is a working ceiling from one person's use, not a number
any of this research produced. One May 2026 study found no measurable adherence effect from file
size at all ([arXiv:2605.10039](https://arxiv.org/abs/2605.10039)). Treat the cap as a forcing
function for pruning, not a law.

## Merge, prune, and never rewrite in one pass

- **Grow, then refine.** The ACE framework keeps a context useful by adding in small pieces and
  regularly de-duplicating ([arXiv:2510.04618](https://arxiv.org/abs/2510.04618)). A 2026 memory
  study found de-duplication was the dominant mechanism in keeping memory quality up
  ([arXiv:2605.08538](https://arxiv.org/abs/2605.08538)).
- **Whole-file rewrites destroy things.** ACE traced one rewrite that shrank a context from 18,282
  tokens to 122 and dropped task accuracy from 66.7% to 57.1% in a single step. Hence the
  curator's one-change-at-a-time rule.

## Files that never get updated

A study of 100 repos with agent instruction files found 24% had never been updated after they
were first generated, and 91% had at least one common defect: restating what a linter already
enforces, files over 200 lines, or file paths with no reason to open them.
([arXiv:2606.15828](https://arxiv.org/abs/2606.15828)) A regular sync is the fix for the first;
`bin/check.sh` and the curator's rules cover the rest.

## Why the global file stays human-approved

Memory and context poisoning is on OWASP's Top 10 for Agentic Applications, as ASI06: an agent that
edits its own persistent instructions can write in a bad rule that then shapes every later
session. ([OWASP GenAI](https://genai.owasp.org)) That's why the weekly sweep can file guides on
its own but has to propose global changes and wait for a yes.

## Guides load only when needed

Rules in `~/.claude/rules/` with `paths:` frontmatter load only when Claude works on matching
files, and symlinked shared rules are a documented pattern
([Claude Code memory docs](https://code.claude.com/docs/en/memory)). Guides go one step further:
they cost nothing until the global file's pointer tells Claude to open them. That only works if
the pointer says *when*. A bare path tends to get ignored.

## Possibly new here

I found no prior work that prunes instructions using a per-rule record of "did this rule
actually fire" (`notes/rule-audits.log`). The closest work tunes against overall task scores. That
comes from one search, not a systematic review, so treat it as a hunch.
