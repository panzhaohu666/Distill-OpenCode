# Config Templates

This directory holds the configuration templates used by `install.sh`.

## What's here

| File | Purpose |
|------|---------|
| `opencode.jsonc` | Main OpenCode config (models, provider, plugins) |
| `oh-my-openagent.jsonc` | Static agent/category model assignments |
| `tui.json` | TUI theme and plugin settings |

## Variable substitution

`${DEEPSEEK_KEY}` in `opencode.jsonc` is a **placeholder**. During
installation, `install.sh` replaces it with the user's real DeepSeek API key
(collected from the CLI argument, `DEEPSEEK_API_KEY` env var, or an
interactive prompt). The other two files are fully static — no substitution
is performed on them.

## When are these templates used?

- **git clone**: When running from a cloned repo (`bash
  Distill-OpenCode/install.sh`), `install.sh` reads the config content from
  these templates.
- **piped curl**: When installed via
  `curl -fsSL .../install.sh | bash -s -- sk-xxx`, `install.sh` falls back
  to configs embedded directly in the script body (no template files are
  available on the piped stdin, only the script itself).

Both paths produce identical configs.

## Customizing without being overwritten

To customize your configs so they survive a reinstall:

1. Copy the file you want to change into
   `~/.config/opencode/local/` (creating the directory if needed).
2. Edit the copy as you like.

Files under `~/.config/opencode/local/` are merged over the generated
configs and are **not overwritten** on reinstall, so your customizations
persist.
