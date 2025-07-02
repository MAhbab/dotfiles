-- Bootstrap Lazy.nvim if it isn't installed
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath
  })
end


vim.opt.rtp:prepend(lazypath)
-- init.lua
vim.loader.enable()

-- Relative line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Convert string to keycodes
local function feedkeys(keys)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "n", false)
end

-- Map <leader>f to your macro (equivalent to pressing %hh d%)
vim.keymap.set("n", "<leader>f", function()
  feedkeys("%hhd%")
end, { noremap = true, silent = true })

-- Add lazy.nvim to runtime path
vim.opt.rtp:prepend("~/.config/nvim/lazy/lazy.nvim")

-- Set python3 host
vim.g.python3_host_prog = "/Users/mahfuj/.venvs/mono/bin/python"

require("lazy").setup("plugins")

-- Load your existing modules
require("completion")
require("lsp")
require("mappings")
require("treesitter")
require("user.obsidian.patch")
require("user.obsidian.find_by_field")
require("user.obsidian.config")
require("user.obsidian.template_manager")
require("utils.path")

-- Reload Module
P = function(v)
  print(vim.inspect(v))
  return v
end

RELOAD = function(name)
  package.loaded[name] = nil
  return require(name)
end

R = function(name)
  return P(RELOAD(name))
end

-- remove BufWritePre *.md autocommands
vim.api.nvim_clear_autocmds({
  event = "BufWritePre",
  pattern = "*.md",
})
