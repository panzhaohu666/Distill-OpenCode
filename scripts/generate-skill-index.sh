#!/usr/bin/env bash
#
# generate-skill-index.sh
#
# Scans the category-pointer skills (skills/) and the full-skill library
# (skill-libraries/) for SKILL.md files, extracts the YAML frontmatter fields
# (name, description, tags, triggers) using sed/awk only (no yq/jq), and prints
# a markdown index grouped by tag to stdout.
#
# Usage:
#   bash scripts/generate-skill-index.sh > SKILL_INDEX.md
#
# Environment overrides (optional):
#   SKILLS_DIR       - path to the category-pointer skills root (default: ~/.config/opencode/skills)
#   LIBRARIES_DIR    - path to the full-skill library root (default: ~/.config/opencode/skill-libraries)
#
set -u

SKILLS_DIR="${SKILLS_DIR:-$HOME/.config/opencode/skills}"
LIBRARIES_DIR="${LIBRARIES_DIR:-$HOME/.config/opencode/skill-libraries}"

# ---------------------------------------------------------------------------
# extract_field <frontmatter> <field>
# Prints the value of a single-line frontmatter field, with surrounding
# quotes and whitespace stripped. Empty string if absent.
# ---------------------------------------------------------------------------
extract_field() {
  printf '%s\n' "$1" \
    | sed -n "s/^${2}:[[:space:]]*//p" \
    | head -n 1 \
    | sed -e 's/^[[:space:]"'"'"']*//' -e 's/[[:space:]"'"'"']*$//'
}

# ---------------------------------------------------------------------------
# scan_dir <root> <kind>
# Emits one line per (tag, skill) pair to stdout:
#   <tag>\t<name>\t<description>\t<location>\t<triggers>\t<kind>
# A skill with N tags emits N lines (one per tag).
# ---------------------------------------------------------------------------
scan_dir() {
  local root="$1" kind="$2"
  [ -d "$root" ] || return 0

  local file rel fm name desc tags triggers loc
  while IFS= read -r file; do
    rel="${file#"$root"/}"
    loc="~/${file#"$HOME"/}"
    fm="$(awk 'BEGIN{n=0} /^---[[:space:]]*$/{n++; next} n==1{print} n==2{exit}' "$file")"
    [ -n "$fm" ] || continue

    name="$(extract_field "$fm" name)"
    [ -n "$name" ] || name="${rel%/*}"
    name="${name%/SKILL.md}"
    desc="$(extract_field "$fm" description)"
    tags="$(extract_field "$fm" tags)"
    triggers="$(extract_field "$fm" triggers)"
    [ -n "$tags" ] || tags="uncategorized"

    local t
    IFS=',' read -r -a taglist <<< "$tags"
    for t in "${taglist[@]}"; do
      t="$(printf '%s' "$t" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr 'A-Z' 'a-z')"
      [ -n "$t" ] || continue
      printf '%s\t%s\t%s\t%s\t%s\t%s\n' "$t" "$name" "$desc" "$loc" "$triggers" "$kind"
    done
  done < <(find "$root" -name SKILL.md -type f 2>/dev/null | sort)
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

scan_dir "$SKILLS_DIR" "pointer"    >> "$tmp"
scan_dir "$LIBRARIES_DIR" "library" >> "$tmp"
sort -u -o "$tmp" "$tmp"

n_total="$(wc -l < "$tmp")"
n_pointers="$(awk -F'\t' '$6=="pointer" {n++} END{print n+0}' "$tmp")"
n_libraries="$(awk -F'\t' '$6=="library" {n++} END{print n+0}' "$tmp")"

cat <<EOF
# Skill Index

Auto-generated index of all skills installed by Distill-OpenCode.

- **Generated:** $(date -u +%Y-%m-%dT%H:%M:%SZ)
- **Category pointers** (skills/): ${n_pointers}
- **Full skills** (skill-libraries/): ${n_libraries}
- **Total entries (incl. multi-tag duplicates):** ${n_total}

> Regenerate after adding or changing skills:
> \`\`\`
> bash scripts/generate-skill-index.sh > SKILL_INDEX.md
> \`\`\`

EOF

awk -F'\t' '
BEGIN { last = "" }
{
  tag=$1; name=$2; desc=$3; loc=$4; trig=$5; kind=$6
  gsub(/\|/, "\\|", desc)
  gsub(/\|/, "\\|", trig)
  if (tag != last) {
    if (NR > 1) print ""
    printf "## %s\n\n", tag
    print "| Skill | Type | Description | Location | Triggers |"
    print "|-------|------|-------------|----------|----------|"
    last = tag
  }
  printf "| %s | %s | %s | %s | %s |\n", name, kind, desc, loc, trig
}
' "$tmp"
