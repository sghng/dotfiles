---@type LazySpec
return {
	"saghen/blink.cmp",
	version = "*", -- needed for fuzzy binary download
	dependencies = "rafamadriz/friendly-snippets",
	event = "InsertEnter",
	---@type blink.cmp.Config
	opts = {
		keymap = { preset = "default" },
		sources = { default = { "lsp", "path", "snippets", "buffer" } },
	},
}
