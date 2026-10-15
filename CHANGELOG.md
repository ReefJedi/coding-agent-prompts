# Changelog

All notable changes to this project are documented here. Format: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), versioning: [SemVer](https://semver.org/).

## [Unreleased]

## [0.1.0] - 2026-10-15
### Added
- Three free roles: `code-reviewer`, `debugger`, `test-writer`.
- Native formats: Claude Code subagents (`.claude/agents/*.md`), Cursor rules (`.cursor/rules/*.mdc`), and an `AGENTS.md` block.
- `install.sh` one-command installer with tool detection, interactive prompt, `--force`, and idempotent AGENTS.md updates.
- Plain-text prompts in `prompts/` for any other tool or API.
