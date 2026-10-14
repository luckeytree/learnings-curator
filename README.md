# Learnings Curator

A starter kit for keeping your Claude Code instructions small, current, and yours.

Most instruction files only grow. Every correction becomes a new rule, nobody removes the old
ones, and you stop knowing which rules are doing anything. Claude Code's docs suggest keeping
each file under 200 lines, and rules that conflict with each other cause more trouble than rule
count alone.

This kit adds one role to fix that: a **curator**. Your working sessions suggest what they
learned, and the curator decides what stays. It merges, rejects, and prunes so your global file
(`~/.claude/CLAUDE.md`) stays under a cap: 1,050 words and 30 rules by default, which is my
working ceiling, not a measured limit. The idea underneath: **the thing that adds rules should
not be the thing that decides whether they stay.**

**Who it's for:** Claude Code users whose global file has grown past the point where they know
what's in it. **First step:** click **Use this template**, run `bin/link`, then `/sync-learnings`
(details in [Start here](#start-here)).

## How it works

```
   you work; Claude gets corrected, finds patterns, breaks rules
                  │
       ┌──────────┴───────────────────────────┐
       ▼                                      ▼
  /sync-learnings  (you run it)          weekly sweep  (optional)
  drafts candidates + a rule audit       drafts from memory + git
       │                                      │
       └──────────────────┬───────────────────┘
                          ▼
                     the curator
     admission test: every session? one situation? one project?
     merges, rejects with reasons, prunes what goes unused,
     checks the budget, commits
                          │
       ┌──────────────────┼───────────────────┐
       ▼                  ▼                   ▼
  global/CLAUDE.md    guides/             notes/
  always loaded,      opened when the     rejection log, audit log,
  capped              work calls for it   sweep reports
```

The weekly sweep can file guides on its own, but changes to your global file wait for your
yes.

Two parts do the work:
- **`/sync-learnings`** runs in the session that learned something. It drafts a list of
  candidate rules and a short audit of which existing rules it followed, broke, or never
  needed. It doesn't decide anything.
- **The curator** reads the whole repo fresh and runs the **admission test** on each candidate
  (the three questions in the diagram): goes in the global file, goes in a guide, belongs to one
  project, or gets dropped. Every rejection is logged with its reason, so the same idea doesn't
  get argued twice.

The audit is what makes pruning honest. A rule that no session has followed or broken across
several syncs gets cut, and the audit log shows why. The audit is Claude's own account of what it
did, so treat it as a signal, and expect it to miss things.

## Is this for you?

Paste this repo's link into Claude Code and ask whether it would help. Claude can read your
current instruction files and tell you how bloated they are. Signs it will help:
- Your `~/.claude/CLAUDE.md` is long, and you're not sure what half of it does.
- The same rule appears in several projects' `CLAUDE.md` files.
- You correct Claude on the same thing across different projects.
- You work on more than one machine and your setup drifts between them.

If your instruction file is twenty lines and working, you probably don't need this yet.

## Start here

1. **Make your own copy.** On GitHub, click **Use this template** and make the new repo
   **private**: it will fill up with how you work. Clone it anywhere.
2. **Install it.** From the clone:
   ```
   bin/link
   git config core.hooksPath hooks
   ```
   `bin/link` symlinks the repo into `~/.claude/`, so pulling the repo updates your live setup.
   It never deletes anything. If you already have a `~/.claude/CLAUDE.md` (or an agent or skill
   with the same name), it moves it to `~/.claude/pre-curator-backup/<timestamp>/` first.
   The second line turns on the budget check before every commit.
3. **Read `global/CLAUDE.md`.** It starts with six seed rules, tagged `(seed)`, that hold for
   almost anyone. Delete any that are wrong for you.
4. **Run your first sync.** Open Claude Code in any project and run `/sync-learnings`.

## Your first sync

The first run is a migration. You don't have session history yet, but you probably have
instruction files, and those are the first candidates.

1. Claude measures what you have: your old global file (from the backup), your project
   `CLAUDE.md` files, and your memory folders. You get a short table of words, rule counts, and
   rules that show up in three or more places.
2. Every rule in your old global file goes to the curator as a candidate.
3. The curator rules on each one. **Expect most to move down or out.** An old global file
   usually mixes project rules, things the model already does, and near-duplicates. Moving those
   out is the point.
4. You get a ledger (a plain list of what was added, merged, rejected, and cut) and before/after
   numbers. Read the rejections first; their reasons teach you
   more about your setup than the additions do. [`examples/ledger-example.md`](examples/ledger-example.md)
   shows what one looks like.
5. Claude offers to schedule a weekly sweep (the same curator run, on a timer; details below).
   Say yes or no; you can change it any time.

Your backup stays where `bin/link` put it. Nothing from it is lost; it's been sorted.

## After that: by hand, weekly, or both

**By hand.** Run `/sync-learnings` when you've corrected Claude on the same thing more than once,
or when a project wraps up. Not every session. A sync reads the whole repo, so it takes a few
minutes. Doing it yourself also keeps you close to what changed and why.

**Weekly.** `bin/schedule-sweep` sets up a background sweep on this machine (Fridays 3pm by
default; see the script's header to change it). It reads your memory folders and git history
from the past week, lets the curator file what it finds, and writes a short report to
`notes/reports/`. Two limits on purpose:
- **It never edits your global file.** Changes there go to `inbox/proposed-global.md`, and your
  next `/sync-learnings` asks you about each one. That file rides on every session, so a bad rule
  there spreads everywhere before anyone reads it.
- **It can't see why a session broke a rule.** Only the live session knows that. After a heavy
  session, a manual sync still catches more.

`bin/schedule-sweep --status` shows whether it's on. `--remove` turns it off. Each machine reads
only its own memory folders, so run it on every machine you use. `bin/run-sweep` runs one now.

**Cost.** In my own use, a curator run took 1 to 5 million tokens, mostly cache reads, about 2
to 7% of the tokens in the session it followed. A weekly sweep has no session to compare against;
expect one curator run's worth of tokens a week. Your numbers will differ with repo size.

## What's in here

```
global/CLAUDE.md          Your global file. Always loaded. Capped. Starts with six seed rules.
guides/                   Rules for one kind of work, opened when it comes up. Starts empty.
skills/sync-learnings/    /sync-learnings: drafts candidates from a live session (and the first-run migration)
skills/learnings-sweep/   The scheduled version: drafts from memory and git history
agents/curator.md         Judges, merges, prunes, and commits. Read this one first.
rules/repo-hygiene.md     Loads only while you're editing instruction files
bin/link                  Installs by symlink; backs up anything in the way
bin/check.sh              The budget and integrity check (the pre-commit hook runs it)
bin/schedule-sweep        Turns the weekly sweep on or off for this machine
bin/run-sweep             Runs one sweep now
notes/                    Rejection log, rule-audit log, sweep reports, why-it-works.md
inbox/                    Proposed global changes waiting for you
examples/                 A sample guide and a sample ledger. Not loaded.
```

## Make it yours

Everything here is meant to be changed.
- **The caps** are at the top of `bin/check.sh`. 1,050 words and 30 rules is a working ceiling
  from one person's use, not a measured threshold. [`notes/why-it-works.md`](notes/why-it-works.md)
  covers what the research says, including that rules colliding matters more than rule count.
- **The curator's judgment** lives in `agents/curator.md`. If it keeps rejecting things you
  want, change the admission test there (the three questions in the diagram), not one rule at a
  time.
- **Seed rules**: the curator cuts any that no sync ever names.

## Requirements

Claude Code, git, and bash. macOS or Linux. On Windows (Git Bash), turn on Developer Mode and
set `MSYS=winsymlinks:nativestrict` before running `bin/link`, or the links quietly become
copies. `bin/link` warns if that happens. The weekly sweep isn't set up for Windows.

## Credits

Started by Leighton Luckey. Some ideas came from others' work, with sources noted where they're
used: the rule-writing method in `skills/sync-learnings` borrows from
[obra/superpowers](https://github.com/obra/superpowers) (MIT). MIT licensed; see `LICENSE`.
