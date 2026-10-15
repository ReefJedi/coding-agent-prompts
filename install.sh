#!/usr/bin/env bash
# coding-agent-prompts installer: copies the free roles into the current project.
# Usage: /path/to/coding-agent-prompts/install.sh [claude|cursor|agents|all] [--force]
set -euo pipefail
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST="$(pwd)"
ROLES=(code-reviewer debugger test-writer)
TOOL="${1:-}"; FORCE=0
for a in "$@"; do [[ "$a" == "--force" ]] && FORCE=1; done
[[ "$TOOL" == "--force" ]] && TOOL=""

if [[ "$SRC" == "$DEST" ]]; then echo "Run this from your project directory, not from the repo itself." >&2; exit 1; fi

detect() {
  local found=()
  [[ -d "$DEST/.claude" || -f "$DEST/CLAUDE.md" ]] && found+=(claude)
  [[ -d "$DEST/.cursor" || -f "$DEST/.cursorrules" ]] && found+=(cursor)
  [[ -f "$DEST/AGENTS.md" ]] && found+=(agents)
  echo "${found[*]:-}"
}

if [[ -z "$TOOL" ]]; then
  detected="$(detect)"
  if [[ -n "$detected" && "$detected" != *" "* ]]; then
    TOOL="$detected"; echo "Detected: $TOOL"
  elif [[ -t 0 ]]; then
    [[ -n "$detected" ]] && echo "Detected several: $detected"
    echo "Install for which tool?"; echo "  1) Claude Code (.claude/agents)"; echo "  2) Cursor (.cursor/rules)"; echo "  3) AGENTS.md (Codex, Copilot, others)"; echo "  4) All of the above"
    read -r -p "Choose 1-4: " c
    case "$c" in 1) TOOL=claude;; 2) TOOL=cursor;; 3) TOOL=agents;; 4) TOOL=all;; *) echo "Invalid choice" >&2; exit 1;; esac
  else
    echo "No tool detected and no terminal to ask. Pass one: claude | cursor | agents | all" >&2; exit 1
  fi
fi

copy() { # src dst
  if [[ -e "$2" && $FORCE -eq 0 ]]; then echo "  skip (exists): ${2#$DEST/}  (use --force to overwrite)"; return; fi
  mkdir -p "$(dirname "$2")"; cp "$1" "$2"; echo "  added: ${2#$DEST/}"
}
install_claude() { echo "Claude Code:"; for r in "${ROLES[@]}"; do copy "$SRC/.claude/agents/$r.md" "$DEST/.claude/agents/$r.md"; done; }
install_cursor() { echo "Cursor:"; for r in "${ROLES[@]}"; do copy "$SRC/.cursor/rules/$r.mdc" "$DEST/.cursor/rules/$r.mdc"; done; }
install_agents() {
  echo "AGENTS.md:"; local f="$DEST/AGENTS.md"
  if [[ -f "$f" ]] && grep -q "coding-agent-prompts:start" "$f"; then
    awk '/coding-agent-prompts:start/{skip=1} !skip{print} /coding-agent-prompts:end/{skip=0}' "$f" > "$f.tmp"; mv "$f.tmp" "$f"
    echo "  replaced existing coding-agent-prompts block"
  fi
  [[ -s "$f" ]] && printf "\n" >> "$f"
  cat "$SRC/AGENTS.md" >> "$f"; echo "  updated: AGENTS.md (block between coding-agent-prompts markers)"
}
case "$TOOL" in
  claude) install_claude;; cursor) install_cursor;; agents) install_agents;;
  all) install_claude; install_cursor; install_agents;;
  *) echo "Unknown tool: $TOOL (use claude | cursor | agents | all)" >&2; exit 1;;
esac
echo
echo "Done. Free roles: ${ROLES[*]}."
echo "Want the full 10-role pipeline (planner, implementer, orchestrator, security auditor...)? https://aiagentdecoder.gumroad.com/l/wylpq"
