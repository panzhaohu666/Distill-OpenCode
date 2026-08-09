# 参与贡献指南

感谢你愿意为 **Distill OpenCode** 添砖加瓦。这是一个一键安装脚本，把 Sisyphus 同款的 OpenCode 配置（1913 个技能、99 个入口、3 条规则）完整复刻到你的机器上。项目本身很薄：一个 `install.sh` + 一堆 markdown 技能。所以贡献的门槛也很低，会写 markdown 就能参与。

> 项目的沟通语言是中文，Issue、PR、评论请尽量使用中文。

---

## 我能贡献什么？

| 方向 | 适合谁 |
|------|--------|
| 提交新技能 | 想分享自己写的好用技能 |
| 修 bug | 安装脚本出问题、某个技能挂了 |
| 提功能建议 | 有想法但暂时不想动手写 |
| 改文档 | 想优化 README、本指南或其他文档 |

---

## 开发环境搭建

```bash
git clone https://github.com/panzhaohu666/Distill-OpenCode.git
cd Distill-OpenCode
```

项目结构：
```text

Distill-OpenCode/
├── install.sh                 # 一键安装脚本（bash）
├── README.md                  # 项目说明
├── docs/                      # 文档（快速上手等）
├── config-templates/          # 配置文件模板
├── .github/                   # Issue / PR 模板、CI
│   ├── ISSUE_TEMPLATE/
│   └── PULL_REQUEST_TEMPLATE.md
└── tests/                     # 安装脚本测试（Docker + shell）
```

改完代码后，想本地验证？

```bash
bash install.sh              # 交互式安装，会询问 API Key
bash install.sh sk-your-key  # 带 Key 一键安装
```

更稳妥的做法是先在 Docker 里跑测试：

```bash
docker build -t distill-test tests/
docker run --rm -it distill-test
```

> ⚠️ 注意：`install.sh` 会直接写入 `~/.config/opencode/`。如果想在真机上测试又不想覆盖现有配置，先备份一份 `~/.config/opencode`。

---

## 提交一个新技能

技能是这个项目的核心资产。提交前先想清楚：**这个技能解决什么问题？别人搜什么词会想起它？** 想清楚了再看格式。

### SKILL.md 的基本格式

每个技能都是 `SKILL.md` 文件，开头必须有 YAML frontmatter：

```markdown
---
name: skill-name
description: "用一句话描述这个技能做什么、什么时候用。要包含触发关键词。"
category: 所属分类（可选，如 writing / security / ai-ml）
---
```

frontmatter 里最关键的是 `name` 和 `description`：

- **name**：技能名，小写连字符命名（如 `git-workflow`）。
- **description**：OpenCode 靠它来决定什么时候调用你的技能。要写清楚"做什么"和"什么时候用"，别写空话。建议带上触发词，比如"Use when working on X-related tasks"。

frontmatter 之后是正文，用标准 markdown 写清楚：

- 技能是干什么的
- 什么时候该用
- 怎么用（步骤、示例）
- 注意事项 / 坑

### 两种技能形态

项目里技能分两类，放的位置不一样：

| 形态 | 说明 | 放哪里 |
|------|------|--------|
| **category-pointer**（入口技能） | 轻量指针，列出某个分类下有哪些技能，引导去加载对应的完整技能 | `skills/` |
| **完整 SKILL.md**（技能库） | 完整自包含的技能，含模板、脚本、参考文档 | `skill-libraries/` |

如果你写的是分类下的某个具体技能，放在 `skill-libraries/<分类>/<技能名>/SKILL.md`；如果是给某个新分类建入口，放在 `skills/<分类>-category-pointer/SKILL.md`。

拿不准放哪？看现有例子：

