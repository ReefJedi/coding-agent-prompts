#!/usr/bin/env bash
# coding-agent-prompts installer: copies the free roles into the current project.
# Usage: /path/to/coding-agent-prompts/install.sh [claude|cursor|agents|all] [--force]
set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST="$(pwd)"
ROLES=(code-reviewer debugger test-writer)
TOOL=""
FORCE=0

usage() {
  cat <<'USAGE'
Usage: install.sh [claude|cursor|agents|all] [--force]

  claude   Install Claude Code subagents into .claude/agents/
  cursor   Install Cursor rules into .cursor/rules/
  agents   Append/replace the coding-agent-prompts block in AGENTS.md
  all      Install all of the above

  --force     Overwrite existing role files (AGENTS.md block is always replaced)
  -h, --help  Show this help

Run from your project directory, not from inside this repository.
USAGE
}

for a in "$@"; do
  case "$a" in
    -h|--help|help) usage; exit 0 ;;
    --force) FORCE=1 ;;
    claude|cursor|agents|all)
      if [[ -n "$TOOL" ]]; then
        echo "Unexpected extra tool argument: $a (already chose $TOOL)" >&2
        exit 1
      fi
      TOOL="$a"
      ;;
    *)
      echo "Unknown argument: $a" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [[ "$SRC" == "$DEST" ]]; then
  echo "Run this from your project directory, not from the repo itself." >&2
  exit 1
fi

require_sources() {
  local missing=0 r
  for r in "${ROLES[@]}"; do
    [[ -f "$SRC/.claude/agents/$r.md" ]] || { echo "Missing source: .claude/agents/$r.md" >&2; missing=1; }
    [[ -f "$SRC/.cursor/rules/$r.mdc" ]] || { echo "Missing source: .cursor/rules/$r.mdc" >&2; missing=1; }
  done
  [[ -f "$SRC/AGENTS.md" ]] || { echo "Missing source: AGENTS.md" >&2; missing=1; }
  if [[ $missing -ne 0 ]]; then
    echo "Installer source tree looks incomplete under: $SRC" >&2
    exit 1
  fi
}

detect() {
  local found=()
  [[ -d "$DEST/.claude" || -f "$DEST/CLAUDE.md" ]] && found+=(claude)
  [[ -d "$DEST/.cursor" || -f "$DEST/.cursorrules" ]] && found+=(cursor)
  [[ -f "$DEST/AGENTS.md" ]] && found+=(agents)
  if ((${#found[@]})); then
    printf '%s' "${found[*]}"
  fi
}

if [[ -z "$TOOL" ]]; then
  detected="$(detect)"
  if [[ -n "$detected" && "$detected" != *" "* ]]; then
    TOOL="$detected"
    echo "Detected: $TOOL"
  elif [[ -t 0 ]]; then
    [[ -n "$detected" ]] && echo "Detected several: $detected"
    echo "Install for which tool?"
    echo "  1) Claude Code (.claude/agents)"
    echo "  2) Cursor (.cursor/rules)"
    echo "  3) AGENTS.md (Codex, Copilot, others)"
    echo "  4) All of the above"
    read -r -p "Choose 1-4: " c
    case "$c" in
      1) TOOL=claude ;;
      2) TOOL=cursor ;;
      3) TOOL=agents ;;
      4) TOOL=all ;;
      *) echo "Invalid choice" >&2; exit 1 ;;
    esac
  else
    echo "No tool detected and no terminal to ask. Pass one: claude | cursor | agents | all" >&2
    exit 1
  fi
fi

require_sources

copy() { # src dst
  if [[ ! -f "$1" ]]; then
    echo "  error: source missing: $1" >&2
    exit 1
  fi
  if [[ -e "$2" && $FORCE -eq 0 ]]; then
    echo "  skip (exists): ${2#"$DEST"/}  (use --force to overwrite)"
    return 0
  fi
  mkdir -p "$(dirname "$2")"
  cp "$1" "$2"
  echo "  added: ${2#"$DEST"/}"
}

install_claude() {
  echo "Claude Code:"
  local r
  for r in "${ROLES[@]}"; do
    copy "$SRC/.claude/agents/$r.md" "$DEST/.claude/agents/$r.md"
  done
}

install_cursor() {
  echo "Cursor:"
  local r
  for r in "${ROLES[@]}"; do
    copy "$SRC/.cursor/rules/$r.mdc" "$DEST/.cursor/rules/$r.mdc"
  done
}

install_agents() {
  echo "AGENTS.md:"
  local f="$DEST/AGENTS.md"
  local tmp
  tmp="$(mktemp "${TMPDIR:-/tmp}/coding-agent-prompts.XXXXXX")"
  cleanup_tmp() { rm -f "$tmp"; }
  trap cleanup_tmp EXIT

  if [[ -f "$f" ]] && grep -q "coding-agent-prompts:start" "$f"; then
    # Drop the previous block (markers inclusive). Keep everything else.
    awk '
      /coding-agent-prompts:start/ { skip=1; next }
      /coding-agent-prompts:end/   { skip=0; next }
      !skip { print }
    ' "$f" > "$tmp"
    echo "  replaced existing coding-agent-prompts block"
  elif [[ -f "$f" ]]; then
    cat "$f" > "$tmp"
  else
    : > "$tmp"
  fi

  if [[ -s "$tmp" ]]; then
    # Ensure a blank line between existing content and our block.
    if [[ -n "$(tail -c 1 "$tmp" || true)" ]]; then
      printf '\n\n' >> "$tmp"
    else
      printf '\n' >> "$tmp"
    fi
  fi

  cat "$SRC/AGENTS.md" >> "$tmp"
  mv "$tmp" "$f"
  trap - EXIT
  echo "  updated: AGENTS.md (block between coding-agent-prompts markers)"
}

case "$TOOL" in
  claude) install_claude ;;
  cursor) install_cursor ;;
  agents) install_agents ;;
  all) install_claude; install_cursor; install_agents ;;
  *)
    echo "Unknown tool: $TOOL (use claude | cursor | agents | all)" >&2
    exit 1
    ;;
esac

echo
echo "Done. Free roles: ${ROLES[*]}."
echo "Want the full 10-role pipeline (planner, implementer, orchestrator, security auditor...)? https://aiagentdecoder.gumroad.com/l/wylpq"
