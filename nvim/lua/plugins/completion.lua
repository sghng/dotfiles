---@type LazySpec
return {
	{
		"saghen/blink.cmp",
		version = "*", -- needed for fuzzy binary download
		dependencies = "rafamadriz/friendly-snippets",
		event = "InsertEnter",
		---@type blink.cmp.Config
		opts = {
			completion = {
				keyword = { range = "full" },
				documentation = { auto_show = true, auto_show_delay_ms = 500 },
			},
			signature = { enabled = true },
			sources = { default = { "lsp", "path", "snippets", "buffer" } },
		},
	},
	{
		"fang2hou/blink-copilot",
		dependencies = {
			"zbirenbaum/copilot.lua",
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
