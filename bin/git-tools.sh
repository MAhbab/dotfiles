#!/bin/bash

# Git Commit Explorer
#
# A lightweight terminal UI for browsing recent Git commits and inspecting file-level diffs.
# Uses `fzf` to let you interactively:
#   - Select a commit and drill down into individual files
#   - Or, with `--full-diff`, view the entire commit diff at once
#
# Usage:
#   ./commit_explorer.sh            # Browse commits and select individual file diffs
#   ./commit_explorer.sh --full-diff   # Preview full diffs of selected commits
#   ./commit_explorer.sh --help        # Show help

set -euo pipefail

REPO_ROOT=$(git rev-parse --show-toplevel)

# Check if we're inside a Git repository
if ! git rev-parse --is-inside-work-tree &> /dev/null; then
  echo "Error: Not inside a Git repository."
  exit 1
fi

# Handle --help flag
if [[ "${1:-}" == "--help" ]]; then
  echo "Git Commit Explorer"
  echo
  echo "Usage:"
  echo "  .$0           # Browse commits and drill into individual file diffs"
  echo "  .$0 --full-diff  # Preview full commit diffs without file selection"
  echo
  exit 0
fi

# Handle full diff mode
if [[ "${1:-}" == "--full-diff" ]]; then
  git log --date=short --pretty=' %h %ad %an %s' -n 80 | \
    fzf --preview 'git show --color=always $(echo {} | awk "{ print \$1 }")' | \
    awk '{ print $1 }' | \
    xargs git show --color=always | \
    less -R
  exit 0
fi

# Default interactive mode: pick commit, then file
COMMIT=$(git log --date=short --pretty='%h %ad %an %s' -n 80 | \
  fzf --preview 'git diff-tree --no-commit-id --name-only $(echo {} | awk "{ print \$1 }") -r' | \
  awk '{ print $1 }')

FILE_SELECTION=$(git -C "$REPO_ROOT" diff-tree --no-commit-id --name-only "$COMMIT" -r | \
  fzf --preview "git -C $REPO_ROOT show --color=always $COMMIT -- {}")

git -C "$REPO_ROOT" show --color=always "$COMMIT" -- "$FILE_SELECTION" 
