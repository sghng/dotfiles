---@type LazySpec
return {
	{ "mason-org/mason.nvim", lazy = true, config = true },
	{
		"mason-org/mason-lspconfig.nvim",
		dependencies = "neovim/nvim-lspconfig",
		event = "VeryLazy",
		config = function()
			require("mason-lspconfig").setup(
				---@type MasonLspconfigSettings
				{
					ensure_installed = {
						"air", -- R LSP and Formatter
						"cssls",
						"html",
						"jsonls",
						"lemminx", -- xml
						"lua_ls",
						"marksman",
						"ruff",
						"tailwindcss",
						"taplo", -- toml
						"ts_ls",
						"unocss",
						"vimls",
						"vue_ls",
					},
				}
			)

			--- Additional configuration for Vue.js support
			local vue_ls_path = vim.fn.expand("$MASON/packages/vue-language-server")
			local vue_plugin_path = vue_ls_path .. "/node_modules/@vue/language-server"
			vim.lsp.config("ts_ls", {
				init_options = {
					plugins = {
						{
							name = "@vue/typescript-plugin",
							location = vue_plugin_path,
							languages = { "vue" },
						},
					},
				},
				filetypes = { "typescript", "javascript", "vue" },
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
