#!/usr/bin/env bash
# ================================================================
#  Distill OpenCode — 一键安装脚本
#  蒸馏 Sisyphus 同款 OpenCode 配置：模型、插件、技能、规则
#
#  用法:
#    curl -fsSL https://raw.githubusercontent.com/panzhaohu666/Distill-OpenCode/main/install.sh | bash
#
#  或者:
#    git clone https://github.com/panzhaohu666/Distill-OpenCode.git
#    bash Distill-OpenCode/install.sh
# ================================================================
set -euo pipefail

# ── 颜色 ──────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

# ── 全局变量 ──────────────────────────────────────────
REPO="panzhaohu666/Distill-OpenCode"
CONFIG_DIR="${HOME}/.config/opencode"
TEMP_DIR=""
HAS_ERROR=0

# ── 工具函数 ──────────────────────────────────────────
cleanup() {
  if [ -n "$TEMP_DIR" ] && [ -d "$TEMP_DIR" ]; then
    rm -rf "$TEMP_DIR"
  fi
}
trap cleanup EXIT

log()     { echo -e "  ${GREEN}✓${NC} $*"; }
warn()    { echo -e "  ${YELLOW}⚠${NC} $*"; }
err()     { echo -e "  ${RED}✗${NC} $*"; HAS_ERROR=1; }
info()    { echo -e "  ${CYAN}→${NC} $*"; }
section() { echo -e "\n${BOLD}${BLUE}═══ $* ═══${NC}"; }

panic() {
  echo -e "\n${RED}${BOLD}致命错误:${NC} $*"
  echo "安装中断。请检查上述错误后重试。"
  exit 1
}

# ── 检测是否为 curl 管道调用 ──────────────────────────
if [ -t 0 ]; then
  # 交互式终端：脚本在本地，从同目录找 archive
  SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
  ARCHIVE_SOURCE="${SCRIPT_DIR}/opencode-skills.tar.gz"
else
  # curl 管道调用：需要从 GitHub Release 下载
  SCRIPT_DIR=""
  ARCHIVE_SOURCE=""
fi

# ════════════════════════════════════════════════════════
# 横幅
# ════════════════════════════════════════════════════════
clear 2>/dev/null || true
echo ""
echo -e "  ${BOLD}${BLUE}╔══════════════════════════════════════════════════╗${NC}"
echo -e "  ${BOLD}${BLUE}║${NC}                                                  ${BOLD}${BLUE}║${NC}"
echo -e "  ${BOLD}${BLUE}║${NC}   ${BOLD}Distill OpenCode — 一键安装 Sisyphus 同款配置${BOLD}${BLUE}║${NC}"
echo -e "  ${BOLD}${BLUE}║${NC}   蒸馏 · 即用 · 无痛迁移                           ${BOLD}${BLUE}║${NC}"
echo -e "  ${BOLD}${BLUE}║${NC}                                                  ${BOLD}${BLUE}║${NC}"
echo -e "  ${BOLD}${BLUE}╚══════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  仓库: ${CYAN}github.com/${REPO}${NC}"
echo ""

# ════════════════════════════════════════════════════════
# Step 1 — 环境检测
# ════════════════════════════════════════════════════════
section "Step 1/7 · 环境检测"

# 操作系统
OS="$(uname -s)"
case "$OS" in
  Linux)   log "操作系统: Linux" ;;
  Darwin)  log "操作系统: macOS" ;;
  *)       warn "操作系统: $OS — 未经充分测试，可能存在问题" ;;
esac

# 架构
ARCH="$(uname -m)"
log "架构: ${ARCH}"

# 磁盘空间
if command -v df &>/dev/null; then
  AVAIL=$(df -k "$HOME" 2>/dev/null | awk 'NR==2 {print $4}')
  if [ -n "$AVAIL" ] && [ "$AVAIL" -lt 500000 ]; then
    warn "磁盘空间不足 500MB (可用: $((AVAIL/1024))MB)，安装可能失败"
  else
    log "磁盘空间充足"
  fi
fi

# ── 检测/安装基本依赖 ─────────────────────────────────
install_pkg() {
  local name="$1"
  for cmd in "$@"; do
    if command -v "$cmd" &>/dev/null; then
      log "${name} 已就绪: $(command -v "$cmd")"
      return 0
    fi
  done
  warn "${name} 未安装，尝试安装..."
  case "$OS" in
    Linux)
      if command -v apt-get &>/dev/null; then
        sudo apt-get update -qq && sudo apt-get install -y -qq "$name" 2>/dev/null
      elif command -v yum &>/dev/null; then
        sudo yum install -y "$name" 2>/dev/null
      elif command -v dnf &>/dev/null; then
        sudo dnf install -y "$name" 2>/dev/null
      elif command -v pacman &>/dev/null; then
        sudo pacman -S --noconfirm "$name" 2>/dev/null
      fi
      ;;
    Darwin)
      if command -v brew &>/dev/null; then
        brew install "$name" 2>/dev/null
      fi
      ;;
  esac
}

