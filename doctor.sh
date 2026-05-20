#!/usr/bin/env bash
#
# Context Engineering Kit - project health checker
#
# Usage:
#   ./doctor.sh                    check current directory
#   ./doctor.sh /path/to/project   check target project
#
set -u

TARGET_DIR="$(cd "${1:-.}" 2>/dev/null && pwd)"
if [ -z "${TARGET_DIR:-}" ]; then
  echo "ERROR: target directory does not exist: ${1:-.}"
  exit 2
fi

WARN_DAYS="${CEK_STALE_DAYS:-7}"

errors=0
warnings=0

info() { echo "INFO: $1"; }
ok() { echo "OK: $1"; }
warn() { warnings=$((warnings + 1)); echo "WARN: $1"; }
fail() { errors=$((errors + 1)); echo "FAIL: $1"; }

exists_file() {
  local rel="$1"
  if [ -f "$TARGET_DIR/$rel" ]; then
    ok "$rel exists"
  else
    fail "$rel is missing"
  fi
}

exists_dir() {
  local rel="$1"
  if [ -d "$TARGET_DIR/$rel" ]; then
    ok "$rel/ exists"
  else
    fail "$rel/ is missing"
  fi
}

date_to_epoch() {
  local value="$1"
  if date -j -f "%Y-%m-%d" "$value" "+%s" >/dev/null 2>&1; then
    date -j -f "%Y-%m-%d" "$value" "+%s"
    return
  fi
  if date -d "$value" "+%s" >/dev/null 2>&1; then
    date -d "$value" "+%s"
    return
  fi
  return 1
}

is_placeholder_file() {
  local path="$1"
  grep -Eq "_（|\\[日期\\]|YYYY-MM-DD|YYYY-MM|\\[决策标题\\]|\\[原因 1\\]" "$path"
}

# Determine kit directory (look for VERSION relative to this script)
SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "$0" 2>/dev/null || echo "$0")")" && pwd)"
KIT_VERSION="$(tr -d '[:space:]' < "$SCRIPT_DIR/VERSION" 2>/dev/null || echo "unknown")"

echo "Context Engineering Kit doctor"
echo "Target: $TARGET_DIR"
echo ""

