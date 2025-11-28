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
	{
	  "LintaoAmons/bookmarks.nvim",
	  -- pin the plugin at specific version for stability
	  -- backup your bookmark sqlite db when there are breaking changes (major version change)
	  tag = "3.2.0",
	  dependencies = {
	    {"kkharji/sqlite.lua"},
	    {"nvim-telescope/telescope.nvim"},  -- currently has only telescopes supported, but PRs for other pickers are welcome 
	    {"stevearc/dressing.nvim"}, -- optional: better UI
	    {"GeorgesAlkhouri/nvim-aider"} -- optional: for Aider integration
	  },
	  config = function()
	    local opts = {} -- check the "./lua/bookmarks/default-config.lua" file for all the options
	    require("bookmarks").setup(opts) -- you must call setup to init sqlite db
	  end,
	}
}
