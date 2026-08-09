#!/usr/bin/env bash
# ================================================================
#  Distill OpenCode — 一键安装脚本
#  蒸馏 Sisyphus 同款 OpenCode 配置：模型、插件、技能、规则
#
#  用法 (推荐 — 带 Key 一键完成):
#    curl -fsSL https://raw.githubusercontent.com/panzhaohu666/Distill-OpenCode/main/install.sh | bash -s -- YOUR_DEEPSEEK_API_KEY
#
#  用法 (交互式 — 会询问 Key):
#    bash install.sh
#
#  用法 (环境变量):
#    export DEEPSEEK_API_KEY="sk-xxx"
#    curl -fsSL ... | bash
#
#  用法 (指定版本):
#    bash install.sh sk-xxx --version v1.0.0
#    bash install.sh --version v1.0.0 sk-xxx
#    curl -fsSL ... | bash -s -- --version v1.0.0 sk-xxx
#
#  用法 (安静模式 — 只输出错误):
#    bash install.sh -q sk-xxx
#    bash install.sh --quiet --version v1.0.0
#
#  用法 (git clone):
#    git clone https://github.com/panzhaohu666/Distill-OpenCode.git
#    bash Distill-OpenCode/install.sh
#
#  本地自定义保护:
#    如果 ~/.config/opencode/local/ 已存在文件, 安装过程不会覆盖它们。
#    技能包解压时会自动保留 local/ 目录中的现有文件。
#
#  退出码:
#    0 = 成功
#    1 = 依赖检查失败
#    2 = 下载失败
#    3 = 配置文件写入失败
#    4 = 技能包解压失败
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
QUIET=false
VERSION=""
DEEPSEEK_KEY=""

# ── 参数解析 ──────────────────────────────────────────
# 遍历所有命令行参数, 提取 API Key (sk-... 或非 flag 参数),
# --version / -v, --quiet / -q
while [ $# -gt 0 ]; do
  case "$1" in
    --version|-v)
      if [ $# -lt 2 ]; then
        echo -e "${RED}错误: --version 需要参数, 例如 --version v1.0.0${NC}" >&2
        exit 1
      fi
      VERSION="$2"
      shift 2
      ;;
    --quiet|-q)
      QUIET=true
      shift
      ;;
    *)
      # 第一个非 flag 参数作为 API Key
      if [ -z "$DEEPSEEK_KEY" ] && [ -n "${1:-}" ]; then
        DEEPSEEK_KEY="$1"
      fi
      shift
      ;;
  esac
done

# 如果命令行未提供 Key, 尝试环境变量
if [ -z "$DEEPSEEK_KEY" ] && [ -n "${DEEPSEEK_API_KEY:-}" ]; then
  DEEPSEEK_KEY="$DEEPSEEK_API_KEY"
fi

# ── 工具函数 ──────────────────────────────────────────
# shellcheck disable=SC2329  # cleanup is invoked via trap
cleanup() {
  if [ -n "$TEMP_DIR" ] && [ -d "$TEMP_DIR" ]; then
    rm -rf "$TEMP_DIR"
  fi
}
trap cleanup EXIT
# 额外捕获常见信号, 确保 TEMP_DIR 被清理
trap 'cleanup; exit 130' INT TERM
trap 'cleanup' HUP

# 处理 SIGPIPE: 确保 TEMP_DIR 被清理后退出
trap 'cleanup; exit 141' PIPE 2>/dev/null || true

log()     { [ "$QUIET" = false ] && echo -e "  ${GREEN}✓${NC} $*"; }
warn()    { [ "$QUIET" = false ] && echo -e "  ${YELLOW}⚠${NC} $*"; }
err()     { echo -e "  ${RED}✗${NC} $*"; HAS_ERROR=1; }
info()    { [ "$QUIET" = false ] && echo -e "  ${CYAN}→${NC} $*"; }
section() { echo -e "\n${BOLD}${BLUE}═══ $* ═══${NC}"; }

