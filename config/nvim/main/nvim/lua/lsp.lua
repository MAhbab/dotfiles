-- lua/lsp.lua
local lspconfig = require("lspconfig")

-- Enhance capabilities for nvim-cmp
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- Define LSP keybindings per buffer
local on_attach = function(client, bufnr)
  local buf_map = function(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { noremap = true, silent = true, buffer = bufnr, desc = desc })
  end

  buf_map("n", "gd", vim.lsp.buf.definition, "Go to definition")
  buf_map("n", "gp", vim.lsp.buf.hover, "Peek definition (hover)")
  buf_map("n", "<leader>ld", "<cmd>Telescope lsp_document_symbols<cr>", "Document symbols")
  buf_map("n", "<leader>lw", "<cmd>Telescope lsp_workspace_symbols<cr>", "Workspace symbols")
end

-- Setup mason
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = { "pyright", "rust_analyzer" },
})

-- Hook mason-installed servers to lspconfig
require("mason-lspconfig").setup_handlers({
  function(server_name)
    lspconfig[server_name].setup({
      capabilities = capabilities,
      on_attach = on_attach,
    })
  end,
})

-- Optional: Explicit setup if you want extra config
-- This will override the handler above
lspconfig.rust_analyzer.setup({
  capabilities = capabilities,
  on_attach = on_attach,
})

-- lua lsp
require('lspconfig').lua_ls.setup {
  settings = {
    Lua = {
      workspace = {
        checkThirdParty = false,
        library = vim.api.nvim_get_runtime_file("", true),
      },
      diagnostics = {
        globals = { "vim" },
      },
      telemetry = { enable = false },
    }
  }
}
