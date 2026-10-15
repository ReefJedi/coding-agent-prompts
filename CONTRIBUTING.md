# Contributing

Thanks for helping make coding agents more honest.

## Good contributions
- **Failure reports:** a real case where a role misbehaved (fake "tests pass", invented API, ignored scope). Include the tool, model, the prompt version, and the transcript excerpt.
- **Prompt fixes:** a change to a role that fixes a reported failure. Explain the failure and how you checked the fix.
- **New tool formats:** e.g. Codex, Copilot instructions, Windsurf, Cline.
- **Installer fixes:** keep `install.sh` dependency-free bash.

## Rules
1. Edit the source in `prompts/<role>.md` first, then mirror the change into `.claude/agents/`, `.cursor/rules/`, and `AGENTS.md`, so all formats stay in sync.
2. Keep the honesty rules intact: no change may let a role claim it ran something it did not run.
3. Don't claim a prompt "improves results" without a before/after example.
4. Add a line under `[Unreleased]` in `CHANGELOG.md`.
5. Test the installer in a scratch directory: `mkdir /tmp/t && cd /tmp/t && /path/to/repo/install.sh all`.

## Process
Open an issue first for anything bigger than a typo, then a pull request referencing it. By contributing you agree your contribution is licensed under MIT.
