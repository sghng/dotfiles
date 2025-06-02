---@type LazySpec
return {
	{ "mason-org/mason.nvim", lazy = true, config = true },
	{
		"mason-org/mason-lspconfig.nvim",
		dependencies = "neovim/nvim-lspconfig",
		event = "VeryLazy",
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = {
					"cssls",
					"html",
					"jsonls",
					"lemminx", -- xml
					"lua_ls",
					"marksman",
					"ruff",
					"taplo",
					"ts_ls",
					"unocss",
					"vimls",
					"vue_ls",
				},
			})
		end,
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		event = "VeryLazy",
		opts = {
			ensure_installed = {
				--Linters
				"cspell",
				"markdownlint-cli2",
				"stylua",
				"vint", -- Vim script
				--Formatters
				"prettier",
				"prettierd",
				"shfmt",
			},
			auto_update = true,
		},
	},
}
