This repository contains my dotfiles, which include custom made commands, scripts, aliases, and configurations for neovim and tmux. 

# Gemini Assistant Guidelines for My Dotfiles

This document provides context for the Gemini assistant to help it understand my environment, preferences, and coding style when assisting with this dotfiles repository.

---

## 1. Core Environment and Tools

- **Primary OS:** macOS (darwin)
- **Secondary OS**: Debian (Ubuntu and KDE Neon)
- **Primary Shell:** zsh
- **Package Managers:** Homebrew (`brew`) and `apt`
- **Key Installed Tools:**
    - `bat`: Preferred for file previews and `cat` replacement.
    - `ripgrep` (`rg`): Preferred over `grep` for recursive searching.
    - `jq`: Available for JSON processing.
    - `fzf`: Core tool for interactive filtering.

---

## 2. Scripting Conventions

- **Default Scripting Shell:** `bash` for portability, unless a `zsh`-specific feature is needed.
- **Style:** Strive for POSIX compliance where reasonable. Generally follow the Google Shell Style Guide.
- **Best Practices:** Start new scripts with `set -euo pipefail`.

---

## 3. Project Philosophy

- **Portability is a Goal:** The dotfiles should be functional on both macOS and Linux. Please use commands and flags compatible with both, or write OS-specific conditional logic if necessary.
