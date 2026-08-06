#!/bin/sh
set -e

# Validates and converts a single skill's SKILL.md frontmatter for opencode,
# then installs the skill into the destination directory.
#
# Usage: opencode-convert-skill.sh <src_skill_dir> <dest_skill_dir>
#
# Exit 0 on success. Exit 1 on validation failure, with a reason on stderr —
# nothing is written to <dest_skill_dir> in that case. opencode itself never
# checks that frontmatter `name` matches the skill's directory name, and
# silently drops a skill whose frontmatter fails to parse — this script
# enforces both before opencode ever sees the file.

SRC="$1"
DEST="$2"

if [ -z "$SRC" ] || [ -z "$DEST" ]; then
  echo "Usage: $0 <src_skill_dir> <dest_skill_dir>" >&2
  exit 1
fi

SKILL_MD="$SRC/SKILL.md"
NAME="$(basename "$DEST")"

if [ ! -f "$SKILL_MD" ]; then
  echo "missing SKILL.md" >&2
  exit 1
fi

FRONTMATTER="$(awk '
  /^---[ \t]*$/ { n++; if (n == 2) exit; next }
  n == 1 { print }
' "$SKILL_MD")"

if [ -z "$FRONTMATTER" ]; then
  echo "no frontmatter block found" >&2
  exit 1
fi

fm_value() {
  key="$1"
  printf '%s\n' "$FRONTMATTER" | sed -n "s/^${key}:[[:blank:]]*//p" | sed 's/[[:blank:]]*$//' | head -n1
}

trim_quotes() {
  v="$1"
  v="${v#\"}"; v="${v%\"}"
  v="${v#\'}"; v="${v%\'}"
  printf '%s' "$v"
}

FM_NAME="$(trim_quotes "$(fm_value name)")"
FM_DESC="$(trim_quotes "$(fm_value description)")"

if [ -z "$FM_NAME" ]; then
  echo "missing 'name' in frontmatter" >&2
  exit 1
fi

if [ "$FM_NAME" != "$NAME" ]; then
  echo "'name: $FM_NAME' does not match directory name '$NAME'" >&2
  exit 1
fi

if [ -z "$FM_DESC" ]; then
  echo "missing 'description' in frontmatter" >&2
  exit 1
fi

DESC_LEN=$(printf '%s' "$FM_DESC" | wc -c | tr -d '[:space:]')
if [ "$DESC_LEN" -gt 250 ]; then
  echo "'description' is $DESC_LEN chars, exceeds 250-char limit" >&2
  exit 1
fi

BAD_KEY="$(printf '%s\n' "$FRONTMATTER" | grep -E '^(context|agent|argument-hint):' | head -n1)"
if [ -n "$BAD_KEY" ]; then
  echo "disallowed Claude-only frontmatter key: ${BAD_KEY%%:*}" >&2
  exit 1
fi

# Port of opencode's own sanitize() (packages/core/src/config/markdown.ts):
# rewrite any unquoted-colon value as a YAML block scalar, so the installed
# copy is already safe instead of depending on opencode's parse-time retry.
SANITIZED="$(printf '%s\n' "$FRONTMATTER" | awk -v sq="'" -v dq='"' '
{
  line = $0
  trimmed_line = line
  sub(/^[ \t]+/, "", trimmed_line)
  if (trimmed_line ~ /^#/ || trimmed_line == "" || line ~ /^[ \t]/) {
    print line
    next
  }
  if (match(line, /^[a-zA-Z_][a-zA-Z0-9_]*[ \t]*:[ \t]*/)) {
    matched = substr(line, RSTART, RLENGTH)
    keyname = matched
    sub(/[ \t]*:[ \t]*$/, "", keyname)
    value = substr(line, RSTART + RLENGTH)
    trimmed = value
    sub(/[ \t]+$/, "", trimmed)
    first = substr(trimmed, 1, 1)
    if (trimmed == "" || trimmed == ">" || trimmed == "|" || first == dq || first == sq) {
      print line
      next
    }
    if (index(trimmed, ":") == 0) {
      print line
      next
    }
    print keyname ": |-"
    print "  " trimmed
    next
  }
  print line
}
')"

mkdir -p "$DEST"

awk -v fm="$SANITIZED" '
  /^---[ \t]*$/ {
    n++
    print
    if (n == 1) print fm
    next
  }
  n < 2 { next }
  { print }
' "$SKILL_MD" > "$DEST/SKILL.md"

for f in "$SRC"/*; do
  base="$(basename "$f")"
  [ "$base" = "SKILL.md" ] && continue
  cp -r "$f" "$DEST/$base"
done
