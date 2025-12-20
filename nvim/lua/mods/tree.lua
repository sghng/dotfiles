---@type LazySpec
return {
	{
		"nvim-neo-tree/neo-tree.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			"MunifTanjim/nui.nvim",
			"3rd/image.nvim",
			"s1n7ax/nvim-window-picker",
		},
		lazy = false,
		keys = {
			{
				"<Leader>\\", -- inspired by / suggested by Neo-tree
				"<Cmd>Neotree toggle current reveal_force_cwd<CR>",
				desc = "Open current [d]irectory",
			},
			{
				"|", -- suggested by Neo-tree
				"<Cmd>Neotree toggle left<CR>",
				desc = "Reveal file in Neotree sidebar",
			},
			{
				"<Leader>r", -- Neo-tree suggested gd, which conflicts with go to definition
				"<Cmd>Neotree float reveal reveal_force_cwd<CR>",
				desc = "[r]eveal file in Neotree popup",
			},
			{
				"<Leader>bb", -- inspired by <Leader>b suggested by Neo-tree
				"<Cmd>Neotree toggle show buffers right<CR>",
				desc = "Toggle [b]uffer explorer",
			},
			{
				"<Leader>s", -- suggested by Neo-tree
				"<Cmd>Neotree toggle float git_status<CR>",
				desc = "Show Git [s]tatus in Neotree",
			},
		},
		---@module "neo-tree"
		---@type neotree.Config
		opts = {
			filesystem = {
				bind_to_cwd = true,
				hijack_netrw_behavior = "open_current",
				filtered_items = { hide_dotfiles = false },
			},
			window = {
				width = 25,
				mappings = {
					["P"] = { "toggle_preview", config = { use_image_nvim = true } },
				},
			},
			event_handlers = {
				{
					event = "neo_tree_buffer_enter",
					handler = function()
						vim.opt_local.relativenumber = true
					end,
				},
			},
			---@diagnostic disable-next-line: missing-fields
			source_selector = { winbar = true }, -- statusline is taken
		},
	},
	{
		"s1n7ax/nvim-window-picker",
		lazy = true, -- delay until needed
		opts = {
			hint = "floating-big-letter",
			picker_config = { handle_mouse_click = true },
		},
	},
	{
		-- Update import paths when renaming files
		"antosha417/nvim-lsp-file-operations",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-neo-tree/neo-tree.nvim",
		},
		event = "LspAttach",
		opts = {}, -- required
	},
	{
		"stevearc/oil.nvim",
		dependencies = "nvim-tree/nvim-web-devicons",
		cmd = "Oil",
		---@module 'oil'
		---@type oil.SetupOpts
		opts = { default_file_explorer = false },
	},
}
