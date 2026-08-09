# Distill OpenCode

> 蒸馏 Sisyphus 同款 OpenCode 配置 — 一条命令，完整复刻，开箱即用。

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Skills](https://img.shields.io/badge/Skills-1913-blue)](https://github.com/panzhaohu666/Distill-OpenCode/releases)
[![Entry Points](https://img.shields.io/badge/Entry%20Points-99-green)](https://github.com/panzhaohu666/Distill-OpenCode/releases)

---

## 一键安装

### 方式一：带 Key 一键到位（推荐）

```bash
curl -fsSL https://raw.githubusercontent.com/panzhaohu666/Distill-OpenCode/main/install.sh | bash -s -- sk-your-deepseek-api-key
```

### 方式二：环境变量

```bash
export DEEPSEEK_API_KEY="sk-your-key"
curl -fsSL https://raw.githubusercontent.com/panzhaohu666/Distill-OpenCode/main/install.sh | bash
```

### 方式三：交互式（会询问 Key）

```bash
curl -fsSL https://raw.githubusercontent.com/panzhaohu666/Distill-OpenCode/main/install.sh -o install.sh
bash install.sh
```

> **只需一个 DeepSeek API Key**。全部 Agent 统一使用 DeepSeek，无需 Google 或其他 provider。
> 获取 Key：[platform.deepseek.com/api_keys](https://platform.deepseek.com/api_keys)

---

## 安装了什么？

| 组件 | 数量 | 说明 |
|------|------|------|
| **入口技能** | 99 | 按领域分类（AI/ML、开发、安全、云、移动…）|
| **技能库** | 1913 | 完整 SKILL.md，含模板、脚本、参考文档 |
| **全局规则** | 3 | 代码质量规范 · Git 工作流 · 自我进化宣言 |
| **Agent 模型** | 全部 DeepSeek | Pro 推理 / Flash 执行，无需额外 provider |
| **插件** | 2 | oh-my-openagent + opencode-skill-creator |
| **主题** | 1 | tokyonight |

### 配置架构

```
推理层 (Pro)             执行层 (Flash)
──────────────────────   ──────────────────────
oracle                   sisyphus-junior
metis                    explore
momus                    librarian
prometheus               quick
hephaestus               unspecified-*
ultrabrain               visual-engineering
deep                     writing
artistry                 multimodal-looker
```

全部统一使用 DeepSeek，一个 Key 搞定一切。

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

脚本自动安装缺失依赖（curl、git、Node.js）。

---

## 验证

```bash
opencode "hello world"
```

> 查看 [快速体验指南](docs/QUICKSTART.md) 了解更多使用示例和常见问题解答。

---

## 后续加其他 Provider（可选）

如需添加 Google Gemini、OpenAI 等，编辑配置：

```bash
vim ~/.config/opencode/opencode.jsonc
```

```jsonc
"provider": {
  "deepseek": {
    "options": { "apiKey": "sk-xxx", ... }
  },
  // 添加其他 provider:
  "google": {
    "options": { "apiKey": "your-google-key" }
  }
}
```

同步在 `oh-my-openagent.jsonc` 中修改对应 agent 的 model。

---

## 更新

重新运行安装脚本获取最新技能包：

```bash
curl -fsSL https://raw.githubusercontent.com/panzhaohu666/Distill-OpenCode/main/install.sh | bash -s -- sk-your-key
```

---

## 目录结构

安装后 `~/.config/opencode/`：

```
~/.config/opencode/
├── opencode.jsonc              # 主配置（模型、provider、API Key）
├── oh-my-openagent.jsonc       # Agent/Category 模型分配（全 DeepSeek）
├── tui.json                    # 终端主题 (tokyonight)
├── rules/                      # 全局规则（3 个 .md）
│   ├── code-quality.md
│   ├── git-workflow.md
│   └── omo-self-evolution.md
├── skills/                     # 入口技能（99 个 category-pointer）
├── skill-libraries/            # 技能库（1913 个完整 SKILL.md）
└── opencode-skill-creator-update-check.json
```

---

## 参与贡献

欢迎提交 Issue 和 PR！详见 [CONTRIBUTING.md](CONTRIBUTING.md)。

添加新技能请参考 [SKILL_TEMPLATE.md](SKILL_TEMPLATE.md)。

---

## License

MIT
