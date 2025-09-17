vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "[g]o to definition" })
---@type LazySpec
return {

	-- LSP Installation and Config

	{
		"mason-org/mason-lspconfig.nvim",
		dependencies = {
			{ "mason-org/mason.nvim", cmd = "Mason", opts = {} },
			"neovim/nvim-lspconfig", -- must be manually loaded
			"WhoIsSethDaniel/mason-tool-installer.nvim", -- ensure tools are installed
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
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		lazy = true,
		opts = {
			ensure_installed = {
				--Linters
				"checkmake", -- Makefile
				"cspell",
				"eslint_d",
				"markdownlint-cli2",
				"stylua",
				"vint", -- Vim script
				--Formatters
				"prettier",
				"prettierd",
				"shfmt",
				"typstyle", -- Typst
			},
			auto_update = true,
		},
	},

	-- LSP Utilities

	-- BUG: trouble.nvim not working in Neovim nighly now.
	-- https://github.com/folke/trouble.nvim/issues/655
	-- TODO: we might need better key mappings
	-- NOTE: best thing about trouble picker: preview in real time as we
	-- navigate the picker
	-- FIXME: trouble background is not transparent
	{
		"folke/trouble.nvim",
		cmd = "Trouble",
		keys = {
			{
				"<Leader>xp",
				vim.diagnostic.open_float,
				desc = "Diagnostics [p]opup",
			},
			{
				"<Leader>xx",
				"<Cmd>Trouble diagnostics toggle<CR>",
				desc = "Diagnostics (Trouble)",
			},
			{
				"<Leader>xX",
				"<Cmd>Trouble diagnostics toggle filter.buf=0<CR>",
				desc = "Buffer Diagnostics (Trouble)",
			},
			{
				"<Leader>cs",
				"<Cmd>Trouble symbols toggle focus=false<CR>",
				desc = "Symbols (Trouble)",
			},
			{
				"<Leader>cl",
				"<Cmd>Trouble lsp toggle focus=false win.position=right<CR>",
				desc = "LSP Definitions / references / ... (Trouble)",
			},
			{
				"<Leader>xL",
				"<Cmd>Trouble loclist toggle<CR>",
				desc = "Location List (Trouble)",
			},
			{
				"<Leader>xQ",
				"<Cmd>Trouble qflist toggle<CR>",
				desc = "Quickfix List (Trouble)",
			},
		},
		opts = {}, -- required
	},
	{
		-- provides a few LSP features additional to Trouble:
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
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-tree/nvim-web-devicons",
		},
	},
}
