---@type LazySpec
return {
	-- Project management

	{
		"folke/todo-comments.nvim",
		dependencies = "nvim-lua/plenary.nvim",
		event = { "BufRead", "BufNewFile" },
		opts = {}, -- required
	},
	{
		-- TODO: need to figure this out
		"LintaoAmons/bookmarks.nvim",
		dependencies = {
			"kkharji/sqlite.lua",
			"nvim-telescope/telescope.nvim",
			"stevearc/dressing.nvim", -- optional: better UI
		},
		event = { "BufRead", "BufNewFile" }, -- needed for bookmarks rendering
		cmd = {
			"BookmarksCommands",
			"BookmarksGrep",
			"BookmarksInfo",
			"BookmarksLists",
			"BookmarksNewLists",
			"BookmarksQuery",
		},
		config = function()
			require("bookmarks").setup() -- required for DB initailization
		end,
	},

	-- Language support

	{
		-- provides context breadcrumbs, symbols outline, etc
		-- TODO: better key binding since this is helpful
		"nvimdev/lspsaga.nvim",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
			"nvim-treesitter/nvim-treesitter",
		},
		event = "LspAttach",
		opts = { lightbulb = { enable = false } }, -- takes up to much space
	},
	{
		"stevearc/aerial.nvim",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-tree/nvim-web-devicons",
		},
		-- FIXME: need to remap this, Aerial jumps based on function only
		keys = {
			{ "{", "<Cmd>AerialPrev<CR>" },
			{ "}", "<Cmd>AerialNext<CR>" },
		},
		cmd = {
			"AerialInfo",
			"AerialNavOpen",
			"AerialNavToggle",
			"AerialOpen",
			"AerialOpenAll",
			"AerialToggle",
		},
		opts = {}, -- required
	},
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

	-- Misc

	{ "tpope/vim-sensible", event = "VimEnter" },
	{
		"ggandor/leap.nvim",
		config = function()
			require("leap").set_default_mappings()
		end,
	},
	{
		-- TODO: doesn't work in terminal window, create an issue
		"christoomey/vim-tmux-navigator",
		keys = {
			{ "<C-h>", "<Cmd><C-U>TmuxNavigateLeft<CR>" },
			{ "<C-j>", "<Cmd><C-U>TmuxNavigateDown<CR>" },
			{ "<C-k>", "<Cmd><C-U>TmuxNavigateUp<CR>" },
			{ "<C-l>", "<Cmd><C-U>TmuxNavigateRight<CR>" },
		},
	},
	{
		-- TODO: the naviations after entering Zen mode doesn't persist, the
		-- status line are also showing up when exiting neo-tree, create issue
		"folke/zen-mode.nvim", -- automatically enabled in zen mode
		dependencies = {
			"folke/twilight.nvim",
			dependencies = "nvim-treesitter/nvim-treesitter",
			cmd = { "Twilight", "TwilightEnable" },
			opts = { dimming = { alpha = 0.5 } },
		},
		cmd = "ZenMode",
		keys = { { "<Leader>z", "<Cmd>ZenMode<CR>", desc = "Toggle [Z]en Mode" } },
		---@module "zen-mode"
		---@type ZenOptions
		---@diagnostic disable: missing-fields
		opts = {
			plugins = {
				options = { laststatus = 0 }, -- hide statusline
				tmux = { enabled = true },
				kitty = { enabled = true, font = "+4" },
				wezterm = { enabled = true, font = "+4" },
				neovide = {
					enabled = true,
					scale = 1.2,
					disable_animations = false,
				},
			},
		},
		---@diagnostic enable: missing-fields
	},
	{
		"akinsho/toggleterm.nvim",
		cmd = "ToggleTerm",
		keys = {
			{
				"<C-\\>",
				"<Cmd>ToggleTerm<CR>",
				mode = { "n", "i", "v", "t" },
				desc = "Toggle terminal",
			},
		},
		config = true,
	},
	{
		"sitiom/nvim-numbertoggle",
		event = "InsertEnter",
		init = function()
			vim.opt.number = true
			vim.opt.relativenumber = true
		end,
	},
	{
		"echasnovski/mini.animate",
		cond = not vim.g.neovide,
		-- TODO: window animations conflict with neo-tree, file issues
		opts = { open = { enable = false }, close = { enable = false } },
	},
	"Bekaboo/deadcolumn.nvim",
	{
		"ellisonleao/dotenv.nvim",
		lazy = false,
		cmd = { "Dotenv", "DotenvGet" },
		config = function()
			require("dotenv").setup()
			vim.cmd("Dotenv ~/.env")
		end,
	},
	{
		"folke/noice.nvim",
		dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" },
		event = "VeryLazy",
		---@module "noice"
		---@type NoiceConfig
		opts = {
			views = {
				cmdline_popup = { position = { row = -5 } },
				mini = {
					border = { style = "rounded" },
					position = { row = -2 },
				},
			},
			lsp = {
				-- override markdown rendering to enable treesitter highlighting
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
				},
				hover = { silent = true },
			},
			-- you can enable a preset for easier configuration
			presets = {
				long_message_to_split = true, -- long messages will be sent to a split
				lsp_doc_border = true,
			},
		},
	},
}
