-- TODO: break this file down

---@type LazySpec
return {
	-- Project management

	{
		"folke/todo-comments.nvim",
		dependencies = "nvim-lua/plenary.nvim",
		event = { "BufReadPost", "BufNewFile" },
		cmd = {
			"TodoTelescope",
			"TodoLocList",
			"TodoTrouble",
			"TodoQuickFix",
		},
		keys = {
			{
				"<Leader>ft",
				"<Cmd>TodoTelescope<CR>",
				desc = "[f]ind [t]odos in Telescope",
			},
			-- TODO: maybe we should use Trouble for this?
			{
				"<Leader>lt",
				"<Cmd>TodoLocList<CR>",
				desc = "[l]ist [t]odos",
			},
			-- overrides tag navigation, which is obsolete now
			{
				"]t",
				function()
					require("todo-comments").jump_next()
				end,
				desc = "next [t]odo comment",
			},
			{
				"[t",
				function()
					require("todo-comments").jump_prev()
				end,
				desc = "next [t]odo comment",
			},
		},
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
		event = { "BufReadPost", "BufNewFile" }, -- needed for bookmarks rendering
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

	-- Misc

	{ "tpope/vim-sensible", event = "VimEnter" },
	{
		"ggandor/leap.nvim",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			require("leap").set_default_mappings()
		end,
	},
	{
		"christoomey/vim-tmux-navigator",
		keys = {
			{ "<C-h>", "<Cmd>TmuxNavigateLeft<CR>", mode = { "n", "i", "t", "v" } },
			{ "<C-j>", "<Cmd>TmuxNavigateDown<CR>", mode = { "n", "i", "t", "v" } },
			{ "<C-k>", "<Cmd>TmuxNavigateUp<CR>", mode = { "n", "i", "t", "v" } },
			{ "<C-l>", "<Cmd>TmuxNavigateRight<CR>", mode = { "n", "i", "t", "v" } },
		},
		init = function()
			vim.g.tmux_navigator_no_mappings = 1
		end,
	},
	{
		-- TODO: the naviations after entering Zen mode doesn't persist, the
		-- status line are also showing up when exiting neo-tree, create issue
		-- toggling neo-tree breaks Zen mode
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
		---@diagnostic disable-next-line: missing-fields
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
	},
	{
		"akinsho/toggleterm.nvim",
		cmd = "ToggleTerm",
		keys = {
			{
				"<C-\\>",
				"<Cmd>ToggleTerm direction='horizontal'<CR>",
				mode = { "n", "i", "v", "t" },
				desc = "Toggle terminal (horizontal)",
			},
			{
				"<M-\\>",
				"<Cmd>ToggleTerm direction='float'<CR>",
				mode = { "n", "i", "v", "t" },
				desc = "Toggle terminal (float)",
			},
			{
				"<C-|>",
				"<Cmd>ToggleTerm direction='tab'<CR>",
				mode = { "n", "i", "v", "t" },
				desc = "Toggle terminal (tab)",
			},
		},
		---@module "toggleterm"
		---@type ToggleTermConfig
		---@diagnostic disable-next-line:missing-fields
		opts = { float_opts = { border = "rounded" } },
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
		event = "UIEnter",
		opts = {
			-- Cursor animation handled by terminal emulator
			cursor = { enable = false },
			-- Window open/close animations doesn't work with transparency
			open = { enable = false },
			close = { enable = false },
		},
	},
	{ "Bekaboo/deadcolumn.nvim", event = { "BufReadPost", "BufNewFile" } },
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
		event = "UIEnter",
		---@module "noice"
		---@type NoiceConfig
		---@diagnostic disable-next-line: missing-fields
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
			routes = {
				filter = {},
			},
		},
	},
	{
		"hat0uma/csvview.nvim",
		cmd = { "CsvViewEnable", "CsvViewDisable", "CsvViewToggle" },
		keys = {
			{
				"<Localleader>v",
				"<Cmd>CsvViewToggle<CR>",
				desc = "Toggle CSV table [v]iew",
				ft = { "csv", "tsv" },
			},
		},
		---@module "csvview"
		---@type CsvView.Options
		opts = { parser = { quote_char = '"' } }, -- somehow needs to be specified
	},
}
