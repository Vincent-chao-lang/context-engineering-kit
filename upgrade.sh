#!/usr/bin/env bash
#
# Context Engineering Kit - 升级脚本
#
# 用法:
#   ./upgrade.sh                    升级当前目录
#   ./upgrade.sh /path/to/project   升级指定项目
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "$0" 2>/dev/null || echo "$0")")" && pwd)"
TARGET_DIR="$(cd "${1:-.}" 2>/dev/null && pwd)"
if [ -z "${TARGET_DIR:-}" ]; then
  echo "ERROR: target directory does not exist: ${1:-.}"
  exit 2
fi

KIT_VERSION="$(tr -d '[:space:]' < "$SCRIPT_DIR/VERSION" 2>/dev/null || echo "unknown")"

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

updated=()
added=()
skipped=()

cek_get() {
  local path="$1"
  local key="$2"
  local default="${3:-}"

  if [ ! -f "$path" ]; then
    printf '%s\n' "$default"
    return
  fi

  if command -v python3 >/dev/null 2>&1; then
    python3 - "$path" "$key" "$default" <<'PY'
import json
import sys

path, key, default = sys.argv[1:]
try:
    with open(path, encoding="utf-8") as f:
        data = json.load(f)
except (OSError, json.JSONDecodeError):
    print(default)
else:
    value = data.get(key, default)
    print(default if value is None else value)
PY
  else
    grep -o "\"$key\":\"[^\"]*\"" "$path" 2>/dev/null | head -1 | cut -d'"' -f4 || printf '%s\n' "$default"
  fi
}

cek_set_version() {
  local path="$1"
  local version="$2"

  if command -v python3 >/dev/null 2>&1; then
    python3 - "$path" "$version" <<'PY'
import json
import sys

path, version = sys.argv[1:]
with open(path, encoding="utf-8") as f:
    data = json.load(f)
data["version"] = version
with open(path, "w", encoding="utf-8") as f:
    json.dump(data, f, ensure_ascii=False, separators=(",", ":"))
    f.write("\n")
PY
  elif command -v sed >/dev/null 2>&1; then
    sed -i.bak "s/\"version\":\"[^\"]*\"/\"version\":\"$version\"/" "$path" 2>/dev/null && rm -f "$path.bak"
  else
    return 1
  fi
}

add_memory_templates() {
  local rel_dir="$1"
  local dest_dir="$TARGET_DIR/$rel_dir"
  local mem filename dest

  mkdir -p "$dest_dir"
  for mem in "$SCRIPT_DIR/templates/memory/"*.md; do
    [ -f "$mem" ] || continue
    filename="$(basename "$mem")"
    dest="$dest_dir/$filename"
    if [ ! -f "$dest" ]; then
      cp "$mem" "$dest"
      added+=("$rel_dir/$filename")
      echo -e "  ${GREEN}+${NC} $rel_dir/$filename (new)"
    else
      skipped+=("$rel_dir/$filename")
    fi
  done
}

echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"
echo -e "${CYAN}  Context Engineering Kit 升级器 v${KIT_VERSION}${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"
echo ""
echo "目标项目: $TARGET_DIR"
echo ""

# ---- 检查 .cek ----
CEK_FILE="$TARGET_DIR/.cek"
if [ ! -f "$CEK_FILE" ]; then
  echo -e "${RED}ERROR: .cek not found in target project${NC}"
  echo "Run install.sh first to initialize the project."
  exit 1
fi

OLD_VERSION="$(cek_get "$CEK_FILE" "version" "")"
if [ -z "$OLD_VERSION" ]; then
  echo -e "${RED}ERROR: cannot read installed version from .cek${NC}"
  exit 1
fi

if [ "$OLD_VERSION" = "$KIT_VERSION" ]; then
  echo -e "${GREEN}Already at version $KIT_VERSION. Nothing to do.${NC}"
  exit 0
fi

echo -e "升级: ${YELLOW}${OLD_VERSION}${NC} → ${GREEN}${KIT_VERSION}${NC}"
echo ""

