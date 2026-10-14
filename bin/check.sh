#!/usr/bin/env bash
# Repo self-check for learnings-curator: the budgets the curator enforces, as machinery.
# Run from anywhere: bin/check.sh  ·  bin/check.sh --install  ·  exit 1 = a gate failed.
set -uo pipefail
shopt -s nullglob
cd "$(dirname "$0")/.." || exit 1

# --- Budgets -------------------------------------------------------------------
# global/CLAUDE.md rides on every prompt of every session. The cost is attention, not tokens.
# These caps are a working ceiling, not a measured threshold. Rules colliding costs more than
# rule count (notes/why-it-works.md). Counted in WORDS and RULES, not lines,
# because lines measure wrapping and a reflow would buy room the rules never earned.
# Change them if your experience says otherwise. That's your call, not the curator's.
GLOBAL_WORDS=1050
GLOBAL_RULES=30
# Without this, the rule cap stops binding: rules get packed into fewer, fatter bullets, and the
# collisions move inside them where no one sees them.
BULLET_WORDS=60
# Guides are opened situationally. Soft: past this, ask the split question.
SITUATIONAL_WORDS=1400
# The curator's charter and the loop's skills load whenever they run, and the curator never
# budgets itself. Soft: past this, the charter is due a prune like any other file.
MACHINERY_WORDS=2200

fail=0; warn=0
red()  { printf '\033[31m%s\033[0m\n' "$*"; }
yell() { printf '\033[33m%s\033[0m\n' "$*"; }
ok()   { printf '\033[32m%s\033[0m\n' "$*"; }
# Whitespace tokens via awk, not wc -w: GNU wc under LC_ALL=C skips a standalone dash and
# undercounts. The gate must not depend on locale.
words() { awk '{n+=NF} END{print n+0}' "$1"; }

# --- --install: every live ~/.claude path the repo ships must resolve back into it --------
if [ "${1:-}" = "--install" ]; then
  repo="$(pwd -P)"; bad=0
  CH="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
  paths=("$CH/CLAUDE.md")
  for a in agents/*.md; do paths+=("$CH/$a"); done
  for r in rules/*.md;  do paths+=("$CH/$r"); done
  for d in skills/*/;   do paths+=("$CH/${d%/}"); done
  for p in "${paths[@]}"; do
    if [ ! -e "$p" ] && [ ! -L "$p" ]; then red "  MISSING      $p"; bad=1; continue; fi
    if [ ! -L "$p" ]; then red "  NOT A LINK   $p (a real file is shadowing the repo)"; bad=1; continue; fi
    t=$(cd "$(dirname "$p")" && cd "$(dirname "$(readlink "$p")")" 2>/dev/null && pwd -P)
    case "$t/" in "$repo"/*) : ;; *) red "  WRONG TARGET $p -> $(readlink "$p")"; bad=1 ;; esac
  done
  [ "$bad" -eq 0 ] && ok "install OK: every live path resolves into this repo"
  exit "$bad"
fi

# --- 1. Hard budget: global/CLAUDE.md -------------------------------------------------
echo "== global/CLAUDE.md budget =="
gw=$(words global/CLAUDE.md)
gr=$(grep -cE '^[[:space:]]*-[[:space:]]' global/CLAUDE.md | tr -d ' ')
printf '   words %4s / %s\n   rules %4s / %s\n' "$gw" "$GLOBAL_WORDS" "$gr" "$GLOBAL_RULES"
[ "$gw" -gt "$GLOBAL_WORDS" ] && { red "   FAIL over word budget by $((gw-GLOBAL_WORDS)): a new rule must displace or absorb a weaker one"; fail=1; }
[ "$gr" -gt "$GLOBAL_RULES" ] && { red "   FAIL over rule budget by $((gr-GLOBAL_RULES)): merge, don't append"; fail=1; }
# Per-bullet: a bullet runs from its "- " line through indented continuation lines.
fat=$(awk -v cap="$BULLET_WORDS" '
  function flush() { if (n > cap) printf "   line %d: %d words: %s...\n", start, n, head; n = 0 }
  /^[[:space:]]*-[[:space:]]/ { flush(); start = NR; n = NF - 1; head = substr($0, 1, 50); next }
  /^[[:space:]]+[^[:space:]]/ && n > 0 { n += NF; next }
  { flush() }
  END { flush() }' global/CLAUDE.md)
[ -n "$fat" ] && { red "   FAIL bullets over ${BULLET_WORDS} words: split them or cut them"; red "$fat"; fail=1; }
[ "$fail" -eq 0 ] && ok "   within budget"

# --- 2. Soft budget: guides and path-scoped rules ---------------------------------------
echo
echo "== situational files (soft ${SITUATIONAL_WORDS}w) =="
n=0
for f in guides/*.md rules/*.md; do
  [ "$(basename "$f")" = "README.md" ] && continue
  n=$((n+1)); w=$(words "$f")
  if [ "$w" -gt "$SITUATIONAL_WORDS" ]; then
    yell "$(printf '   %-40s %5sw  ask the split question' "$f" "$w")"; warn=$((warn+1))
  else
    printf '   %-40s %5sw\n' "$f" "$w"
  fi
done
[ "$n" -eq 0 ] && echo "   (no guides yet: the curator creates them as learnings arrive)"

echo
echo "== the loop's own files (soft ${MACHINERY_WORDS}w) =="
for f in agents/*.md skills/*/SKILL.md; do
  w=$(words "$f")
  if [ "$w" -gt "$MACHINERY_WORDS" ]; then
    yell "$(printf '   %-40s %5sw  the curator is due its own prune' "$f" "$w")"; warn=$((warn+1))
  else
    printf '   %-40s %5sw\n' "$f" "$w"
  fi
