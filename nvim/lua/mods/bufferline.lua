---@type LazyKeysSpec[]
local keys = {}
for i = 1, 5 do
	table.insert(keys, {
		"<Leader>" .. i,
		"<Cmd>BufferLineGoToBuffer " .. i .. "<CR>",
		desc = "Go to buffer [" .. i .. "]",
	})
end
table.insert(keys, {
	"bD",
	"<Cmd>BufferLinePickClose<CR>",
	desc = "Pick [b]uffer to [d]elete",
})

---@type LazySpec
return {
	"akinsho/bufferline.nvim",
	dependencies = "nvim-tree/nvim-web-devicons",
	-- load before UIEnter in Neovide for correct bg
	event = vim.g.neovide and "ColorScheme" or { "BufReadPost", "BufNewFile" },
	keys = keys,
	init = function()
		vim.opt.mousemoveevent = true -- required for hovering
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
