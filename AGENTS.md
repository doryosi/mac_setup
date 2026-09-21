# Repository Guidelines

## Purpose

This repository reproduces the user's macOS command-line and application setup. Keep installation logic separate from versioned configuration files.

## Structure

```text
.
├── AGENTS.md
├── setup.sh
├── skills.sh
├── config/
│   ├── .zshrc
│   ├── ghostty.conf
│   ├── starship.toml
│   ├── opencode/
│   │   ├── opencode.json
│   │   └── tui.json
│   └── vscode/
│       ├── extensions.txt
│       └── settings.json
└── skills/
    └── <skill-name>/
        └── SKILL.md
```

## Configuration Rules

- Store application configuration under `config/`; do not embed substantial configuration in `setup.sh`.
- Use a tool-specific subdirectory when an application has multiple configuration files, as with `config/opencode/`.
- Keep single-file configurations directly under `config/`, as with `ghostty.conf` and `starship.toml`.
- Keep the repository copy equivalent to the active user configuration unless portability or secret removal requires a documented difference.
- Never commit credentials, tokens, private keys, machine identifiers, or other secrets. Inspect active files before exporting them.
- Update `setup.sh` whenever a configuration file is added or moved so a new machine installs the repository copy in the correct destination.
- Preserve existing user configuration by default. Only overwrite it when the user explicitly requests deterministic replacement.
- Store repository-owned OpenCode skills under `skills/<name>/SKILL.md`; install third-party skills through `skills.sh`.

## Validation

- Run `bash -n setup.sh` and `bash -n skills.sh` after shell changes.
- Run `git diff --check` after edits.
- Validate application configuration with the application's CLI when available.
