---@type LazySpec
return {
	"akinsho/toggleterm.nvim",
	cmd = { "ToggleTerm", "TermExec", "TermNew" },
	keys = {
		-- Inspired by <C-`> in Zed/VSCode
		{
			"<M-`>",
			"<Cmd>ToggleTerm direction='horizontal'<CR>",
			mode = { "n", "i", "v", "t" },
			desc = "Toggle terminal (horizontal)",
		},
		-- inspired by <C-~> in Zed/VSCode
		{
			"<M-~>", -- only valid in Neovide
			"<Cmd>TermNew<CR>",
			mode = { "n", "i", "v", "t" },
			desc = "Toggle terminal (horizontal)",
		},
		{
			"<M-\\>",
			"<Cmd>ToggleTerm direction='float'<CR>",
			mode = { "n", "i", "v", "t" },
			desc = "Toggle terminal (float)",
		},
	},
	---@module "toggleterm"
	---@type ToggleTermConfig
	---@diagnostic disable-next-line:missing-fields
	opts = { float_opts = { border = "rounded" } },
}
