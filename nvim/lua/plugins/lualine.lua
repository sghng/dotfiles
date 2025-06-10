local noice = require("noice")
---@type LazySpec
return {
	"nvim-lualine/lualine.nvim",
	dependencies = "nvim-tree/nvim-web-devicons",
	event = { "BufRead", "BufNewFile" },
	opts = {
		options = {
			theme = "gruvbox-material",
			extensions = {
				"aerial",
				"fugitive",
				"lazy",
				"mason",
				"neo-tree",
				"toggleterm",
			},
		},
		sections = {
			lualine_x = {
				{
					noice.api.status.command.get,
					cond = noice.api.status.command.has,
					color = { fg = "#ff9e64" },
				},
				{
					noice.api.status.search.get,
					cond = noice.api.status.search.has,
					color = { fg = "#ff9e64" },
				},
			},
		},
	},
	init = function()
		vim.opt.laststatus = 3 -- lualine spans whole window
	end,
}
