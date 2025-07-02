require("nvim-treesitter.configs").setup({
  ensure_installed = {
    "python",
    "rust",
    "lua",
    "sql",
    "yaml",
    "bash",
    "json",
    "markdown",
  },
  highlight = {
    enable = true,
  },
  indent = {
    enable = true,
  },
})
