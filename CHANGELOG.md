# Changelog

All notable changes to Distill OpenCode will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/).

---

## [Unreleased]

### Added
- `CHANGELOG.md` — 版本变更记录

---

## [0.4.0] - 2026-08-09

### Added
- **install.sh 可靠性增强**：下载自动重试（3 次）、SHA256 文件校验和验证
- **install.sh 安装前自动备份**：覆盖 `~/.config/opencode/` 前备份到 `~/.config/opencode.backup/`
- **install.sh `--version` 参数**：支持安装指定 Release 版本
- **install.sh `--quiet` / `-q` 参数**：安静模式，只输出错误信息
- **install.sh `local/` 目录保护**：用户自定义目录不被覆盖
- **install.sh 细分退出码**：1=依赖 2=下载 3=配置 4=解压
- **config-templates/ 目录**：配置文件模板，支持从 git clone 安装时读取
- **docs/QUICKSTART.md**：5 分钟快速体验指南 + 常见问题解答
- **CONTRIBUTING.md**：贡献指南（如何提交技能、报告 Bug、发起 PR）
- **`.github/ISSUE_TEMPLATE/`**：Bug 报告和功能建议模板
- **`.github/PULL_REQUEST_TEMPLATE.md`**：PR 模板
- **`.github/workflows/ci.yml`**：ShellCheck + markdownlint 自动检查
- **`.github/workflows/release.yml`**：打 tag 自动打包 + SHA256 + GitHub Release
- **SKILL_TEMPLATE.md**：SKILL.md 格式规范
- **SKILL_INDEX.md**：技能分类体系参考
- **scripts/generate-skill-index.sh**：技能索引生成器
- **tests/**：Docker 集成测试环境

### Changed
- 命令行参数从简单的 `$1` 改为完整参数解析（支持 `--version`、`--quiet`）
- `A && B || C` 模式改为标准 `if-else` 结构
- 信号处理增强（INT/TERM/HUP/PIPE）

### Fixed
- codegraph MCP 捆绑 Node 缺失问题

---

## [0.3.0] - 2026-08-07

### Fixed
- 修复 codegraph MCP 捆绑 Node 缺失，安装后自动创建软链接

---

## [0.2.0] - 2026-08-06

### Added
- API Key 自动注入功能 — 安装后 `opencode.jsonc` 中 Key 直接可用
- 支持三种 Key 传入方式：命令行参数、环境变量 `DEEPSEEK_API_KEY`、交互式输入
- 全部 Agent 统一使用 DeepSeek（Pro 推理 / Flash 执行）
- `oh-my-openagent.jsonc` 和 `tui.json` 配置文件

---

## [0.1.0] - 2026-08-06

### Added
- 初始版本 — 一键安装 Sisyphus 同款 OpenCode 配置
- 一条命令安装：`curl | bash -s -- sk-xxx`
- 1913 个技能库 + 99 个入口技能 + 3 条全局规则
- `README.md`、`LICENSE`（MIT）