install_pkg "curl" curl
install_pkg "tar" tar
install_pkg "git" git

# ── 检测/安装 Node.js & npm ────────────────────────────
if command -v node &>/dev/null; then
  NODE_VER=$(node -v)
  log "Node.js 已安装: ${NODE_VER}"
else
  warn "Node.js 未安装"
  info "正在通过 nvm 安装 Node.js LTS..."
  export NVM_DIR="${HOME}/.nvm"
  if [ -s "$NVM_DIR/nvm.sh" ]; then
    source "$NVM_DIR/nvm.sh"
    nvm install --lts
    nvm use --lts
    log "Node.js LTS 安装完成: $(node -v)"
  else
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
    export NVM_DIR="${HOME}/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
    nvm install --lts
    nvm use --lts
    log "Node.js LTS 安装完成: $(node -v)"
  fi
fi

# ════════════════════════════════════════════════════════
# Step 2 — 安装 OpenCode CLI
# ════════════════════════════════════════════════════════
section "Step 2/7 · 安装 OpenCode CLI"

if command -v opencode &>/dev/null; then
  OC_VER=$(opencode --version 2>/dev/null || echo "unknown")
  log "OpenCode CLI 已安装: ${OC_VER}"
else
  info "通过 npm 全局安装 opencode..."
  npm install -g opencode@latest 2>&1 | tail -1
  if command -v opencode &>/dev/null; then
    log "OpenCode CLI 安装完成: $(opencode --version 2>/dev/null || echo 'ok')"
  else
    panic "OpenCode CLI 安装失败，请检查 npm 配置"
  fi
fi

# ════════════════════════════════════════════════════════
# Step 3 — 创建配置目录
# ════════════════════════════════════════════════════════
section "Step 3/7 · 创建配置目录"

if [ -d "$CONFIG_DIR" ]; then
  if [ -d "${CONFIG_DIR}/skills" ] || [ -d "${CONFIG_DIR}/skill-libraries" ]; then
    warn "检测到已有 OpenCode 配置"
    echo ""
    echo -e "  ${YELLOW}是否覆盖已有配置？(y/N)${NC}"
    read -r OVERWRITE
    if [ "$OVERWRITE" != "y" ] && [ "$OVERWRITE" != "Y" ]; then
      info "保留现有配置，跳过技能库解压"
      SKIP_SKILLS=true
    else
      info "将覆盖现有配置..."
      SKIP_SKILLS=false
    fi
  fi
fi

mkdir -p "$CONFIG_DIR"
log "配置目录: ${CONFIG_DIR}"

# ════════════════════════════════════════════════════════
# Step 4 — 写入配置文件
# ════════════════════════════════════════════════════════
section "Step 4/7 · 写入配置文件"

# ── opencode.jsonc ─────────────────────────────────────
cat > "${CONFIG_DIR}/opencode.jsonc" << 'EOF'
{
  "$schema": "https://opencode.ai/config.json",
  "plugin": [
    "oh-my-openagent@latest",
    "opencode-skill-creator"
  ],
  "model": "deepseek/deepseek-v4-pro",
  "small_model": "deepseek/deepseek-v4-flash",
  "provider": {
    "deepseek": {
      "options": {
        "apiKey": "YOUR_DEEPSEEK_API_KEY_HERE",
        "timeout": 600000,
        "chunkTimeout": 60000
      }
    },
    "google": {
      "options": {
        "apiKey": "YOUR_GOOGLE_API_KEY_HERE"
      }
    }
  }
}
EOF
log "opencode.jsonc     — 模型配置 (需填入 API Key)"

# ── oh-my-openagent.jsonc ──────────────────────────────
cat > "${CONFIG_DIR}/oh-my-openagent.jsonc" << 'EOF'
{
  "$schema": "https://raw.githubusercontent.com/code-yeongyu/oh-my-openagent/dev/assets/oh-my-openagent.schema.json",
  "agents": {
    "atlas":            { "model": "deepseek/deepseek-v4-flash" },
    "explore":          { "model": "deepseek/deepseek-v4-flash" },
    "hephaestus":      { "model": "deepseek/deepseek-v4-pro" },
    "librarian":        { "model": "deepseek/deepseek-v4-flash" },
    "metis":            { "model": "deepseek/deepseek-v4-pro" },
    "momus":            { "model": "deepseek/deepseek-v4-pro" },
    "multimodal-looker": { "model": "google/gemini-3.5-flash-lite" },
    "oracle":           { "model": "deepseek/deepseek-v4-pro" },
    "prometheus":       { "model": "deepseek/deepseek-v4-pro" },
    "sisyphus-junior":  { "model": "deepseek/deepseek-v4-flash" }
  },
  "categories": {
    "artistry":           { "model": "deepseek/deepseek-v4-pro" },
    "deep":               { "model": "deepseek/deepseek-v4-pro" },
    "quick":              { "model": "deepseek/deepseek-v4-flash" },
    "ultrabrain":         { "model": "deepseek/deepseek-v4-pro" },
    "unspecified-high":   { "model": "deepseek/deepseek-v4-flash" },
    "unspecified-low":    { "model": "deepseek/deepseek-v4-flash" },
    "visual-engineering": { "model": "deepseek/deepseek-v4-flash" },
    "writing":            { "model": "deepseek/deepseek-v4-flash" }
  }
}
EOF
log "oh-my-openagent.jsonc — Agent/Category 模型分配"

