---@type LazySpec
return {
	{ "mason-org/mason.nvim", lazy = true, config = true },
	{
		"mason-org/mason-lspconfig.nvim",
		dependencies = "neovim/nvim-lspconfig",
		event = { "BufRead", "BufNewFile" },
		---@type MasonLspconfigSettings
		opts = {
			ensure_installed = {
				"air", -- R
				"cssls",
				"html",
				"jsonls",
				"lemminx", -- XML
				"lua_ls",
				"marksman",
				"pyrefly", -- Python, LSP
				"ruff", -- Python, formatter/linter
				"tailwindcss",
				"taplo", -- TOML
				"ts_ls",
				"ty", -- Python, type checker
				"unocss",
				-- FIXME: vale is too noisy, find alternatives
				-- "vale_ls", -- LS for proses
				"vimls",
				"vue_ls",
			},
			-- NOTE: `ty` is currently unstable
			automatic_enable = { exclude = { "ty" } },
		},
		config = function(_, opts)
			require("mason-lspconfig").setup(opts)
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
				"eslint_d",
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
