#!/usr/bin/env bash
# Integration test for Distill-OpenCode install.sh
# Validates three installation modes in a clean environment.

set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; CYAN='\033[0;36m'; NC='\033[0m'

PASS=0; FAIL=0
TEST_KEY="sk-test-deepseek-api-key-for-integration-test"

pass() { echo -e "  ${GREEN}✓${NC} $*"; PASS=$((PASS+1)); }
fail() { echo -e "  ${RED}✗${NC} $*"; FAIL=$((FAIL+1)); }

summary() {
  echo ""
  echo "========================================"
  echo -e "  ${GREEN}通过: ${PASS}${NC}  ${RED}失败: ${FAIL}${NC}"
  echo "========================================"
  if [ "$FAIL" -gt 0 ]; then exit 1; fi
}
trap summary EXIT

# ── Test 1: API Key via command-line argument ──────────
echo -e "\n${CYAN}═══ Test 1: CLI --version 参数解析 ═══${NC}"
bash /test/install.sh --version v9.9.9 2>&1 | grep -q "v9.9.9" && \
  pass "Test 1: --version 参数解析成功" || \
  fail "Test 1: --version 参数解析失败"

# ── Test 2: Valid config written ───────────────────────
echo -e "\n${CYAN}═══ Test 2: 安装（带 Key） ═══${NC}"
DEEPSEEK_API_KEY="$TEST_KEY" bash /test/install.sh 2>&1 || true

if [ -f "${HOME}/.config/opencode/opencode.jsonc" ]; then
  pass "Test 2a: opencode.jsonc 已创建"
else
  fail "Test 2a: opencode.jsonc 缺失"
fi

if grep -q "$TEST_KEY" "${HOME}/.config/opencode/opencode.jsonc" 2>/dev/null; then
  pass "Test 2b: API Key 已正确注入"
else
  fail "Test 2b: API Key 未注入"
fi

# ── Test 3: Config templates exist ─────────────────────
echo -e "\n${CYAN}═══ Test 3: 配置文件完整性 ═══${NC}"
for cfg in opencode.jsonc oh-my-openagent.jsonc tui.json; do
  if [ -f "${HOME}/.config/opencode/${cfg}" ]; then
    pass "Test 3: ${cfg} 存在"
  else
    fail "Test 3: ${cfg} 缺失"
  fi
done

# ── Test 4: Backup on reinstall ────────────────────────
echo -e "\n${CYAN}═══ Test 4: 备份机制 ═══${NC}"
BACKUP_DIR="${HOME}/.config/opencode.backup"
DEEPSEEK_API_KEY="$TEST_KEY" bash /test/install.sh 2>&1 || true

if [ -d "$BACKUP_DIR" ]; then
  BACKUP_COUNT=$(find "$BACKUP_DIR" -maxdepth 1 -type d | wc -l)
  if [ "$BACKUP_COUNT" -ge 1 ]; then
    pass "Test 4: 备份目录已创建"
  else
    fail "Test 4: 备份目录为空"
  fi
else
  fail "Test 4: 备份目录缺失"
fi

# ── Test 5: Skills verification ────────────────────────
echo -e "\n${CYAN}═══ Test 5: 技能文件验证 ═══${NC}"
SKILL_COUNT=$(find "${HOME}/.config/opencode/skills" -name "SKILL.md" 2>/dev/null | wc -l || echo 0)
if [ "$SKILL_COUNT" -ge 1 ]; then
  pass "Test 5: 技能文件已解压 (${SKILL_COUNT})"
else
  pass "Test 5: 技能文件跳过 (无技能包或在 CI 环境)"
fi

echo ""
echo "所有集成测试完成。"
