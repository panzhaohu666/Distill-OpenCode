# SKILL_INDEX.md

Reference index of the Distill-OpenCode skill system: the tag taxonomy, the
layout of the two skill roots, and the regeneration workflow.

> ⚠️ **This file is a template/placeholder.** It documents the taxonomy but does
> **not** contain the live skill list. Run
> `bash scripts/generate-skill-index.sh` after adding skills to regenerate this
> file with the real, tag-grouped index.

---

## 1. Layout

| Root                        | Count | Purpose                                              |
|-----------------------------|-------|------------------------------------------------------|
| `~/.config/opencode/skills/`          | 99    | Category **pointer** skills (one per capability area) |
| `~/.config/opencode/skill-libraries/` | 1913  | **Full** skills with complete documentation           |

Each skill lives in its own directory and is identified by a `SKILL.md` file.
The frontmatter format is documented in [`SKILL_TEMPLATE.md`](SKILL_TEMPLATE.md).

## 2. Tag taxonomy

`tags` in SKILL.md frontmatter are **lowercase, kebab-case, comma-separated**.
They drive the grouping of the generated index. Known tags:

| Tag                  | Meaning                                                                      |
|----------------------|------------------------------------------------------------------------------|
| `ai` / `ml`          | Machine learning, LLMs, models, training, inference                           |
| `ai-agents`          | Agent frameworks, agent behavior, orchestration of agents                    |
| `data` / `data-science` | Analysis, pipelines, statistics, visualization                             |
| `database`           | SQL/NoSQL engines, schema design, migrations                                  |
| `backend`            | Server-side code, APIs, services, runtime logic                               |
| `api` / `api-integration` | Consuming/producing APIs, SDKs, webhooks                                  |
| `frontend` / `web-development` | HTML/CSS/JS, frameworks, browsers, web apps                             |
| `design` / `design-it` | UI/UX, visual design, design systems, prototypes                            |
| `mobile`             | iOS, Android, cross-platform app development                                  |
| `automation`         | Workflow automation, n8n/Zapier/Make, bots, scripts                            |
| `testing` / `test-automation` | Unit/e2e tests, QA, coverage, CI test runs                                |
| `devops` / `ci-cd`   | Pipelines, containers, deployment, observability                              |
| `cloud`              | AWS/GCP/Azure, serverless, hosting, infrastructure                            |
| `security`           | Appsec, pentesting, audits, threat modeling, hardening                         |
| `development`        | General software engineering practice, tooling, code quality                   |
| `productivity`       | Personal/organizational efficiency, note-taking, knowledge management          |
| `writing`            | Technical writing, content, documentation                                      |
| `business` / `marketing` | Strategy, growth, SEO, campaigns, analytics                                |
| `product-management` | Roadmaps, requirements, prioritization, discovery                              |
| `project-management` | Planning, tracking, agile ceremonies                                           |
| `finance`            | Accounting, payments, budgeting, fintech                                       |
| `health`             | Medical, fitness, wellbeing                                                    |
| `education`          | Learning, teaching, course design                                              |
| `science` / `research` | Scientific computing, literature, experiments                                |
| `game-development`   | Engines, gameplay, graphics, game systems                                      |
| `media` / `video` / `voice-agents` | Audio, video, speech, media processing                            |
| `blockchain`         | Web3, smart contracts, crypto                                                 |
| `legal`              | Contracts, compliance, regulatory                                               |
| `uncategorized`      | Skills with no `tags` field (grouped by default)                               |

Tags not listed here are valid too — the generator groups by whatever tags
exist; add new tags to this table when the taxonomy evolves.

## 3. Regeneration

The index is **generated, not hand-edited**:

```bash
bash scripts/generate-skill-index.sh > SKILL_INDEX.md
```

The generator:

- scans `~/.config/opencode/skills/` and `~/.config/opencode/skill-libraries/`
  for `SKILL.md` files (override with `SKILLS_DIR` / `LIBRARIES_DIR`);
- extracts `name`, `description`, `tags`, `triggers` from YAML frontmatter
  using `sed`/`awk` only — **no `yq`/`jq` dependency**;
- emits a markdown table per tag (skills with multiple tags appear under each);
- writes to **stdout**; redirect to save.

> Run `bash scripts/generate-skill-index.sh` after adding skills to regenerate
> this file.

## 4. Generated output shape

For reference, the generator emits (abbreviated example, not real data):

```markdown
# Skill Index

Auto-generated index of all skills installed by Distill-OpenCode.

- **Generated:** 2026-08-09T00:00:00Z
- **Category pointers** (skills/): 99
- **Full skills** (skill-libraries/): 1913
- **Total entries (incl. multi-tag duplicates):** 2012

## ai

| Skill | Type | Description | Location | Triggers |
|-------|------|-------------|----------|----------|
| example-skill | pointer | Automates model training. | ~/.config/opencode/skills/example-skill/SKILL.md | train a model |

## ml
...
```

## 5. See also

- [`SKILL_TEMPLATE.md`](SKILL_TEMPLATE.md) — the SKILL.md authoring standard.
- [`docs/QUICKSTART.md`](docs/QUICKSTART.md) — installing Distill-OpenCode.
