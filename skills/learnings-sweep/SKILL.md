---
name: learnings-sweep
description: Use only when started by the scheduled job from bin/schedule-sweep, or when the operator explicitly asks for a background learnings sweep. For an interactive sync, use sync-learnings instead.
---

# Learnings sweep (scheduled, no conversation)

The weekly version of `/sync-learnings`. Nobody is in this session, so you draft from files
instead of from a conversation, the curator files what it can, and the operator gets a report.
The repo is the clone `~/.claude/CLAUDE.md` links into (`readlink -f`, two levels up).

**What you can't see:** the rule audit's best signal is a live session explaining why it broke a
rule. You don't have that, so your audit will be thin. Say so in the report rather than
inventing reasons. A manual `/sync-learnings` after a heavy session still beats this sweep.

## 1. Find what changed since the last sweep

The last sweep's date is in the newest `notes/reports/*-<hostname -s>.md` (this machine's;
none means look back 7 days).
- Memory files under `~/.claude/projects/*/memory/` modified since then. Feedback-type memories
  matter most. The folder name tells you the project.
- `git log --since=<date>` in each of those projects, where it's a repo. Don't decode the
  folder name into a path (hyphens make it ambiguous); read the `cwd` field from the newest
  `.jsonl` in that project folder. Look for the same kind of fix made more than once.
- Skip anything already in `notes/rejected-candidates.log`.

## 2. Draft candidates

Same three-line format as `sync-learnings` Step 1 (Learning / Evidence / Suggested home), with
the project named in Evidence so the report can group by source. Write the rule audit from what
the files show, marking every entry `(inferred from files)`. An empty list is fine: write a
one-line report and stop.

## 3. Dispatch the curator

Send the list with the words `SCHEDULED RUN`. In that mode the curator may edit guides, skills,
and notes, but any change to `global/CLAUDE.md` goes to `inbox/proposed-global.md` for the
operator to approve. Unattended edits to the always-on file are how a bad rule spreads to every
session before anyone reads it.

## 4. Write the report

`notes/reports/<YYYY-MM-DD>-<hostname -s>.md`, short enough to read in two minutes:
- **What shifted this week**, grouped by project.
- **Filed**: the curator's ledger, unchanged.
- **Waiting on you**: each proposed global change, quoted in full, or "nothing".
- **Gone quiet**: rules no audit has named in the last four reports.
- **Blind spots**: what this sweep couldn't see (machines it didn't run on, thin audit).

Commit the report with the curator's changes. If the repo has a remote, `git fetch` and
rebase first, then push. On a rebase conflict, abort, leave the commit local, and say so at the
top of the report. Never force-push.