# 检测模式
CEK_FILE="$TARGET_DIR/.cek"
CEK_MODE="solo"
CEK_USER=""
if [ -f "$CEK_FILE" ]; then
  CEK_MODE="$(grep -o '"mode":"[^"]*"' "$CEK_FILE" | head -1 | cut -d'"' -f4 || echo "solo")"
  CEK_USER="$(grep -o '"user":"[^"]*"' "$CEK_FILE" | head -1 | cut -d'"' -f4 || echo "")"
  [ -z "$CEK_MODE" ] && CEK_MODE="solo"
fi

if [ "$CEK_MODE" = "team" ]; then
  echo "Mode: team (user: ${CEK_USER:-unknown})"
else
  echo "Mode: solo"
fi
echo ""

echo "[1/8] Required files"
exists_file "CLAUDE.md"
exists_file "DECISIONS.md"
exists_file "TASKS.md"
if [ "$CEK_MODE" = "team" ]; then
  exists_file "memory/shared/current_state.md"
  exists_file "memory/shared/bugs.md"
  if [ -n "$CEK_USER" ]; then
    exists_file "memory/$CEK_USER/current_state.md"
  fi
else
  exists_file "memory/current_state.md"
  exists_file "memory/bugs.md"
fi
exists_dir "prompts"
echo ""

echo "[2/8] Claude Code commands"
exists_file ".claude/commands/init-context.md"
exists_file ".claude/commands/start.md"
exists_file ".claude/commands/wrap.md"
echo ""

echo "[3/8] Cross-tool agent entry"
if [ -f "$TARGET_DIR/AGENTS.md" ]; then
  ok "AGENTS.md exists"
else
  warn "AGENTS.md is missing; Codex and other repo-instruction tools may lack a clear entry point"
fi
echo ""

echo "[4/8] Placeholder content"
for file in \
  "CLAUDE.md" \
  "DECISIONS.md" \
  "TASKS.md" \
  "memory/current_state.md" \
  "prompts/common/coding_rules.md" \
  "prompts/typescript/style_guide.md" \
  "prompts/python/style_guide.md"; do
  path="$TARGET_DIR/$file"
  if [ -f "$path" ]; then
    if is_placeholder_file "$path"; then
      warn "$file still appears to contain placeholder text"
    else
      ok "$file does not look like a raw placeholder"
    fi
  fi
done
echo ""

echo "[5/8] memory/current_state.md freshness"
if [ "$CEK_MODE" = "team" ]; then
  state_file="$TARGET_DIR/memory/shared/current_state.md"
else
  state_file="$TARGET_DIR/memory/current_state.md"
fi
if [ -f "$state_file" ]; then
  last_update="$(grep -E "_?最后更新: [0-9]{4}-[0-9]{2}-[0-9]{2}" "$state_file" | tail -1 | grep -Eo "[0-9]{4}-[0-9]{2}-[0-9]{2}" || true)"
  if [ -z "$last_update" ]; then
    warn "memory/current_state.md has no parsable last update date"
  else
    now_epoch="$(date "+%s")"
    update_epoch="$(date_to_epoch "$last_update" || true)"
    if [ -z "${update_epoch:-}" ]; then
      warn "memory/current_state.md last update date is not parseable: $last_update"
    else
      age_days=$(( (now_epoch - update_epoch) / 86400 ))
      if [ "$age_days" -gt "$WARN_DAYS" ]; then
        warn "memory/current_state.md is $age_days days old; run /wrap after work sessions"
      else
        ok "memory/current_state.md updated $age_days days ago"
      fi
    fi
  fi
fi
echo ""

echo "[6/8] DECISIONS.md duplicate IDs"
decisions_file="$TARGET_DIR/DECISIONS.md"
if [ -f "$decisions_file" ]; then
  duplicate_ids="$(grep -E "^## D[0-9]{3,}" "$decisions_file" | sed -E "s/^## (D[0-9]+).*/\\1/" | sort | uniq -d || true)"
  if [ -n "$duplicate_ids" ]; then
    fail "duplicate decision IDs: $(echo "$duplicate_ids" | tr '\n' ' ')"
  else
    ok "no duplicate decision IDs"
  fi
fi
echo ""

echo ""
echo "[7/8] Kit version"
if [ -f "$CEK_FILE" ]; then
  installed_version="$(grep -o '"version":"[^"]*"' "$CEK_FILE" | head -1 | cut -d'"' -f4 || true)"
  if [ -z "$installed_version" ]; then
    warn ".cek exists but version field not found"
  elif [ "$KIT_VERSION" = "unknown" ]; then
    info "installed version $installed_version, kit version unknown (running outside kit directory)"
  elif [ "$installed_version" = "$KIT_VERSION" ]; then
    ok "kit version $installed_version (latest)"
  else
    warn "installed version $installed_version, latest is $KIT_VERSION — run upgrade.sh"
  fi
else
  warn ".cek not found — kit version unknown, reinstall or run install.sh to create it"
fi
echo ""

echo "[8/8] Team mode"
if [ "$CEK_MODE" = "team" ]; then
  exists_file "memory/TEAM.md"
  exists_dir "memory/shared"
  if [ -n "$CEK_USER" ]; then
    exists_dir "memory/$CEK_USER"
  else
    warn "team mode but no user set in .cek"
  fi
  if [ -f "$TARGET_DIR/.gitignore" ]; then
    if grep -q "memory/\*/" "$TARGET_DIR/.gitignore" 2>/dev/null; then
      ok ".gitignore has personal memory exclusion rules"
    else
      warn ".gitignore missing personal memory exclusion rules (memory/*/  !memory/shared/)"
    fi
  else
    warn ".gitignore not found — personal memory files will be tracked"
  fi
  if [ -f "$TARGET_DIR/.gitattributes" ]; then
    if grep -q "merge=union" "$TARGET_DIR/.gitattributes" 2>/dev/null; then
      ok ".gitattributes has merge strategies"
    else
      warn ".gitattributes missing merge strategies for append-only files"
    fi
  else
    warn ".gitattributes not found — no merge strategies for team files"
  fi
else
  info "solo mode — team checks skipped"
fi
echo ""

if [ "$errors" -gt 0 ]; then
  echo "Result: $errors error(s), $warnings warning(s)"
  exit 1
fi

echo "Result: 0 errors, $warnings warning(s)"
exit 0
