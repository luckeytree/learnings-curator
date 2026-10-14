---
name: sync-learnings
description: Use when the operator asks to sync learnings, when several corrections or new working patterns have piled up in a session, or when closing out a project. Also the first thing to run after installing learnings-curator.
---

# Sync learnings into the learnings-curator repo

Sweep this session's durable learnings back into the operator's portable setup repo (find the
local clone with `readlink -f ~/.claude/CLAUDE.md`, two levels up), via the **curator** agent.

The split of labor: **you** (the main session) know what was actually learned, so you draft the
candidates. The **curator** owns judgment and the repo: placement, merging, pruning, committing.
You're also the session that just learned these things, which makes you the worst judge of what's
worth keeping. Report what you saw and let the curator rule. Don't edit the repo directly from
this skill, and don't pre-reject: deciding what's already covered takes fresh eyes on the whole
repo, which is the curator's entire job.

## Step 0: Which run is this?

- **First run** if `notes/rule-audits.log` holds no entries (only `#` comment lines). Do the
  migration below instead of Steps 1–3, then the schedule offer.
- **Pending proposals** if `inbox/proposed-global.md` exists: a scheduled sweep wants to change
  the global file and is waiting on the operator. Show it first, get a yes or no on each item,
  and pass the answers to the curator with this run's list.
- Otherwise, a normal run: Steps 1–4.

## First run: the migration

A new install has no session history worth mining, but it usually has instruction files that
grew without anyone pruning them. Those are the first candidates.

1. **Measure the before.** Find what the operator already has:
   - The old global file: `bin/link` moved it to `~/.claude/pre-curator-backup/<timestamp>/CLAUDE.md`.
     None there means there wasn't one.
   - Project `CLAUDE.md` files. The reliable list of projects is the `cwd` field in each
     `~/.claude/projects/*/*.jsonl` (newest file per folder). Check each for a `CLAUDE.md`. Show
     the list and let the operator drop any before you read them.
   - Memory folders under `~/.claude/projects/*/memory/`: count files per folder.

   Report a short table: words and rule count (lines starting `- `) for each file, memory file
   counts, and any rule that appears in three or more places. "Before" means the old global file.
2. **Draft every rule in the old global file as a candidate**, plus any rule found in three or
   more places. For these, one line each is enough: `old global L12 · <the rule> · suggested
   home`. Don't cut any yourself; that's the curator's job.
3. **Dispatch the curator** with the list, the measurements, the project paths, and the words
   `FIRST RUN`.
4. **Relay the ledger** with before and after numbers (global words and rules, old file vs. now,
   against the cap) and where the backup is. Then work through the ledger's two hand-off lists
   with the operator:
   - **Needs your call:** conflicts the curator settled provisionally. Ask about each one; pass
     any reversal back to the curator.
   - **Route to project:** rules that belong to one project. **A project rule that lived only in
     the old global file stops loading after install until it lands in its project's
     `CLAUDE.md`.** Show each project file and the lines going into it, and on the operator's
     yes, append them. Also offer to remove project-file copies of rules that are now in the
     global file.
5. **Hand over the Mechanize flags** as a short to-do list per project (the check, and where it
   goes), and offer to wire one in now.
6. **Push** (Step 4 below), then **offer the schedule**. Say it in about these words:
   > Your first sync is done. From here you can keep running `/sync-learnings` by hand, or I can
   > schedule a weekly sweep that reads your memory folders and git history, lets the curator file
   > what it finds, and leaves you a report. Changes to your global file always wait for your yes.
   > It costs about one curator run's worth of tokens a week.
   > You can still run `/sync-learnings` any time, either way. Want the weekly sweep?

   On yes, **before scheduling, make sure they know how it runs.** It's their computer's own
   scheduler, not a service, so it only runs if the machine is on and awake at that moment. Say
   so plainly, then ask which day and time they're usually at this machine with the lid open
   (late in the workday works well). Tell them:
   - **Laptop closed or asleep:** on a Mac it runs when the machine next wakes, possibly in the
     middle of something. **Shut down:** that week is skipped. On Linux, asleep or off means
     skipped.
   - It uses their normal Claude login and usage. An expired login or a used-up usage window
     means a failed run (they get a notification saying so).
   - It only sees this machine's memory folders, so each machine they use needs its own schedule.
   - Corporate network security can cut off long runs.

   Then run `SWEEP_WEEKDAY=<0-6, 0 = Sunday> SWEEP_HOUR=<0-23> bin/schedule-sweep` with their
   answer and show its output. Mention `bin/schedule-sweep --status`, which shows when it last
   ran, so a skipped week is visible. On no, say how to turn it on later.

## Step 1: Draft the candidate list (you)

Mine five sources:
1. This conversation: corrections the operator made, approaches they confirmed, friction that
   recurred.
2. The project's memory directory (feedback-type memories especially).
3. The project's `CLAUDE.md`: conventions that turned out to be general, not project-specific.
4. Git history: repeated fix patterns (the same kind of revert or sweep more than once).
5. The repo's own rules in contact with this session: skim `global/CLAUDE.md` and the guide
   nearest the work, and note which rules were **applied** (shaped behavior unprompted),
   **violated** (broken, then corrected), or stayed **silent** (never relevant).

For each candidate, write three lines:
- **Learning:** the generalized rule (strip project specifics: roles, not names).
- **Evidence:** what happened that taught it (one line).
- **Suggested home:** where you'd guess it goes. A guess, not a verdict; the curator decides.

End the list with a **Rule audit**: three short lines (applied / violated / silent), naming
specific rules. Each **violated** entry carries two things: the reasoning you were running on at
the moment you broke it, quoted word for word, and your answer to *how could the rule have been
written so I'd have followed it?* "It was clear, I chose otherwise" needs a tiebreaker or a gate;
"it should have said X" needs a reword. A handful of honest datapoints beats a complete
inventory. This is the curator's only usage signal; without it, pruning runs on taste.
(The violated-rule format borrows the "baseline the excuse, then write against it" method from
obra/superpowers `writing-skills`, MIT.)

Include the borderline ones. A candidate you suspect is already covered goes on the list with why
you suspect it. Leave off only facts about this one project (those go to project memory) and
mechanics of this one conversation. An empty list is a valid outcome: say so and stop.

## Step 2: Dispatch the curator

Send the curator agent the candidate list and rule audit verbatim, plus the project name and the
path to the project's memory directory. Running this skill is the operator's authorization for
this one subagent. Don't spawn others.

## Step 3: Relay

Return the curator's ledger (added / merged / rejected / pruned / mechanized / global count) to
the operator unchanged. Point out anything rejected as project-specific so it can go in the
project's own `CLAUDE.md` or memory instead. If the ledger flags anything **Mechanize**, wire
that check into this project's validator or hooks; that's your half.

## Step 4: Push

If the repo has a remote, `git push` the curator's commit. Triggering the sync is the
authorization. A commit that stays local is a sync that reached one machine.
