---@type LazySpec
return {
	"nvim-lualine/lualine.nvim",
	dependencies = "nvim-tree/nvim-web-devicons",
	event = { "BufReadPost", "BufNewFile" },
	opts = {
		options = {
			globalstatus = true,
			theme = "gruvbox-material",
			disabled_filetypes = { winbar = { "neo-tree" } },
		},
		extensions = {
			"aerial",
			"lazy",
			"mason",
			"neo-tree",
			"quickfix",
			"toggleterm",
			"trouble",
		},
		winbar = {
			lualine_a = {
				{
					function()
						-- the symbols from LSPSaga is better than Aerial
						return require("lspsaga.symbol.winbar").get_bar() or ""
					end,
					separator = { right = "" },
				},
			},
			lualine_z = { { "filename" } },
		},
		inactive_winbar = { lualine_z = { "filename" } },
	},
	init = function()
		vim.opt.laststatus = 3 -- lualine spans whole window
	end,
}