# ── tui.json ───────────────────────────────────────────
cat > "${CONFIG_DIR}/tui.json" << 'EOF'
{
  "$schema": "https://opencode.ai/tui.json",
  "plugin": ["oh-my-openagent@latest"],
  "theme": "tokyonight"
}
EOF
log "tui.json           — 终端主题 tokyonight"

# ════════════════════════════════════════════════════════
# Step 5 — 下载并解压技能库
# ════════════════════════════════════════════════════════
section "Step 5/7 · 安装技能库 (1913 技能 + 99 入口 + 3 规则)"

SKIP_SKILLS="${SKIP_SKILLS:-false}"

if [ "$SKIP_SKILLS" = true ]; then
  log "跳过技能库安装 (用户选择保留现有配置)"
else
  # 确定 archive 来源
  if [ -n "$ARCHIVE_SOURCE" ] && [ -f "$ARCHIVE_SOURCE" ]; then
    info "使用本地技能包: ${ARCHIVE_SOURCE}"
    ARCHIVE_PATH="$ARCHIVE_SOURCE"
  else
    # 从 GitHub Release 下载
    TEMP_DIR=$(mktemp -d)
    ARCHIVE_PATH="${TEMP_DIR}/opencode-skills.tar.gz"
    RELEASE_URL="https://github.com/${REPO}/releases/latest/download/opencode-skills.tar.gz"
    
    info "从 GitHub Release 下载技能包..."
    info "URL: ${RELEASE_URL}"
    
    if curl -fSL --progress-bar -o "$ARCHIVE_PATH" "$RELEASE_URL"; then
      log "下载完成 ($(du -h "$ARCHIVE_PATH" | cut -f1))"
    else
      # 尝试不跟随重定向
      DL_URL=$(curl -sI "$RELEASE_URL" | grep -i location | awk '{print $2}' | tr -d '\r')
      if [ -n "$DL_URL" ]; then
        info "跟随重定向下载..."
        curl -fSL --progress-bar -o "$ARCHIVE_PATH" "$DL_URL" || panic "下载技能包失败，请检查网络连接"
        log "下载完成 ($(du -h "$ARCHIVE_PATH" | cut -f1))"
      else
        panic "无法从 GitHub Release 下载技能包。请确认网络连接或手动下载。"
      fi
    fi
  fi
  
  # 解压
  info "解压技能包到 ${CONFIG_DIR}..."
  tar xzf "$ARCHIVE_PATH" -C "$CONFIG_DIR/" 2>/dev/null
  log "技能包解压完成"
fi

# ════════════════════════════════════════════════════════
# Step 6 — 安装插件
# ════════════════════════════════════════════════════════
section "Step 6/7 · 安装插件"

info "安装 oh-my-openagent..."
opencode plugin install oh-my-openagent@latest 2>/dev/null && \
  log "oh-my-openagent ✓" || \
  warn "oh-my-openagent 可稍后手动安装: opencode plugin install oh-my-openagent@latest"

info "安装 opencode-skill-creator..."
opencode plugin install opencode-skill-creator 2>/dev/null && \
  log "opencode-skill-creator ✓" || \
  warn "opencode-skill-creator 可稍后手动安装: opencode plugin install opencode-skill-creator"

# ════════════════════════════════════════════════════════
# Step 7 — 验证
# ════════════════════════════════════════════════════════
section "Step 7/7 · 验证安装"

SKILL_COUNT=$(find "${CONFIG_DIR}/skills" -name "SKILL.md" 2>/dev/null | wc -l)
LIB_COUNT=$(find "${CONFIG_DIR}/skill-libraries" -name "SKILL.md" 2>/dev/null | wc -l)
RULE_COUNT=$(find "${CONFIG_DIR}/rules" -name "*.md" 2>/dev/null | wc -l)

