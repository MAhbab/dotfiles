# 🛠️ Neovim Config — Minimalist, Functional, and Obsidian-Ready

Welcome to my personal Neovim configuration! This setup is built for developers and note-takers who want a fast, modern, and productive editing experience — especially those who use Obsidian and write in Markdown often.

## ✨ Features

- **Lua-first Neovim config** with `lazy.nvim` plugin manager
- **Autocompletion** via `nvim-cmp`, tuned for productivity
- **Path-aware Obsidian-style link completion** with `[[relative/path/to/file]]` format
- **Treesitter** for smart syntax highlighting and code structure
- **LSP support** via `nvim-lspconfig` + `mason.nvim`
- **Fuzzy Finder** via Telescope (`<leader>ff`, `<leader>fg`, etc.)
- **Codeium** autocomplete with custom bindings (`<C-g>`, `<C-h>`, etc.)
- **Relative line numbers** and clean formatting across YAML, Python, SQL, Rust
- **Custom macro** (`<leader>f`) to fix malformed `[[wikilinks]]` (e.g., `%hh d%`)
- **Clipboard shortcuts** to copy file path and line: `<leader>y`
- **Obsidian.nvim** for working with a local vault (`~/Documents/mindspace/content`)

## 🧩 Plugin Highlights

- `nvim-cmp` + `cmp-path`, `cmp-nvim-lsp`, `cmp-buffer`, `cmp_luasnip`
- `LuaSnip` for snippets
- `obsidian.nvim` (custom patched to support full path-based completion)
- `nvim-treesitter` and `plenary.nvim`
- `telescope.nvim` for fast navigation
- `codeium.vim` for code suggestions

## 🧪 Language-Specific Settings

Tab/indent behavior is configured per filetype:
- YAML → 2 spaces
- Python / SQL / Rust → 4 spaces

## 🔧 Requirements

- `neovim >= 0.9`
- `ripgrep`, `fd`, `node`, `python3-pynvim`
- (Optional) `codeium` access and login

## 🚀 Getting Started

```bash
git clone https://github.com/your-username/nvim-config.git ~/.config/nvim
nvim


## ⚠️  Warning
If you're interested in using the Obsidian plugin, please note that:
First, the Obsidian plugin was modified to work with my [quartz](https://github.com/jackyzha0/quartz) configuration which requires complete file paths (e.g. `/my/dir/file.md`) instead of relative ones (e.g. `.file.md`). Autocompleting pages linked with double brackets (`[[my/dir/file]]`) is buggy and every file linking via autocompletion requires a fix. That fix is implemented as a macro which is called with `\f`.

Second, you'll need to update file paths in a few different files to point to your own vault. Here are the files and line numbers you'll need to change:

```
lua/obsidian_patch.lua:34:    local root = "/Users/mahfuj/Documents/mindspace/content/"
lua/obsidian_config.lua:5:      path = "~/Documents/mindspace/content",
lua/completion.lua:6:local vault_root = "/Users/mahfuj/Documents/mindspace/content"
```

Lastly, not Obsidian related but there are some artifacts remaining from my migration from vim-plug to lazy.nvim. They shouldn't affect the user experience.
