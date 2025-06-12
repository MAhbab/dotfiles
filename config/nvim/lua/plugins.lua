return {
  { "folke/lazy.nvim" }, -- bootstrap plugin manager
  { "rust-lang/rust.vim" },
  { "hrsh7th/nvim-cmp" },
  { "hrsh7th/cmp-nvim-lsp" },
  { "hrsh7th/cmp-path" },
  { "hrsh7th/cmp-buffer" },
  { "L3MON4D3/LuaSnip" },
  { "saadparwaiz1/cmp_luasnip" },
  { "neovim/nvim-lspconfig" },
  { "williamboman/mason.nvim" },
  { "williamboman/mason-lspconfig.nvim" },
  { "Exafunction/codeium.vim", branch = "main" },
  { "nvim-lua/plenary.nvim" },
  { "nvim-telescope/telescope.nvim", build = ":UpdateRemotePlugins" },
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },

  {
    "epwalsh/obsidian.nvim",
    config = function()
      -- Remove problematic autocommands (BufWritePre *.md)
      vim.schedule(function() 
	pcall(vim.api.nvim_del_augroup_by_name, "obsidian_setup")
      end)
    end,
  },
}
