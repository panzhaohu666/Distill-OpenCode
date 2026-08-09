# 5 分钟快速体验

安装 Distill OpenCode 后，你将拥有 Sisyphus 同款的 AI 编程配置——1913 个技能、99 个入口、开箱即用。

---

## 第一步：安装

```bash
curl -fsSL https://raw.githubusercontent.com/panzhaohu666/Distill-OpenCode/main/install.sh | bash -s -- sk-your-deepseek-api-key
```

> API Key 获取：[platform.deepseek.com/api_keys](https://platform.deepseek.com/api_keys)

安装完成后看到 `安装完成！一条命令，全部到位。` 即表示成功。

---

## 第二步：验证

```bash
opencode "hello world"
```

如果正常启动 TUI 界面，说明一切就绪。

---

## 第三步：试试这些例子

### 写代码

```bash
opencode "用 Python 写一个快速排序算法，带详细的注释"
```

### 调试

```bash
opencode "帮我分析这段代码为什么报 segmentation fault"
```

### 写测试

```bash
opencode "为 src/utils/auth.ts 写单元测试"
```

### 代码审查

```bash
opencode "review 当前仓库最近的 5 个 commit"
```

### 重构
```bash
opencode "把 src/ 下的 console.log 替换成 logger.info"
```

---

## 第四步：了解你的技能库

运行 `opencode` 进入 TUI 后，你的 Agent 已经加载了 1913 个专业技能，涵盖：

| 领域 | 技能数 | 用途 |
|---|---|---|
| AI/ML | 128 | 模型训练、Prompt 工程、Hugging Face 集成 |
| 开发 | 170 | Go、Python、Rust、架构设计 |
| 安全 | 81 | 渗透测试、代码审计、漏洞扫描 |
| 云服务 | 145 | K8s、Terraform、CI/CD |
| 前端/设计 | 48 风格 | 页面设计、UI 组件、动画效果 |
| 移动端 | 30 | iOS、Android、Expo 跨平台 |

直接说出你的需求，Agent 会自动加载相应的技能。

---

## 第五步：自定义配置

编辑配置文件：
```bash
vim ~/.config/opencode/opencode.jsonc
```

添加其他 AI Provider（可选）：
```jsonc
"provider": {
  "deepseek": {
    "options": { "apiKey": "sk-xxx", "timeout": 600000 }
  },
  "google": {
    "options": { "apiKey": "your-google-key" }
  }
}
```

Agent 模型分配见 `~/.config/opencode/oh-my-openagent.jsonc`。

---

## 下一步

- 阅读 [README.md](../README.md) 了解完整配置架构
- 查看 [FAQ](#常见问题) 解决常见问题
- 阅读 [CONTRIBUTING.md](../CONTRIBUTING.md) 参与贡献

---

## 常见问题

### 安装失败 / 网络超时怎么办？

1. **重试**：脚本支持自动重试（最多 3 次），等待即可。
2. **手动下载**：前往 [GitHub Releases](https://github.com/panzhaohu666/Distill-OpenCode/releases) 下载 `opencode-skills.tar.gz`，放在与 `install.sh` 同一目录，然后运行 `bash install.sh`。
3. **使用代理**：
   ```bash
   export https_proxy=http://127.0.0.1:7890
   curl -fsSL https://raw.githubusercontent.com/panzhaohu666/Distill-OpenCode/main/install.sh | bash -s -- sk-your-key
   ```

### 如何更新技能库？

重新运行安装脚本自动获取最新 Release：
```bash
curl -fsSL https://raw.githubusercontent.com/panzhaohu666/Distill-OpenCode/main/install.sh | bash -s -- sk-your-key
```

安装前会自动备份旧配置到 `~/.config/opencode.backup/`。

如需安装特定版本：
```bash
curl -fsSL https://raw.githubusercontent.com/panzhaohu666/Distill-OpenCode/main/install.sh | bash -s -- sk-your-key --version v1.0.0
```

### 如何卸载？

```bash
rm -rf ~/.config/opencode/
npm uninstall -g opencode
```

### 如何更换 DeepSeek API Key？

编辑配置文件：
```bash
vim ~/.config/opencode/opencode.jsonc
```
找到 `"apiKey"` 字段，替换为新的 Key。

### 如何添加其他 AI Provider（如 OpenAI、Google）？

编辑 `~/.config/opencode/opencode.jsonc`，在 `"provider"` 中添加新 provider。然后编辑 `~/.config/opencode/oh-my-openagent.jsonc`，修改对应 Agent 的 `"model"` 字段。

### Windows WSL 能用吗？

可以。在 WSL (Ubuntu) 中直接运行安装命令即可。

### 安装后 opencode 命令找不到？

重新加载 shell 配置：
```bash
source ~/.bashrc  # 或 source ~/.zshrc
```

或关闭终端重新打开。

### 技能太多了，如何找到我需要的？

直接向 Agent 描述你的需求，它会自动匹配相关技能。你也可以查看技能分类：
```bash
ls ~/.config/opencode/skills/
ls ~/.config/opencode/skill-libraries/
```
