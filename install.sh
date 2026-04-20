#!/bin/sh
set -e

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
SKILLS_DIR="$REPO_ROOT/skills"

TOOL="opencode"
PROJECT_PATH=""

usage() {
  cat <<EOF
Usage: $0 [OPTIONS]

Install skills-md skills to a supported AI coding tool.

Options:
  --tool <name>       Target tool (default: opencode)
  --project <path>    Install to per-project path instead of global
  --help              Show this help message

Supported tools:
  opencode    Global: \$HOME/.config/opencode/skills/
              Project: <path>/.opencode/skills/

Examples:
  $0
  $0 --tool opencode
  $0 --project /path/to/my-project
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --tool)
      TOOL="$2"
      shift 2
      ;;
    --project)
      PROJECT_PATH="$2"
      shift 2
      ;;
    --help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

case "$TOOL" in
  opencode)
    if [ -n "$PROJECT_PATH" ]; then
      DEST="$PROJECT_PATH/.opencode/skills"
    else
      DEST="$HOME/.config/opencode/skills"
    fi
    ;;
  *)
    echo "Unsupported tool: $TOOL" >&2
    echo "Supported tools: opencode" >&2
    exit 1
    ;;
esac

if [ ! -d "$SKILLS_DIR" ]; then
  echo "Skills directory not found: $SKILLS_DIR" >&2
  exit 1
fi

mkdir -p "$DEST"

COUNT=0
for skill_dir in "$SKILLS_DIR"/*/; do
  skill_name="$(basename "$skill_dir")"
  cp -r "$skill_dir" "$DEST/"
  echo "  installed: $skill_name"
  COUNT=$((COUNT + 1))
done

echo ""
echo "$COUNT skill(s) installed to $DEST"
