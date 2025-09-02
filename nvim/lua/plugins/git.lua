---@type LazySpec
return {
	{ "tpope/vim-fugitive", event = "VeryLazy" }, -- too many commands
	{
		"airblade/vim-gitgutter",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			vim.cmd("GitGutterLineNrHighlightsEnable")
		end,
	},
	{
		"kdheepak/lazygit.nvim",
		cmd = {
			"LazyGit",
			"LazyGitConfig",
			"LazyGitCurrentFile",
			"LazyGitFilter",
			"LazyGitFilterCurrentFile",
			"LazyGitLog",
		},
		keys = { { "<Leader>g", vim.cmd.LazyGit, desc = "Lazy[g]it" } },
		config = function()
			vim.g.lazygit_floating_window_scaling_factor = 0.9
		end,
	},
}