done

# --- 3. Dangling relative links ---------------------------------------------------------
echo
echo "== link integrity =="
# A function, not inline in $( ): macOS's bash 3.2 can't parse a case statement there.
scan_links() {
  find . -name '*.md' -not -path './.git/*' | while IFS= read -r f; do
    d=$(dirname "$f")
    grep -oE '\]\([^)]+\)' "$f" 2>/dev/null | sed -e 's/^](//' -e 's/)$//' | while IFS= read -r t; do
      case "$t" in http*|\#*|mailto:*|"") continue;; esac
      p="${t%%#*}"; [ -z "$p" ] && continue
      [ -e "$d/$p" ] || echo "   BROKEN $f -> $t"
    done
  done
}
broken=$(scan_links)
if [ -n "$broken" ]; then red "$broken"; fail=1; else ok "   no dangling relative links"; fi

# --- 4. Frontmatter on skills and agents ------------------------------------------------
echo
echo "== frontmatter =="
fmbad=0
for f in skills/*/SKILL.md agents/*.md; do
  head -1 "$f" | grep -q '^---$' || { red "   $f: missing opening ---"; fmbad=1; }
  sed -n '2,10p' "$f" | grep -q '^name:' || { red "   $f: missing name:"; fmbad=1; }
  sed -n '2,10p' "$f" | grep -q '^description:' || { red "   $f: missing description:"; fmbad=1; }
  case "$f" in skills/*)
    dir=$(basename "$(dirname "$f")")
    nm=$(sed -n '2,10p' "$f" | grep '^name:' | head -1 | sed 's/^name:[[:space:]]*//')
    [ "$dir" = "$nm" ] || { red "   $f: name '$nm' != directory '$dir'"; fmbad=1; }
  ;; esac
done
[ "$fmbad" -eq 0 ] && ok "   all skills and agents well-formed" || fail=1

# --- 5. Rules carry paths: (else they load on every session, outside the budget) --------
echo
echo "== path-scoped rules =="
for f in rules/*.md; do
  if sed -n '1,12p' "$f" | grep -q '^paths:'; then
    printf '   %-40s scoped\n' "$f"
  else
    red "   $f: no paths: frontmatter, so it loads on every session and spends the global budget"; fail=1
  fi
done

# --- Verdict ----------------------------------------------------------------------------
echo
if [ "$fail" -ne 0 ]; then red "FAIL: fix the above before committing."; exit 1; fi
[ "$warn" -gt 0 ] && yell "PASS with $warn soft-budget note(s)." || ok "PASS"
exit 0
