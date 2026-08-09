# SKILL.md Template

This document defines the **standard format for every `SKILL.md` file** in the
Distill-OpenCode project. Both *category-pointer* skills and *full library*
skills must follow this format so that tooling (e.g.
[`scripts/generate-skill-index.sh`](scripts/generate-skill-index.sh)) can parse
them reliably.

---

## 1. YAML Frontmatter

Every `SKILL.md` starts with a YAML frontmatter block delimited by `---` lines
**at the very top of the file** (nothing before the first `---`).

### Required fields

| Field         | Type   | Description                                                              |
|---------------|--------|--------------------------------------------------------------------------|
| `name`        | string | Unique, kebab-case identifier for the skill. Matches its directory name. |
| `description` | string | One sentence: what the skill does and **when to use it**.                |
| `location`    | string | Path to this `SKILL.md` (`~` is allowed for the home directory).         |

### Optional fields

| Field      | Type   | Description                                                             |
|------------|--------|-------------------------------------------------------------------------|
| `tags`     | string | Comma-separated categories for grouping in the index (lowercase).       |
| `triggers` | string | Comma-separated trigger phrases that should activate this skill.        |

### Example frontmatter

```yaml
---
name: example-skill
description: Brief description of what this skill does and when to use it
location: ~/.config/opencode/skills/example-skill/SKILL.md
tags: ai, ml, python
triggers: machine learning, training, model
---
```

### Conventions

- Field names are lowercase, single word, followed by `: ` (colon + space).
- String values containing `:` or `,` should be wrapped in double quotes:
  ```yaml
  description: "Runs reports, builds charts, and exports data. Use for analytics."
  ```
- `tags` values should be **lowercase, kebab-case** (e.g. `ml-ops`, `web-development`),
  comma-separated. A skill may have zero or more tags.
- `triggers` phrases are comma-separated, plain text (e.g. `machine learning, model training`).
- Do **not** add extra fields beyond `name`, `description`, `location`, `tags`,
  `triggers`. Keep the frontmatter simple so `sed`/`awk`-based tooling can parse it.

---

## 2. Full example SKILL.md

```markdown
---
name: example-skill
description: Automates model training pipelines end to end. Use when the user asks to train, retrain, or tune a model.
location: ~/.config/opencode/skills/example-skill/SKILL.md
tags: ai, ml, automation
triggers: train a model, model training, hyperparameter tuning
---

# Example Skill

One paragraph explaining the skill's purpose and when it should be loaded.

## Usage

1. Step one.
2. Step two.

## References

- Link or note pointing to related files.
```

---

## 3. Category-pointer vs full-library skills

The skill system has **two tiers**:

### `skills/` — category pointers (99)

One **pointer skill** per capability category. Its `SKILL.md` is short: it lists
the full skills available in that category and where their vault lives. It keeps
startup context minimal — the heavy content stays in the library.

```yaml
---
name: automation-category-pointer
description: "Pointer to a library of 49 specialized Automation skills. Use when working on automation-related tasks."
location: ~/.config/opencode/skills/automation-category-pointer/SKILL.md
tags: automation
triggers: automate, workflow, pipeline
---
```

Body convention:

```markdown
# Automation Capability Library 🎯

This is a **pointer skill**. The 49 specialized Automation skills are stored in a
hidden vault to keep your startup context minimal.

## Available skills in this category

- **skill-name** — one-line description.
```

### `skill-libraries/` — full skills (1913)

The actual, fully-documented skills. One directory per skill, each containing a
`SKILL.md` with complete instructions. These may carry extra provenance fields
in practice (e.g. `risk`, `source`, `date_added`) — the index generator only
reads `name`, `description`, `tags`, `triggers` and ignores everything else.

---

## 4. Markdown structure conventions

- **Heading levels:** `#` for the skill title (exactly one H1), `##` for major
  sections, `###` for subsections. Never skip levels.
- **Code blocks:** fence with ``` and name the language (```bash, ```python,
  ```yaml). Indented 4-space blocks are allowed only for inline snippets.
- **Lists:** `- ` for bullets, `1. ` for ordered steps.
- **Tables:** pipe-separated with a `|---|---|` separator row.
- **Inline code:** backticks for file names, commands, and field names.
- Keep line length ≤ 100 characters where practical.
- Avoid emojis except in pointer-skill titles (project convention).
