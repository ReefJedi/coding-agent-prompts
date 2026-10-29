# Changelog

All notable changes to this project are documented here. Format: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), versioning: [SemVer](https://semver.org/).

## [Unreleased]

## [0.1.1] - 2026-10-29
### Added
- README section linking the free in-browser [AI coding rules generator](https://coding-agent-prompts.pages.dev/tools/rules-generator/) for `.cursorrules`, `AGENTS.md`, and `CLAUDE.md`.

### Fixed
- `install.sh` now checks that source role files exist before copying, rejects unknown arguments, supports `--help`, and rewrites `AGENTS.md` via a temp file so a failed update cannot leave a truncated file.

## [0.1.0] - 2026-10-15
### Added
- Three free roles: `code-reviewer`, `debugger`, `test-writer`.
- Native formats: Claude Code subagents (`.claude/agents/*.md`), Cursor rules (`.cursor/rules/*.mdc`), and an `AGENTS.md` block.
- `install.sh` one-command installer with tool detection, interactive prompt, `--force`, and idempotent AGENTS.md updates.
- Plain-text prompts in `prompts/` for any other tool or API.
