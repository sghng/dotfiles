---@type LazySpec
return {
	"folke/which-key.nvim",
	dependencies = "nvim-tree/nvim-web-devicons",
	-- we want this plugin to be loaded for keymaps hints
	event = "VeryLazy",
	keys = { {
		"<Leader>?",
		"<Cmd>WhichKey<CR>",
		desc = "Local Keymaps (which-key)",
	} },
	---@module "which-key"
	---@type wk.Config
	---@diagnostic disable-next-line: missing-fields
	opts = {
		preset = "helix",
		delay = function(ctx)
			return ctx.plugin and 0 or 500
		end,
		keys = {
			scroll_down = "<Down>",
			scroll_up = "<Up>",
		},
		spec = {
			-- common groupings
			{ "<Leader>b", group = "buffer" },
			{ "<Leader>f", group = "[f]ind (with Telescope)" },
			{ "[", group = "Previous..." },
			{ "]", group = "Previous..." },
			{ "gr", group = "LSP operations" },
			-- common keymaps
		},
	},
}
