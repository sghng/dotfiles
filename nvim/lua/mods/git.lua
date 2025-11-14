wk_add({ "<Leader>g", group = "[g]it" })

---@type LazySpec
return {
	{
		"kdheepak/lazygit.nvim",
		cmd = { "LazyGit", "LazyGitConfig", "LazyGitCurrentFile" },
		keys = { { "<Leader>gg", vim.cmd.LazyGit, desc = "Lazy[g]it" } },
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
		dependencies = {
			"nvim-lua/plenary.nvim",
			"sindrets/diffview.nvim",
		},
		cmd = "Neogit",
		keys = {
			{ "<Leader>gn", "<Cmd>Neogit kind=floating<CR>", desc = "open [n]eogit popup" },
		},
	},
}
