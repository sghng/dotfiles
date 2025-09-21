vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "[g]o to definition" })
---@type LazySpec
return {

	-- LSP Installation and Config

	{
		"mason-org/mason-lspconfig.nvim",
		dependencies = {
			{ "mason-org/mason.nvim", cmd = "Mason", opts = {} },
			"neovim/nvim-lspconfig", -- must be manually loaded
		},
		-- Language servers should be ready before entering buffer to ensure
		-- proper syntax highlighting
		event = { "BufReadPre", "BufNewFile" },
		---@type MasonLspconfigSettings
		opts = {
			ensure_installed = {
				"air", -- R
				"bashls",
				"clangd",
				"cssls",
				"fish_lsp",
				"html",
				"jsonls",
				"just",
				"lemminx", -- XML
				"lua_ls",
				"marksman",
				"neocmake", -- CMake
				"oxlint",
				"ruff", -- Python formatter/linter
				"tailwindcss",
				"taplo", -- TOML
				"ts_ls", -- TypeScript
				"ty", -- Python LSP/type checker
				"tinymist", -- Typst LSP
				"unocss",
				-- FIXME: vale is too noisy, find alternatives
				-- "vale_ls", -- LS for proses
				"vimls",
				"vue_ls",
			},
		},
		config = function(_, opts)
			require("mason-lspconfig").setup(opts)
			-- Additional configuration for Vue.js support, see:
			-- https://github.com/vuejs/language-tools/wiki/Neovim
			-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#vue_ls
			local vue_ls_path = vim.fn.expand("$MASON/packages/vue-language-server/")
			local vue_plugin_path = vue_ls_path .. "node_modules/@vue/language-server/"
			vim.lsp.config("ts_ls", {
				init_options = {
					plugins = {
						{
							name = "@vue/typescript-plugin",
							location = vue_plugin_path,
							languages = { "vue" },
							configNamespace = "typescript",
						},
					},
				},
				filetypes = { "typescript", "javascript", "vue" },
			})
		end,
	},

	-- Non-LSP injected LSP options

	{ "nvimtools/none-ls.nvim", lazy = true },

	-- LSP Utilities

	{
		-- context breadcrumb, call hierarchy, code action,
		-- definitions peeking (Trouble can't display this in hover)
		-- not actively maintained
		-- TODO: could be helpful
		"nvimdev/lspsaga.nvim",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
			"nvim-treesitter/nvim-treesitter",
		},
		cmd = "Lspsaga",
		keys = {
			"<Leader>lo",
			"<Cmd>Lspsaga outline<CR>",
			desc = "[l]ist [o]utline (LSPSaga)",
		},
		opts = {
			lightbulb = { enable = false }, -- takes up to much space
			symbol_in_winbar = {
				enable = false, -- handover to lualine
				separator = " ",
				show_file = false,
			},
		},
	},
	{
		-- TODO: could be helpful
		"stevearc/aerial.nvim",
		event = "LspAttach",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-tree/nvim-web-devicons",
		},
		opts = {}, -- required
	},
}
