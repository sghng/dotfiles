wk_add({ "<Leader>g", group = "[g]it" })

---@type LazySpec
return {
	{
		"kdheepak/lazygit.nvim",
		cmd = { "LazyGit", "LazyGitConfig", "LazyGitCurrentFile" },
		keys = { { "<Leader>gz", vim.cmd.LazyGit, desc = "La[z]y[g]it" } },
		config = function()
			vim.g.lazygit_floating_window_scaling_factor = 0.9
		end,
	},
	{
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPost", "BufNewFile" },
		cmd = "Gitsigns",
		keys = {
			{ "]h", "<Cmd>Gitsigns next_hunk<CR>", desc = "Next [h]unk" },
			{ "[h", "<Cmd>Gitsigns prev_hunk<CR>", desc = "Previous [h]unk" },
			{ "<Leader>gb", "<Cmd>Gitsigns blame<CR>", desc = "[g]it [b]lame" },
			{ "<Leader>gh", "<Cmd>Gitsigns toggle_linehl<CR>", desc = "toggle [g]it hunk [h]ighlight" },
			{ "<Leader>gd", "<Cmd>Gitsigns diffthis<CR>", desc = "[g]it [d]iff this buffer" },
			{ "<Leader>gsh", "<Cmd>Gitsigns stage_hunk<CR>", desc = "[g]it [s]tage this hunk" },
			{ "<Leader>guh", "<Cmd>Gitsigns undo_stage_hunk<CR>", desc = "[g]it [u]nstage this hunk" },
			{ "<Leader>gsb", "<Cmd>Gitsigns stage_buffer<CR>", desc = "[g]it [s]tage this buffer" },
			{ "<Leader>gub", "<Cmd>Gitsigns undo_stage_buffer<CR>", desc = "[g]it [u]nstage this buffer" },
		},
		---@module "gitsigns"
		---@type Gitsigns.Config
		---@diagnostic disable-next-line:missing-fields
		opts = {
			current_line_blame = true,
			preview_config = { border = "rounded" },
			sign_priority = 10, -- push signs to the left
		},
	},
	{
		"NeogitOrg/neogit",
		dependencies = { "nvim-lua/plenary.nvim", "sindrets/diffview.nvim" },
		cmd = "Neogit",
		keys = {
			{ "<Leader>gg", "<Cmd>Neogit kind=floating<CR>", desc = "neo[g]it popup" },
			{ "<Leader>gl", "<Cmd>Neogit log kind=tab<CR>", desc = "[g]it [l]og" },
		},
	},
	{
		"pwntester/octo.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			"folke/snacks.nvim",
		},
		cmd = "Octo",
		keys = {
			{ "<Leader>oi", "<Cmd>Octo issue list<CR>", desc = "GitHub Issues" },
			{ "<Leader>op", "<Cmd>Octo pr list<CR>", desc = "GitHub PullRequests" },
			{ "<Leader>od", "<Cmd>Octo discussion list<CR>", desc = "GitHub Discussions" },
			{ "<Leader>on", "<Cmd>Octo notification list<CR>", desc = "GitHub Notifications" },
			{
				"<Leader>os",
				function()
					require("octo.utils").create_base_search_command({ include_current_repo = true })
				end,
				desc = "Search GitHub",
			},
		},
		---@type OctoConfig
		---@diagnostic disable-next-line: missing-fields
		opts = { picker = "snacks", enable_builtin = true },
	},
}