# ---- 展示变更日志 ----
CHANGELOG="$SCRIPT_DIR/CHANGELOG.md"
if [ -f "$CHANGELOG" ]; then
  echo -e "${CYAN}变更日志:${NC}"
  echo "────────────────────────────────────────"
  # 显示从新版本标题到旧版本标题之间的内容
  awk -v old="## ${OLD_VERSION}" -v new="## ${KIT_VERSION}" '
    $0 ~ "^## " { in_range = 0 }
    $0 == new { in_range = 1; next }
    $0 == old { in_range = 0; next }
    in_range { print "  " $0 }
  ' "$CHANGELOG" | head -40
  echo "────────────────────────────────────────"
  echo ""
fi

# ---- 确认 ----
read -rp "继续升级? [y/N] " confirm
if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
  echo "取消升级。"
  exit 0
fi
echo ""

# ---- Phase 1: 覆盖 commands ----
echo -e "${CYAN}[1/3] 更新 commands → .claude/commands/${NC}"

COMMANDS_DIR="$TARGET_DIR/.claude/commands"
mkdir -p "$COMMANDS_DIR"

for cmd in "$SCRIPT_DIR/commands/"*.md; do
  filename="$(basename "$cmd")"
  dest="$COMMANDS_DIR/$filename"
  cp "$cmd" "$dest"
  updated+=(".claude/commands/$filename")
  echo -e "  ${GREEN}↻${NC} .claude/commands/$filename"
done

echo ""

# ---- Phase 2: 添加新文件 ----
echo -e "${CYAN}[2/3] 添加新模板文件${NC}"

# 根级模板
for root_file in "$SCRIPT_DIR/templates/"*.md; do
  [ -f "$root_file" ] || continue
  filename="$(basename "$root_file")"
  dest="$TARGET_DIR/$filename"
  if [ ! -f "$dest" ]; then
    cp "$root_file" "$dest"
    added+=("$filename")
    echo -e "  ${GREEN}+${NC} $filename (new)"
  else
    skipped+=("$filename")
  fi
done

# prompts 模板
PROMPTS_DIR="$TARGET_DIR/prompts"
mkdir -p "$PROMPTS_DIR"

while IFS= read -r p; do
  rel="${p#$SCRIPT_DIR/templates/prompts/}"
  dest="$PROMPTS_DIR/$rel"
  mkdir -p "$(dirname "$dest")"
  if [ ! -f "$dest" ]; then
    cp "$p" "$dest"
    added+=("prompts/$rel")
    echo -e "  ${GREEN}+${NC} prompts/$rel (new)"
  else
    skipped+=("prompts/$rel")
  fi
done < <(find "$SCRIPT_DIR/templates/prompts" -type f -name "*.md" 2>/dev/null | sort)

# memory 模板
MODE="$(cek_get "$CEK_FILE" "mode" "solo")"
USER_NAME="$(cek_get "$CEK_FILE" "user" "")"
if [ "$MODE" = "solo" ]; then
  add_memory_templates "memory"
elif [ "$MODE" = "team" ]; then
  add_memory_templates "memory/shared"
  if [ -n "$USER_NAME" ]; then
    add_memory_templates "memory/$USER_NAME"
  else
    echo -e "  ${YELLOW}!${NC} team mode has no user in .cek; skipped personal memory templates"
  fi
fi

echo ""

# ---- Phase 3: 更新 .cek ----
echo -e "${CYAN}[3/3] 更新 .cek 版本号${NC}"

if cek_set_version "$CEK_FILE" "$KIT_VERSION"; then
  echo -e "  ${GREEN}↻${NC} .cek → version $KIT_VERSION"
else
  echo -e "  ${YELLOW}!${NC} cannot update .cek automatically; please update version to $KIT_VERSION manually"
fi

echo ""

# ---- 报告 ----
echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"
echo -e "  ${GREEN}更新 ${#updated[@]} 个文件${NC}，${GREEN}新建 ${#added[@]} 个文件${NC}，${YELLOW}跳过 ${#skipped[@]} 个已有文件${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"
echo ""
echo "升级完成: $OLD_VERSION → $KIT_VERSION"
echo ""