echo ""
echo -e "  ${BOLD}┌─────────────────────────────────────────┐${NC}"
echo -e "  ${BOLD}│${NC}  安装验证                               ${BOLD}│${NC}"
echo -e "  ${BOLD}├─────────────────────────────────────────┤${NC}"
printf "  ${BOLD}│${NC}  入口技能 (skills/):         ${GREEN}%4d${NC} 个    ${BOLD}│${NC}\n" "$SKILL_COUNT"
printf "  ${BOLD}│${NC}  技能库 (skill-libraries/):  ${GREEN}%4d${NC} 个    ${BOLD}│${NC}\n" "$LIB_COUNT"
printf "  ${BOLD}│${NC}  全局规则 (rules/):          ${GREEN}%4d${NC} 个    ${BOLD}│${NC}\n" "$RULE_COUNT"
echo -e "  ${BOLD}└─────────────────────────────────────────┘${NC}"
echo ""

VERIFY_OK=true
[ "$SKILL_COUNT" -ge 90 ]  || { err "入口技能不足 (预期 ≥90, 实际 ${SKILL_COUNT})"; VERIFY_OK=false; }
[ "$LIB_COUNT" -ge 1000 ]  || { err "技能库不足 (预期 ≥1000, 实际 ${LIB_COUNT})"; VERIFY_OK=false; }
[ "$RULE_COUNT" -ge 3 ]    || { err "规则文件不足 (预期 ≥3, 实际 ${RULE_COUNT})"; VERIFY_OK=false; }

if [ "$VERIFY_OK" = true ]; then
  log "所有组件验证通过 ✓"
fi

# ════════════════════════════════════════════════════════
# 完成
# ════════════════════════════════════════════════════════
echo ""
echo -e "  ${BOLD}${GREEN}╔══════════════════════════════════════════════════╗${NC}"
echo -e "  ${BOLD}${GREEN}║${NC}                                                  ${BOLD}${GREEN}║${NC}"
echo -e "  ${BOLD}${GREEN}║${NC}   ${BOLD}安装完成！${NC}                                   ${BOLD}${GREEN}║${NC}"
echo -e "  ${BOLD}${GREEN}║${NC}                                                  ${BOLD}${GREEN}║${NC}"
echo -e "  ${BOLD}${GREEN}╠══════════════════════════════════════════════════╣${NC}"
echo -e "  ${BOLD}${GREEN}║${NC}                                                  ${BOLD}${GREEN}║${NC}"
echo -e "  ${BOLD}${GREEN}║${NC}  ${YELLOW}⚠ 完成最后一步 — 填入 API Key:${NC}                 ${BOLD}${GREEN}║${NC}"
echo -e "  ${BOLD}${GREEN}║${NC}                                                  ${BOLD}${GREEN}║${NC}"
echo -e "  ${BOLD}${GREEN}║${NC}  ${CYAN}vim ~/.config/opencode/opencode.jsonc${NC}          ${BOLD}${GREEN}║${NC}"
echo -e "  ${BOLD}${GREEN}║${NC}                                                  ${BOLD}${GREEN}║${NC}"
echo -e "  ${BOLD}${GREEN}║${NC}  替换:                                           ${BOLD}${GREEN}║${NC}"
echo -e "  ${BOLD}${GREEN}║${NC}    YOUR_DEEPSEEK_API_KEY_HERE                   ${BOLD}${GREEN}║${NC}"
echo -e "  ${BOLD}${GREEN}║${NC}    YOUR_GOOGLE_API_KEY_HERE                     ${BOLD}${GREEN}║${NC}"
echo -e "  ${BOLD}${GREEN}║${NC}                                                  ${BOLD}${GREEN}║${NC}"
echo -e "  ${BOLD}${GREEN}╠══════════════════════════════════════════════════╣${NC}"
echo -e "  ${BOLD}${GREEN}║${NC}                                                  ${BOLD}${GREEN}║${NC}"
echo -e "  ${BOLD}${GREEN}║${NC}  快速验证:                                       ${BOLD}${GREEN}║${NC}"
echo -e "  ${BOLD}${GREEN}║${NC}    ${CYAN}opencode \"hello world\"${NC}                      ${BOLD}${GREEN}║${NC}"
echo -e "  ${BOLD}${GREEN}║${NC}                                                  ${BOLD}${GREEN}║${NC}"
echo -e "  ${BOLD}${GREEN}║${NC}  一键安装命令 (新机器):                          ${BOLD}${GREEN}║${NC}"
echo -e "  ${BOLD}${GREEN}║${NC}    ${CYAN}curl -fsSL https://raw.githubusercontent.com/${REPO}/main/install.sh | bash${NC}${BOLD}${GREEN}║${NC}"
echo -e "  ${BOLD}${GREEN}║${NC}                                                  ${BOLD}${GREEN}║${NC}"
echo -e "  ${BOLD}${GREEN}╚══════════════════════════════════════════════════╝${NC}"
echo ""

exit $HAS_ERROR
