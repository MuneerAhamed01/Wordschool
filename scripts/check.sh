#!/usr/bin/env bash
# Compact checks: prints only problems and one summary line per step, so a
# run costs a few lines of output instead of hundreds.
#   scripts/check.sh            analyze + structure rules + all Flutter tests
#   scripts/check.sh test/foo   analyze + tests under a path
#   scripts/check.sh --fn       also ruff + pytest in functions/
set -uo pipefail
cd "$(dirname "$0")/.."

fn=0; paths=()
for arg in "$@"; do
  if [[ $arg == --fn ]]; then fn=1; else paths+=("$arg"); fi
done

status=0
# The 6 accepted pre-PSC issues (CW-009) are filtered out; anything else is shown.
known='colors.dart:75|game_page.dart:114|glowing_bulb.dart:18|wordle_tile/tile.dart:3|tile_mixin.dart:23'
analyze=$(fvm flutter analyze --no-pub 2>&1)
issues=$(grep -E ' • ' <<<"$analyze" | grep -vE "$known")
if [[ -n $issues ]]; then echo "$issues"; status=1; fi
echo "analyze: $(grep -cE ' • ' <<<"$issues" || true) new issue(s) ($(tail -1 <<<"$analyze"))"

structure=$(python3 scripts/check_structure.py) || { status=1; echo "$structure" | head -40; }
tail -1 <<<"$structure"

tests=$(fvm flutter test --no-pub --timeout 60s -r failures-only "${paths[@]}" 2>&1)
if ! grep -q 'All tests passed' <<<"$tests"; then status=1; echo "$tests" | cut -c1-240 | tail -60; fi
echo "tests: $(tail -1 <<<"$tests" | grep -oE '\+[0-9]+.*' | tr -s ' ')"

if [[ $fn == 1 ]]; then
  (cd functions && venv/bin/ruff check -q . && venv/bin/ruff format --check -q . \
    && venv/bin/pytest -q 2>&1 | tail -1) || status=1
fi
exit $status
