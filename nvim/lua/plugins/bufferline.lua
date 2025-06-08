local keys = {}
for i = 1, 5 do
	table.insert(keys, {
		"<Leader>" .. i,
		"<Cmd>BufferLineGoToBuffer " .. i .. "<CR>",
		desc = "Go to buffer " .. i,
	})
end
table.insert(keys, {
	"gD",
	"<Cmd>BufferLinePickClose<CR>",
	desc = "Pick buffer to close",
	noremap = true,
})

---@type LazySpec
return {
	"akinsho/bufferline.nvim",
	dependencies = "nvim-tree/nvim-web-devicons",
	event = "BufEnter",
	keys = keys,
	init = function()
		vim.opt.termguicolors = true
		vim.opt.mousemoveevent = true
	end,
	---@module "bufferline"
	---@type bufferline.UserConfig
	opts = {
		options = {
			separator_style = "slope",
			hover = { enabled = true, reveal = { "close" } },
			diagnostics = "nvim_lsp",
			diagnostics_indicator = function(count, level, diagnostics_dict, context)
				local icon = level:match("error") and " " or " "
				return " " .. icon .. count
			end,
			numbers = "ordinal",
			offsets = { {
				filetype = "neo-tree",
				highlight = "Directory",
				text = "neo-tree",
			} },
		},
		highlights = {
			-- dim separators
			separator = { fg = { attribute = "bg", highlight = "Pmenu" } },
			separator_selected = {
				fg = { attribute = "bg", highlight = "PmenuSel" },
			},
		},
	},
}
