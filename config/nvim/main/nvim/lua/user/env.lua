-- lua/user/env.lua
local M = {}

-- Get vault path from environment variable or use a default.
-- The path should be absolute.
M.vault_path = vim.fn.expand(vim.env.VAULT_PATH or "~/Documents/mindspace/content")

return M
