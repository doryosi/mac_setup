#!/usr/bin/env bash

set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
opencode_skills_dir="${XDG_CONFIG_HOME:-$HOME/.config}/opencode/skills"

# Install shared third-party skills globally for OpenCode.
npx --yes skills add vercel-labs/skills \
  --global --agent opencode --skill find-skills --yes
npx --yes skills add stablyai/orca \
  --global --agent opencode --skill orca-cli orchestration --yes

# Install repository-owned skills without removing unrelated user skills.
mkdir -p "$opencode_skills_dir"
cp -R "$repo_dir/skills/." "$opencode_skills_dir/"