panic() {
  local msg="$1"
  local code="${2:-1}"
  echo -e "\n${RED}${BOLD}致命错误:${NC} $msg"
  echo "安装中断。请检查上述错误后重试。"
  exit "$code"
}

# ── 横幅 (安静模式下跳过) ─────────────────────────────
show_banner() {
  clear 2>/dev/null || true
  echo ""
  echo -e "  ${BOLD}${BLUE}╔══════════════════════════════════════════════════╗${NC}"
  echo -e "  ${BOLD}${BLUE}║${NC}                                                  ${BOLD}${BLUE}║${NC}"
  echo -e "  ${BOLD}${BLUE}║${NC}   ${BOLD}Distill OpenCode — 一键安装 Sisyphus 同款配置${BOLD}${BLUE}║${NC}"
  echo -e "  ${BOLD}${BLUE}║${NC}   蒸馏 · 即用 · 无痛迁移 · 一条命令到位           ${BOLD}${BLUE}║${NC}"
  echo -e "  ${BOLD}${BLUE}║${NC}                                                  ${BOLD}${BLUE}║${NC}"
  echo -e "  ${BOLD}${BLUE}╚══════════════════════════════════════════════════╝${NC}"
  echo ""
  echo -e "  仓库: ${CYAN}github.com/${REPO}${NC}"
  if [ -n "$VERSION" ]; then
    echo -e "  版本: ${CYAN}${VERSION}${NC}"
  fi
  echo ""
}

if [ "$QUIET" = false ]; then
  show_banner
fi

# ════════════════════════════════════════════════════════
# Step 0 — 收集 API Key (如未提供)
# ════════════════════════════════════════════════════════
# 检测运行模式: 从 tty 运行 (交互模式) vs 管道输入 (非交互)
if [ -t 0 ]; then
  SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
  ARCHIVE_SOURCE="${SCRIPT_DIR}/opencode-skills.tar.gz"
  INTERACTIVE=true
else
  SCRIPT_DIR=""
  ARCHIVE_SOURCE=""
  INTERACTIVE=false
fi

if [ -z "$DEEPSEEK_KEY" ]; then
  if [ "$INTERACTIVE" = true ]; then
    section "API Key 配置"
    echo ""
    echo -e "  ${BOLD}所有模型统一使用 DeepSeek，只需一个 API Key。${NC}"
    echo -e "  DeepSeek API Key 获取: ${CYAN}https://platform.deepseek.com/api_keys${NC}"
    echo ""
    echo -e "  ${BOLD}请输入你的 DeepSeek API Key (sk-...):${NC}"
    echo -n "  > "
    read -r DEEPSEEK_KEY
  fi

  if [ -z "$DEEPSEEK_KEY" ]; then
    warn "未提供 API Key，将写入占位符。之后手动编辑: vim ~/.config/opencode/opencode.jsonc"
    DEEPSEEK_KEY="YOUR_DEEPSEEK_API_KEY_HERE"
  fi
fi

# 简单校验格式
if [ "$DEEPSEEK_KEY" != "YOUR_DEEPSEEK_API_KEY_HERE" ]; then
  if [[ "$DEEPSEEK_KEY" =~ ^sk- ]]; then
    log "API Key 格式校验通过"
    KEY_CONFIGURED=true
  else
    warn "API Key 格式不标准 (通常以 sk- 开头)，已写入但可能无效"
    KEY_CONFIGURED=true
  fi
else
  KEY_CONFIGURED=false
fi

# ════════════════════════════════════════════════════════
# Step 0.5 — 预安装备份 (如有现有配置)
# ════════════════════════════════════════════════════════
if [ -d "$CONFIG_DIR" ] && [ "$(ls -A "$CONFIG_DIR" 2>/dev/null)" ]; then
  BACKUP_DIR="${HOME}/.config/opencode.backup/$(date +%Y%m%d-%H%M%S)"
  section "预安装备份"
  mkdir -p "$(dirname "$BACKUP_DIR")"
  info "检测到已有配置, 备份到: ${BACKUP_DIR}"
  cp -r "$CONFIG_DIR" "$BACKUP_DIR"
  log "备份完成: ${BACKUP_DIR}"
