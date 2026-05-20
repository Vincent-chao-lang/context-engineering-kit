#!/usr/bin/env bash
#
# Context Engineering Kit - 安装脚本
#
# 用法:
#   ./install.sh                              安装到当前目录（solo 模式）
#   ./install.sh /path/to/project             安装到指定项目（solo 模式）
#   ./install.sh --team --user alice          团队模式安装到当前目录
#   ./install.sh --team --user alice /path    团队模式安装到指定项目
#
set -euo pipefail

# 解析参数
CEK_MODE="solo"
CEK_USER=""

POSITIONAL=()
while [[ $# -gt 0 ]]; do
  case $1 in
    --team)  CEK_MODE="team"; shift ;;
    --user)  CEK_USER="${2:-}"; shift 2 ;;
    *)       POSITIONAL+=("$1"); shift ;;
  esac
done

if [ "$CEK_MODE" = "team" ] && [ -z "$CEK_USER" ]; then
  echo "ERROR: --team requires --user <username>"
  exit 1
fi

# 确定脚本所在目录（兼容符号链接）
SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "$0" 2>/dev/null || echo "$0")")" && pwd)"
TARGET_DIR="$(cd "${POSITIONAL[0]:-.}" && pwd)"

KIT_VERSION="$(tr -d '[:space:]' < "$SCRIPT_DIR/VERSION" 2>/dev/null || echo "unknown")"

# 颜色输出
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'

created=()
skipped=()

log_created() { created+=("$1"); echo -e "  ${GREEN}+${NC} $1"; }
log_skipped() { skipped+=("$1"); echo -e "  ${YELLOW}·${NC} $1 (已存在，跳过)"; }

mode_label="solo"
[ "$CEK_MODE" = "team" ] && mode_label="team (user: $CEK_USER)"

echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"
echo -e "${CYAN}  Context Engineering Kit 安装器 v${KIT_VERSION}${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"
echo ""
echo "目标项目: $TARGET_DIR"
echo "模式: $mode_label"
echo ""

# ---- 1. 安装 Claude Code 命令 ----
echo -e "${CYAN}[1/4] 安装 Claude Code 命令 → .claude/commands/${NC}"

COMMANDS_DIR="$TARGET_DIR/.claude/commands"
mkdir -p "$COMMANDS_DIR"

for cmd in "$SCRIPT_DIR/commands/"*.md; do
  filename="$(basename "$cmd")"
  dest="$COMMANDS_DIR/$filename"
  if [ -f "$dest" ]; then
    log_skipped ".claude/commands/$filename"
  else
    cp "$cmd" "$dest"
    log_created ".claude/commands/$filename"
  fi
done

echo ""

# ---- 2. 安装 memory 模板 ----
if [ "$CEK_MODE" = "team" ]; then
  echo -e "${CYAN}[2/4] 安装 memory 模板 → memory/shared/ + memory/$CEK_USER/${NC}"

  # 团队共享
  SHARED_DIR="$TARGET_DIR/memory/shared"
  mkdir -p "$SHARED_DIR"
  for mem in "$SCRIPT_DIR/templates/memory/"*.md; do
    filename="$(basename "$mem")"
    dest="$SHARED_DIR/$filename"
    if [ -f "$dest" ]; then
      log_skipped "memory/shared/$filename"
    else
      cp "$mem" "$dest"
      log_created "memory/shared/$filename"
    fi
  done

  # 个人 memory
  USER_DIR="$TARGET_DIR/memory/$CEK_USER"
  mkdir -p "$USER_DIR"
  for mem in "$SCRIPT_DIR/templates/memory/"*.md; do
    filename="$(basename "$mem")"
    dest="$USER_DIR/$filename"
    if [ -f "$dest" ]; then
      log_skipped "memory/$CEK_USER/$filename"
    else
      cp "$mem" "$dest"
      log_created "memory/$CEK_USER/$filename"
    fi
  done

  # TEAM.md
  TEAM_FILE="$TARGET_DIR/memory/TEAM.md"
  if [ -f "$TEAM_FILE" ]; then
    log_skipped "memory/TEAM.md"
  else
    cp "$SCRIPT_DIR/templates/team/TEAM.md" "$TEAM_FILE"
    log_created "memory/TEAM.md"
  fi
else
  echo -e "${CYAN}[2/4] 安装 memory 模板 → memory/${NC}"

  MEMORY_DIR="$TARGET_DIR/memory"
  mkdir -p "$MEMORY_DIR"

  for mem in "$SCRIPT_DIR/templates/memory/"*.md; do
    filename="$(basename "$mem")"
    dest="$MEMORY_DIR/$filename"
    if [ -f "$dest" ]; then
      log_skipped "memory/$filename"
    else
      cp "$mem" "$dest"
      log_created "memory/$filename"
    fi
  done
