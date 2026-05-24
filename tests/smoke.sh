#!/usr/bin/env bash
#
# Context Engineering Kit smoke tests.
#
# These tests exercise install, doctor, and upgrade in temporary projects.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/cek-smoke.XXXXXX")"

cleanup() {
  rm -rf "$TMP_ROOT"
}
trap cleanup EXIT

pass() {
  printf 'OK: %s\n' "$1"
}

run_doctor() {
  local target="$1"
  "$ROOT_DIR/doctor.sh" "$target" >/dev/null
}

solo_project="$TMP_ROOT/solo project"
team_project="$TMP_ROOT/team project"
upgrade_solo="$TMP_ROOT/upgrade solo"
upgrade_team="$TMP_ROOT/upgrade team"

mkdir -p "$solo_project" "$team_project" "$upgrade_solo" "$upgrade_team"

"$ROOT_DIR/install.sh" "$solo_project" >/dev/null
run_doctor "$solo_project"
"$ROOT_DIR/install.sh" "$solo_project" >/dev/null
run_doctor "$solo_project"
pass "solo install is idempotent and doctor passes before /init-context"

"$ROOT_DIR/install.sh" --team --user alice "$team_project" >/dev/null
run_doctor "$team_project"
"$ROOT_DIR/install.sh" --team --user alice "$team_project" >/dev/null
run_doctor "$team_project"
pass "team install is idempotent and doctor uses team memory paths"

"$ROOT_DIR/install.sh" "$upgrade_solo" >/dev/null
python3 - "$upgrade_solo/.cek" <<'PY'
import json
import sys

path = sys.argv[1]
with open(path, encoding="utf-8") as f:
    data = json.load(f)
data["version"] = "0.0.0"
with open(path, "w", encoding="utf-8") as f:
    json.dump(data, f, separators=(",", ":"))
    f.write("\n")
PY
printf 'y\n' | "$ROOT_DIR/upgrade.sh" "$upgrade_solo" >/dev/null
run_doctor "$upgrade_solo"
pass "solo upgrade updates old .cek version"

"$ROOT_DIR/install.sh" --team --user alice "$upgrade_team" >/dev/null
rm -f "$upgrade_team/memory/shared/experiments.md"
rm -f "$upgrade_team/memory/alice/experiments.md"
python3 - "$upgrade_team/.cek" <<'PY'
import json
import sys

path = sys.argv[1]
with open(path, encoding="utf-8") as f:
    data = json.load(f)
data["version"] = "0.0.0"
with open(path, "w", encoding="utf-8") as f:
    json.dump(data, f, separators=(",", ":"))
    f.write("\n")
PY
printf 'y\n' | "$ROOT_DIR/upgrade.sh" "$upgrade_team" >/dev/null
test -f "$upgrade_team/memory/shared/experiments.md"
test -f "$upgrade_team/memory/alice/experiments.md"
run_doctor "$upgrade_team"
pass "team upgrade restores missing shared and personal memory templates"

pass "smoke tests completed"