fi

# ════════════════════════════════════════════════════════
# Step 1 — 环境检测
# ════════════════════════════════════════════════════════
section "Step 1/7 · 环境检测"

OS="$(uname -s)"
case "$OS" in
  Linux)   log "操作系统: Linux" ;;
  Darwin)  log "操作系统: macOS" ;;
  *)       warn "操作系统: $OS — 未经充分测试" ;;
esac

ARCH="$(uname -m)"
log "架构: ${ARCH}"

if command -v df &>/dev/null; then
  AVAIL=$(df -k "$HOME" 2>/dev/null | awk 'NR==2 {print $4}')
  if [ -n "$AVAIL" ] && [ "$AVAIL" -lt 500000 ]; then
    warn "磁盘空间不足 500MB (可用: $((AVAIL/1024))MB)"
  else
    log "磁盘空间充足"
  fi
fi

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

if command -v node &>/dev/null; then
  log "Node.js 已安装: $(node -v)"
else
  warn "Node.js 未安装"
  info "通过 nvm 安装 Node.js LTS..."
  export NVM_DIR="${HOME}/.nvm"
  # shellcheck source=/dev/null
  if [ -s "$NVM_DIR/nvm.sh" ]; then
    source "$NVM_DIR/nvm.sh"
    nvm install --lts && nvm use --lts
  else
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
    export NVM_DIR="${HOME}/.nvm"
    # shellcheck source=/dev/null
    [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
    nvm install --lts && nvm use --lts
  fi
  log "Node.js LTS: $(node -v)"
fi

# ════════════════════════════════════════════════════════
# Step 2 — 安装 OpenCode CLI
# ════════════════════════════════════════════════════════
section "Step 2/7 · 安装 OpenCode CLI"

if command -v opencode &>/dev/null; then
  log "OpenCode CLI 已安装: $(opencode --version 2>/dev/null || echo 'ok')"
else
  info "npm install -g opencode@latest ..."
  npm install -g opencode@latest 2>&1 | tail -1
  command -v opencode &>/dev/null || panic "OpenCode CLI 安装失败" 1
  log "OpenCode CLI 安装完成"
fi

# ════════════════════════════════════════════════════════
# Step 3 — 创建配置目录
# ════════════════════════════════════════════════════════
section "Step 3/7 · 创建配置目录"

if [ -d "$CONFIG_DIR" ] && { [ -d "${CONFIG_DIR}/skills" ] || [ -d "${CONFIG_DIR}/skill-libraries" ]; }; then
  warn "检测到已有 OpenCode 配置"
  if [ "$INTERACTIVE" = true ]; then
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
  else
    info "非交互模式，保留现有配置。如需覆盖请使用交互模式。"
    SKIP_SKILLS=true
  fi
fi
SKIP_SKILLS="${SKIP_SKILLS:-false}"

mkdir -p "$CONFIG_DIR"
log "配置目录: ${CONFIG_DIR}"

# ════════════════════════════════════════════════════════
# Step 4 — 写入配置文件 (API Key 已注入)
# ════════════════════════════════════════════════════════
section "Step 4/7 · 写入配置文件"

# 检测是否有本地 config-templates/ 目录 (git clone 安装模式)
# 如果有模板文件则使用它们, 否则回退到内置 heredocs
USE_TEMPLATES=false
if [ -n "$SCRIPT_DIR" ] && [ -d "${SCRIPT_DIR}/config-templates" ]; then
  if [ -f "${SCRIPT_DIR}/config-templates/opencode.jsonc" ]; then
    USE_TEMPLATES=true
  fi
fi

# ── opencode.jsonc (仅 DeepSeek, Key 已注入) ──────────
if [ "$USE_TEMPLATES" = true ]; then
  info "使用 config-templates/ 模板..."
  # 转义 API Key 中的特殊字符, 防止 sed 替换异常
  ESCAPED_KEY=$(printf '%s' "$DEEPSEEK_KEY" | sed 's/[&/\]/\\&/g')
  sed "s|\${DEEPSEEK_KEY}|${ESCAPED_KEY}|g" \
    "${SCRIPT_DIR}/config-templates/opencode.jsonc" \
    > "${CONFIG_DIR}/opencode.jsonc" || panic "写入 opencode.jsonc 失败" 3
else
  cat > "${CONFIG_DIR}/opencode.jsonc" << EOF
{
  "\$schema": "https://opencode.ai/config.json",
  "plugin": [
    "oh-my-openagent@latest",
    "opencode-skill-creator@latest"
  ],
  "model": "deepseek/deepseek-v4-pro",
  "small_model": "deepseek/deepseek-v4-flash",
  "provider": {
    "deepseek": {
      "options": {
        "apiKey": "${DEEPSEEK_KEY}",
        "timeout": 600000,
        "chunkTimeout": 60000
      }
    }
  }
}
EOF
fi

if [ "$KEY_CONFIGURED" = true ]; then
  log "opencode.jsonc     — DeepSeek Key 已自动填入 ✓"
else
  warn "opencode.jsonc     — 占位符，请手动编辑填入 Key"
fi

# ── oh-my-openagent.jsonc ──────────────────────────────
if [ "$USE_TEMPLATES" = true ] && [ -f "${SCRIPT_DIR}/config-templates/oh-my-openagent.jsonc" ]; then
  cp "${SCRIPT_DIR}/config-templates/oh-my-openagent.jsonc" \
    "${CONFIG_DIR}/oh-my-openagent.jsonc" || panic "写入 oh-my-openagent.jsonc 失败" 3
else
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
    "multimodal-looker": { "model": "deepseek/deepseek-v4-flash" },
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
fi
log "oh-my-openagent.jsonc — 全部 Agent 统一 DeepSeek"

# ── tui.json ───────────────────────────────────────────
if [ "$USE_TEMPLATES" = true ] && [ -f "${SCRIPT_DIR}/config-templates/tui.json" ]; then
  cp "${SCRIPT_DIR}/config-templates/tui.json" \
    "${CONFIG_DIR}/tui.json" || panic "写入 tui.json 失败" 3
else
  cat > "${CONFIG_DIR}/tui.json" << 'EOF'
{
  "$schema": "https://opencode.ai/tui.json",
  "plugin": ["oh-my-openagent@latest"],
  "theme": "tokyonight"
}
EOF
fi
log "tui.json           — 主题 tokyonight"

# ════════════════════════════════════════════════════════
# Step 5 — 下载并解压技能库
# ════════════════════════════════════════════════════════
section "Step 5/7 · 安装技能库 (1913 技能 + 99 入口 + 3 规则)"

if [ "$SKIP_SKILLS" = true ]; then
  log "跳过技能库安装 (保留现有)"
else
  # 保存 local/ 目录 (如存在并有内容), 解压后恢复, 防止覆盖用户自定义
  LOCAL_BACKUP=""
  if [ -d "${CONFIG_DIR}/local" ] && ls -A "${CONFIG_DIR}/local/" >/dev/null 2>&1; then
    LOCAL_BACKUP="$(mktemp -d)"
    cp -r "${CONFIG_DIR}/local" "$LOCAL_BACKUP/"
    info "local/ 目录已保存, 解压后将恢复以保留自定义文件"
  fi

  if [ -n "$ARCHIVE_SOURCE" ] && [ -f "$ARCHIVE_SOURCE" ]; then
    info "使用本地技能包: ${ARCHIVE_SOURCE}"
    ARCHIVE_PATH="$ARCHIVE_SOURCE"
  else
    TEMP_DIR=$(mktemp -d)
    ARCHIVE_PATH="${TEMP_DIR}/opencode-skills.tar.gz"

    # 根据是否指定版本选择下载 URL
    if [ -n "$VERSION" ]; then
      RELEASE_URL="https://github.com/${REPO}/releases/download/${VERSION}/opencode-skills.tar.gz"
    else
      RELEASE_URL="https://github.com/${REPO}/releases/latest/download/opencode-skills.tar.gz"
    fi

    info "从 GitHub Release 下载技能包 (33MB)..."
    info "URL: ${RELEASE_URL}"

    # 带重试的下载
    if curl -fSL --progress-bar --retry 3 --retry-delay 5 --retry-max-time 120 \
      -o "$ARCHIVE_PATH" "$RELEASE_URL"; then
      log "下载完成 ($(du -h "$ARCHIVE_PATH" | cut -f1))"
    else
      # 尝试跟随重定向作为后备方案
      DL_URL=$(curl -sI "$RELEASE_URL" | grep -i '^location:' | awk '{print $2}' | tr -d '\r')
      if [ -n "$DL_URL" ]; then
        curl -fSL --progress-bar --retry 3 --retry-delay 5 --retry-max-time 120 \
          -o "$ARCHIVE_PATH" "$DL_URL" || panic "下载失败，请检查网络" 2
        log "下载完成 ($(du -h "$ARCHIVE_PATH" | cut -f1))"
      else
        panic "无法下载技能包。请检查网络或手动下载。" 2
      fi
    fi

    # ── SHA256 校验 ────────────────────────────────────
    CHECKSUM_URL="${RELEASE_URL}.sha256"
    CHECKSUM_PATH="${TEMP_DIR}/opencode-skills.tar.gz.sha256"
    info "下载 SHA256 校验文件..."
    if curl -fSL --retry 3 --retry-delay 5 --retry-max-time 60 \
      -o "$CHECKSUM_PATH" "$CHECKSUM_URL" 2>/dev/null; then
      info "校验文件下载成功, 正在验证..."
      pushd "$TEMP_DIR" > /dev/null
      if sha256sum -c "opencode-skills.tar.gz.sha256" 2>/dev/null; then
        log "SHA256 校验通过 ✓"
      else
        EXPECTED=$(cat "$CHECKSUM_PATH" 2>/dev/null | awk '{print $1}')
        ACTUAL=$(sha256sum "$ARCHIVE_PATH" 2>/dev/null | awk '{print $1}')
        warn "SHA256 校验失败!"
        warn "  期望: ${EXPECTED:-未知}"
        warn "  实际: ${ACTUAL:-无法计算}"
        warn "  将继续安装 (不推荐), 按 Ctrl+C 中止或等待继续..."
        sleep 3
      fi
      popd > /dev/null
    else
      warn "无法下载 SHA256 校验文件, 跳过校验 (不推荐)"
    fi
  fi

  info "解压到 ${CONFIG_DIR}..."
  tar xzf "$ARCHIVE_PATH" -C "${CONFIG_DIR}/" 2>/dev/null \
    || panic "技能包解压失败, 请检查磁盘空间或文件完整性" 4
  log "技能包解压完成"

  # ── 恢复 local/ 目录 ─────────────────────────────────
  if [ -n "$LOCAL_BACKUP" ] && [ -d "$LOCAL_BACKUP/local" ]; then
    if [ -d "${CONFIG_DIR}/local" ]; then
      rm -rf "${CONFIG_DIR}/local"
    fi
    cp -r "$LOCAL_BACKUP/local" "${CONFIG_DIR}/local"
    rm -rf "$LOCAL_BACKUP"
    log "local/ 自定义目录已恢复 ✓"
  fi
fi

# ── local/ 目录检测提示 ──────────────────────────────
if [ -d "${CONFIG_DIR}/local" ] && ls -A "${CONFIG_DIR}/local/" >/dev/null 2>&1; then
  info "检测到 local/ 自定义目录, 其中的文件不会被后续安装覆盖"
fi

# ════════════════════════════════════════════════════════
# Step 6 — 安装插件
# ════════════════════════════════════════════════════════
section "Step 6/7 · 安装插件"

info "安装 oh-my-openagent..."
if opencode plugin install oh-my-openagent@latest 2>/dev/null; then
  log "oh-my-openagent ✓"
else
  warn "可稍后手动安装: opencode plugin install oh-my-openagent@latest"
fi

info "安装 opencode-skill-creator..."
if opencode plugin install opencode-skill-creator@latest 2>/dev/null; then
  log "opencode-skill-creator ✓"
else
  warn "可稍后手动安装: opencode plugin install opencode-skill-creator@latest"
fi

# ════════════════════════════════════════════════════════
# Step 6.5 — 修复 codegraph MCP
# ════════════════════════════════════════════════════════
section "Step 6.5/7 · 修复 codegraph MCP 捆绑 Node 缺失"

if [ -f "${HOME}/.omo/codegraph/bin/codegraph" ] && [ ! -f "${HOME}/.omo/codegraph/lib/node" ]; then
  info "检测到 codegraph 捆绑 Node 缺失，创建软链接..."
  ln -sf "$(command -v node)" "${HOME}/.omo/codegraph/lib/node"
  log "codegraph MCP: node 软链接已创建 ✓"
else
  log "codegraph MCP: 无需修复 ✓"
fi

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
echo -e "  ${BOLD}${GREEN}║${NC}   ${BOLD}安装完成！一条命令，全部到位。${NC}                 ${BOLD}${GREEN}║${NC}"
echo -e "  ${BOLD}${GREEN}║${NC}                                                  ${BOLD}${GREEN}║${NC}"

if [ "$KEY_CONFIGURED" = true ]; then
  echo -e "  ${BOLD}${GREEN}║${NC}   ${GREEN}✓ API Key 已配置，开箱即用。${NC}                    ${BOLD}${GREEN}║${NC}"
else
  echo -e "  ${BOLD}${GREEN}║${NC}   ${YELLOW}⚠ 请编辑 ~/.config/opencode/opencode.jsonc${NC}       ${BOLD}${GREEN}║${NC}"
  echo -e "  ${BOLD}${GREEN}║${NC}   ${YELLOW}   替换 YOUR_DEEPSEEK_API_KEY_HERE${NC}              ${BOLD}${GREEN}║${NC}"
fi

echo -e "  ${BOLD}${GREEN}║${NC}                                                  ${BOLD}${GREEN}║${NC}"
echo -e "  ${BOLD}${GREEN}╠══════════════════════════════════════════════════╣${NC}"
echo -e "  ${BOLD}${GREEN}║${NC}                                                  ${BOLD}${GREEN}║${NC}"
echo -e "  ${BOLD}${GREEN}║${NC}  验证:                                           ${BOLD}${GREEN}║${NC}"
echo -e "  ${BOLD}${GREEN}║${NC}    ${CYAN}opencode \"hello world\"${NC}                      ${BOLD}${GREEN}║${NC}"
echo -e "  ${BOLD}${GREEN}║${NC}                                                  ${BOLD}${GREEN}║${NC}"
echo -e "  ${BOLD}${GREEN}║${NC}  后续如需加 Google/其他 provider:                ${BOLD}${GREEN}║${NC}"
echo -e "  ${BOLD}${GREEN}║${NC}    ${CYAN}vim ~/.config/opencode/opencode.jsonc${NC}          ${BOLD}${GREEN}║${NC}"
echo -e "  ${BOLD}${GREEN}║${NC}                                                  ${BOLD}${GREEN}║${NC}"
echo -e "  ${BOLD}${GREEN}║${NC}  新机器一键安装:                                 ${BOLD}${GREEN}║${NC}"
echo -e "  ${BOLD}${GREEN}║${NC}    ${CYAN}curl -fsSL .../install.sh | bash -s -- sk-xxx${NC} ${BOLD}${GREEN}║${NC}"
echo -e "  ${BOLD}${GREEN}║${NC}                                                  ${BOLD}${GREEN}║${NC}"
echo -e "  ${BOLD}${GREEN}╚══════════════════════════════════════════════════╝${NC}"
echo ""

exit $HAS_ERROR