fi

echo ""

# ---- 3. 安装 prompts 模板 + 根级文档 ----
echo -e "${CYAN}[3/4] 安装 prompts 模板 + 根级文档${NC}"

PROMPTS_DIR="$TARGET_DIR/prompts"
mkdir -p "$PROMPTS_DIR"

while IFS= read -r p; do
  rel="${p#$SCRIPT_DIR/templates/prompts/}"
  dest="$PROMPTS_DIR/$rel"
  mkdir -p "$(dirname "$dest")"
  if [ -f "$dest" ]; then
    log_skipped "prompts/$rel"
  else
    cp "$p" "$dest"
    log_created "prompts/$rel"
  fi
done < <(find "$SCRIPT_DIR/templates/prompts" -type f -name "*.md" | sort)

# 根级模板文件
for root_file in "$SCRIPT_DIR/templates/"*.md; do
  filename="$(basename "$root_file")"
  dest="$TARGET_DIR/$filename"
  if [ -f "$dest" ]; then
    log_skipped "$filename"
  else
    cp "$root_file" "$dest"
    log_created "$filename"
  fi
done

echo ""

# ---- 4. 团队模式额外设置 ----
echo -e "${CYAN}[4/4] 元数据与 git 配置${NC}"

# 写 .cek
CEK_FILE="$TARGET_DIR/.cek"
if [ -f "$CEK_FILE" ]; then
  if command -v sed &>/dev/null; then
    sed -i.bak "s/\"version\":\"[^\"]*\"/\"version\":\"$KIT_VERSION\"/" "$CEK_FILE" 2>/dev/null && rm -f "$CEK_FILE.bak"
    sed -i.bak "s/\"mode\":\"[^\"]*\"/\"mode\":\"$CEK_MODE\"/" "$CEK_FILE" 2>/dev/null && rm -f "$CEK_FILE.bak"
    sed -i.bak "s/\"user\":\"[^\"]*\"/\"user\":\"$CEK_USER\"/" "$CEK_FILE" 2>/dev/null && rm -f "$CEK_FILE.bak"
  fi
  log_created ".cek (updated)"
else
  echo "{\"version\":\"$KIT_VERSION\",\"mode\":\"$CEK_MODE\",\"user\":\"$CEK_USER\",\"installed_at\":\"$(date +%Y-%m-%d)\"}" > "$CEK_FILE"
  log_created ".cek"
fi

# 团队模式：更新 .gitignore 和 .gitattributes
if [ "$CEK_MODE" = "team" ]; then
  GITIGNORE="$TARGET_DIR/.gitignore"
  if [ -f "$GITIGNORE" ]; then
    if ! grep -q "memory/\*/" "$GITIGNORE" 2>/dev/null; then
      echo "" >> "$GITIGNORE"
      cat "$SCRIPT_DIR/templates/team/gitignore.append" >> "$GITIGNORE"
      log_created ".gitignore (appended team rules)"
    else
      log_skipped ".gitignore (team rules already present)"
    fi
  else
    cp "$SCRIPT_DIR/templates/team/gitignore.append" "$GITIGNORE"
    log_created ".gitignore"
  fi

  GITATTR="$TARGET_DIR/.gitattributes"
  if [ -f "$GITATTR" ]; then
    if ! grep -q "DECISIONS.md merge=union" "$GITATTR" 2>/dev/null; then
      echo "" >> "$GITATTR"
      cat "$SCRIPT_DIR/templates/team/gitattributes" >> "$GITATTR"
      log_created ".gitattributes (appended merge rules)"
    else
      log_skipped ".gitattributes (merge rules already present)"
    fi
  else
    cp "$SCRIPT_DIR/templates/team/gitattributes" "$GITATTR"
    log_created ".gitattributes"
  fi
fi

echo ""

# ---- 安装报告 ----
echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"
echo -e "  ${GREEN}新建 ${#created[@]} 个文件${NC}，${YELLOW}跳过 ${#skipped[@]} 个已有文件${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"
echo ""
echo "下一步:"
echo "  1. 进入目标项目并启动 Claude Code"
echo "  2. 运行 /init-context，分析项目并生成/补齐 CLAUDE.md、AGENTS.md、ARCHITECTURE.md 等上下文文件"
echo "  3. 检查生成内容后首次 git commit 建立基线"
echo ""
echo "日常工作:"
echo "  /start          恢复工作上下文"
echo "  /wrap           下班自动总结"
echo "  /init-context   初始化或补齐上下文文件"
echo "  $SCRIPT_DIR/doctor.sh \"$TARGET_DIR\"   检查上下文文件健康状态"
echo "  $SCRIPT_DIR/upgrade.sh \"$TARGET_DIR\"  升级 kit（覆盖 commands，不覆盖项目文件）"
echo ""
