---@type LazySpec
return {
	{
		"sainnhe/gruvbox-material",
		lazy = false,
		config = function()
			vim.g.gruvbox_material_enable_bold = 1
			vim.g.gruvbox_material_enable_italic = 1
			vim.g.gruvbox_material_transparent_background = 2
			vim.cmd.colorscheme("gruvbox-material")
		end,
	},
	{
		"neanias/everforest-nvim",
		cond = false,
		opts = {
			background = "soft",
			transparent_background_level = 1,
		},
		config = function(_, opts)
			require("everforest").setup(opts)
			vim.cmd.colorscheme("everforest")
		end,
	},
}
