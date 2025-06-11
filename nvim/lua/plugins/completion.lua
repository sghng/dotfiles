---@type LazySpec
return {
	{ "saghen/blink.compat", opts = {} },
	{
		"saghen/blink.cmp",
		version = "*", -- needed for fuzzy binary download
		dependencies = "L3MON4D3/LuaSnip",
		event = "InsertEnter",
		cmd = "BlinkCmp",
		---@type blink.cmp.Config
		opts = {
			completion = {
				keyword = { range = "full" },
				documentation = { auto_show = true, auto_show_delay_ms = 500 },
			},
			signature = { enabled = true },
			snippets = { preset = "luasnip" },
			sources = { default = { "lsp", "path", "snippets", "buffer", "cmdline", "omni" } },
			term = { enabled = true },
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
	{
		"L3MON4D3/LuaSnip",
		dependencies = "rafamadriz/friendly-snippets",
		build = "make install_jsregexp",
		config = function()
			require("luasnip.loaders.from_vscode").lazy_load()
			require("luasnip").setup()
		end,
	},
}
