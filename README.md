# Distill OpenCode

> 蒸馏 Sisyphus 同款 OpenCode 配置 — 一行命令，完整复刻。

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Skills](https://img.shields.io/badge/Skills-1913-blue)](https://github.com/panzhaohu666/Distill-OpenCode/releases)
[![Entry Points](https://img.shields.io/badge/Entry%20Points-99-green)](https://github.com/panzhaohu666/Distill-OpenCode/releases)

---

## 一键安装

```bash
curl -fsSL https://raw.githubusercontent.com/panzhaohu666/Distill-OpenCode/main/install.sh | bash
```

**安装后唯一手动步骤**：编辑 `~/.config/opencode/opencode.jsonc`，填入你的 API Key。

---

## 安装了哪些内容？

| 组件 | 数量 | 说明 |
|------|------|------|
| **入口技能** | 99 | 按领域分类（AI/ML、开发、安全、云、移动…）|
| **技能库** | 1913 | 完整 SKILL.md，含模板、脚本、参考文档 |
| **全局规则** | 3 | 代码质量规范 · Git 工作流 · 自我进化宣言 |
| **Agent 模型分配** | 10 agents + 8 categories | Pro 推理 / Flash 执行，按任务难度分派 |
| **插件** | 2 | oh-my-openagent + opencode-skill-creator |
| **主题** | 1 | tokyonight |

### 配置架构

```
推理层 (Pro)        执行层 (Flash)        专项
─────────────────   ─────────────────     ─────────────────
oracle              sisyphus-junior        multimodal-looker
metis               explore                (Google Gemini)
momus               librarian
prometheus           quick
hephaestus           unspecified-*
ultrabrain           visual-engineering
deep                 writing
artistry
```

### 技能库覆盖领域

| 领域 | 技能数 | 代表性技能 |
|------|--------|-----------|
| AI/ML | 128 | loki-mode, prompt-engineering-patterns, hugging-face-* |
| 开发 | 170 | go-*, python-*, rust-*, senior-architect |
| 安全 | 81 | container-security-hardening, stride-analysis, 007 |
| 云服务 | 145 | k8s-*, terraform-module-library, vercel-optimize |
| 前端/设计 | 48 风格 | glassmorphism, neo-brutalism, cyberpunk, minimalism |
| 移动端 | 30 | expo-*, swiftui-*, android-dev |
| 自动化 | 49 | apify-*, cicd-automation |
| 其他 | 1300+ | 法律、金融、健康、营销、游戏开发… |

---

## 前提条件

- **操作系统**: Linux / macOS（Windows WSL 亦可）
- **磁盘空间**: ≥ 500MB
- **网络**: 可访问 GitHub 和 npm registry

脚本会自动安装缺失的依赖（curl、git、Node.js）。

---

## 配置 API Key

安装完成后编辑配置文件：

```bash
vim ~/.config/opencode/opencode.jsonc
```

替换两处占位符：

```jsonc
"deepseek": {
  "options": {
    "apiKey": "sk-your-deepseek-key"   // ← 替换这里
  }
},
"google": {
  "options": {
    "apiKey": "your-google-key"         // ← 替换这里（可选）
  }
}
```

Google API Key 仅用于 `multimodal-looker`（图片/PDF 分析），不提供则不影响主要功能。

---

## 验证

```bash
opencode "hello world"
```

---

## 更新

技能包随 Release 更新。重新运行安装脚本即可获取最新技能：

```bash
curl -fsSL https://raw.githubusercontent.com/panzhaohu666/Distill-OpenCode/main/install.sh | bash
```

---

## 目录结构

安装后 `~/.config/opencode/` 的完整结构：

```
~/.config/opencode/
├── opencode.jsonc              # 主配置（模型、provider、插件）
├── oh-my-openagent.jsonc       # Agent/Category 模型分配
├── tui.json                    # 终端主题
├── rules/                      # 全局规则（3 个 .md）
│   ├── code-quality.md         #   代码质量规范（命名、错误处理、测试）
│   ├── git-workflow.md         #   Git 工作流（分支、commit、PR 规范）
│   └── omo-self-evolution.md   #   自我进化宣言（沉淀、分层、TDD）
├── skills/                     # 入口技能（99 个 category-pointer）
│   ├── ai-ml-category-pointer/
│   ├── backend-category-pointer/
│   ├── frontend-category-pointer/
│   └── ... (共 99 个)
├── skill-libraries/            # 技能库（1913 个完整 SKILL.md）
│   ├── ai-ml/                  #   128 个 AI/ML 技能
│   ├── development/            #   170 个开发技能
│   ├── security/               #   81 个安全技能
│   ├── cloud/                  #   145 个云服务技能
│   ├── frontend/design-it/     #   48 种设计风格
│   └── ... (按领域分类)
└── opencode-skill-creator-update-check.json
```

---

## License

MIT
