-- TODO: break this file down

-- Miscellaneous plugins
---@type LazySpec
return {
	-- Misc

	{ "tpope/vim-sensible", event = "VimEnter" },
	{
		"ggandor/leap.nvim",
		event = { "BufReadPost", "BufNewFile" },
		keys = {
			{ "s", "<Plug>(leap)", mode = { "n", "x", "o" } },
			{ "S", "<Plug>(leap-from-window)" },
		},
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
				gitsigns = { enabled = true },
				kitty = { enabled = true, font = "+4" },
				neovide = {
					enabled = true,
					scale = 1.2,
					disable_animations = false,
				},
				tmux = { enabled = true },
				twilight = { enabled = false },
				wezterm = { enabled = true, font = "+4" },
			},
			on_open = function(win)
				vim.opt.winbar = ""
			end,
		},
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
	{
		"Bekaboo/deadcolumn.nvim",
		event = "UIEnter", -- needed for proper highlight
		init = function()
			vim.cmd([[autocmd FileType codecompanion setlocal colorcolumn=]])
		end,
	},
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
		keys = {
			{
				"<Leader>d",
				"<Cmd>Noice dismiss<CR>",
				desc = "[d]ismiss Noice popups",
			},
		},
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
	{ "0xferrous/ansi.nvim", cmd = { "AnsiEnable", "AnsiToggle" } },
}
