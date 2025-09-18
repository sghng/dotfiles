---@type LazySpec
return {
	{
		"saghen/blink.cmp",
		version = "*", -- needed for fuzzy binary download
		dependencies = "rafamadriz/friendly-snippets",
		event = { "InsertEnter", "CmdLineEnter" },
		cmd = "BlinkCmp",
		---@module "blink-cmp"
		---@type blink.cmp.Config
		opts = {
			completion = {
				keyword = { range = "full" },
				documentation = { auto_show = true, auto_show_delay_ms = 500 },
			},
			sources = {
				default = { "lsp", "path", "snippets", "buffer", "omni" },
				providers = {
					-- display snippets according to embedded language, see:
					-- https://github.com/nvim-treesitter/nvim-treesitter/discussions/6643
					-- https://github.com/Saghen/blink.cmp/issues/1679
					snippets = {
						opts = {
							get_filetype = function(context)
								local curline = vim.fn.line(".")
								local lang =
									vim.treesitter.get_parser():language_for_range({ curline, 0, curline, 0 }):lang()
								return lang
							end,
						},
					},
				},
			},
			term = { enabled = true }, -- term completion disabled by default
		},
	},
	{
		"fang2hou/blink-copilot",
		dependencies = {
			{ "zbirenbaum/copilot.lua", cmd = "Copilot", opts = {} },
			{
				"saghen/blink.cmp",
				---@module "blink-cmp"
				---@type blink.cmp.Config
				opts = {
					sources = {
						default = { "copilot" },
						providers = {
							copilot = {
								name = "copilot",
								module = "blink-copilot",
								async = true,
							},
						},
					},
				},
				opts_extend = { "sources.default" },
			},
		},
		event = "InsertEnter",
	},
}
