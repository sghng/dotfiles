---@type LazySpec
return {
	{
		"folke/lazydev.nvim",
		ft = "lua",
		---@module "lazydev"
		---@type lazydev.Config
		opts = { library = { "lazy.nvim" } },
	},
	{
		"saghen/blink.cmp",
		---@module "blink-cmp"
		---@type blink.cmp.Config
		opts = {
			sources = {
				default = { "lazydev" },
				providers = {
					lazydev = {
						name = "LazyDev",
						module = "lazydev.integrations.blink",
						score_offset = 100, -- prioritize lazydev
					},
				},
			},
		},
		opts_extend = { "sources.default" },
	},
}
