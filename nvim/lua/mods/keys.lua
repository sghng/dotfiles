---@type wk.Spec[]
local spec = {
	-- common groupings
	{ "<Leader>b", group = "[b]uffer" },
	{ "<Localleader>o", group = "[o]bsidian" },
	{ "[", group = "Jump to the previous..." },
	{ "]", group = "Jump to the next..." },
	{ "gr", group = "LSP operations" },
	-- common keymaps, reuse established standard from other IDEs
	{ "<F2>", vim.lsp.buf.rename, desc = "Rename Symbol" }, -- VSCode/Zed
	{ "<F8>", vim.diagnostic.open_float, desc = "Expand diagnostic details" }, -- VSCode/Zed
}

---@type LazySpec
return {
	"folke/which-key.nvim",
	dependencies = "nvim-tree/nvim-web-devicons",
	-- we want this plugin to be loaded for keymaps hints
	lazy = false,
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
		spec = spec,
	},
}