- 入口技能示例：[`skills/ai-category-pointer/SKILL.md`](https://github.com/panzhaohu666/Distill-OpenCode/tree/main/skills/ai-category-pointer) —— 一个典型的 category-pointer，正文列出该分类下的技能清单和加载方式。
- 完整技能示例：`skill-libraries/writing/bulletmind/SKILL.md` —— 完整技能，frontmatter 更丰富（含 `category`、`tags`、`tools` 等可选字段）。

### 提交步骤

1. 在 `skills/` 或 `skill-libraries/` 下建好目录和 `SKILL.md`。
2. 本地验证技能能被识别：安装后 `opencode` 里能搜到、能触发。
3. 按下面的 PR 流程提交。

---

## 报告 Bug

遇到问题？先去 [GitHub Issues](https://github.com/panzhaohu666/Distill-OpenCode/issues) 搜一搜，看是不是已经有人报过了。没有的话，新建一个 Issue。

新建 Issue 时选 **Bug 报告** 模板（[`bug_report.md`](.github/ISSUE_TEMPLATE/bug_report.md)），尽量填全这几项：

- **环境信息**：操作系统、安装方式、`opencode --version` 输出
- **问题描述**：发生了什么
- **复现步骤**：怎么一步步复现
- **期望行为**：你觉得应该怎样
- **错误日志**：把报错信息贴出来

好 Issue 的标准：别人照着你的复现步骤能 100% 复现。

---

## 提功能建议

有想法了？同样去 [GitHub Issues](https://github.com/panzhaohu666/Distill-OpenCode/issues)，新建 Issue 时选 **功能建议** 模板（[`feature_request.md`](.github/ISSUE_TEMPLATE/feature_request.md)）。

建议模板里最值得花心思的两栏：

- **使用场景**：这个功能解决什么问题、谁会在什么场景用到。这比功能本身更能说服维护者。
- **期望效果**：功能应该怎么工作，越具体越好。

> 小提示：与其只写"希望有个 XX 技能"，不如直接动手写一个——技能是 markdown，门槛低到你不需要会编程。写好了按"提交一个新技能"的流程走即可。

---

## 提 PR 的流程

流程很简单：Fork → 建分支 → 改代码 → 跑检查 → 提 PR。

1. **Fork 并克隆**

   ```bash
   git clone https://github.com/你的用户名/Distill-OpenCode.git
   cd Distill-OpenCode
   git remote add upstream https://github.com/panzhaohu666/Distill-OpenCode.git
   ```

2. **建分支**，分支名要能看出改了什么：

   ```bash
   git checkout -b fix/install-bug     # 修 bug
   git checkout -b feat/new-skill      # 加技能
   git checkout -b docs/contributing   # 改文档
   ```

3. **做修改**。改了 `install.sh` 的话，提交前必须过一遍 ShellCheck：

   ```bash
   shellcheck install.sh
   ```

   没有 ShellCheck？`apt install shellcheck` 或 `brew install shellcheck` 装一下。这是硬性要求，`install.sh` 的任何变更都要 ShellCheck 通过，否则 CI 会直接红。

4. **本地测试**：按"开发环境搭建"一节跑一遍安装，确保改动没把安装流程搞坏。

5. **提交并推送**

   ```bash
   git add .
   git commit -m "feat: 清晰描述你的改动"
   git push origin 你的分支名
   ```

6. **提交 PR**：到 GitHub 上对 `main` 分支发起 Pull Request。会自动带上 [`.github/PULL_REQUEST_TEMPLATE.md`](.github/PULL_REQUEST_TEMPLATE.md) 模板，把"变更摘要"和"变更动机"写清楚，勾掉测试和检查清单。

### 几个不成文的规矩

- **一个 PR 只做一件事**。混着改（比如顺便格式化了一堆无关文件）会拖慢审查。
- **commit message 说人话**：`feat:`、`fix:`、`docs:` 前缀 + 一句人话描述。参考现有 commit 的风格。
- **CI 要绿**：PR 里会跑 CI（ShellCheck + 测试），红了先自己查。
- **耐心等审查**：维护者可能会让你改，正常现象，改完再 push 就行。

---

## 技能质量要求

想让你提交的技能被合并（而不是被拒），请对照这份自查清单：

1. **README 级别的文档**。别只写一句 description 就完事。正文要说清楚：技能干什么、什么时候用、怎么用、有哪些注意事项。一个合格的 SKILL.md 应当让完全没接触过的人照着就能跑起来。

2. **清晰的触发词**。`description` 里明确写出适用场景和触发关键词。OpenCode 是按 description 匹配来调用技能的，写得模糊 = 永远没人用到你的技能。

3. **规范的 markdown**。frontmatter 格式正确、标题层级清晰、代码块标注语言。别用四不像的格式。

4. **参考成熟例子**。动手前先看看 `skills/` 和 `skill-libraries/` 里已有的技能，尤其是你所在分类的同类技能。风格对齐，合并概率会高很多。

5. **能自圆其说**。技能声称自己会做某事，就得真的做到。宁缺毋滥——一个不靠谱的技能比没有更糟，因为它可能被错误触发。

如果只是小改动（错别字、链接失效、一句话补充），直接提 PR 就行，不用先开 Issue。

---

## 其他问题

文档里没覆盖到？去 [GitHub Issues](https://github.com/panzhaohu666/Distill-OpenCode/issues) 开一个，或者直接在相关 PR 下留言。再次感谢你的贡献 🙌
