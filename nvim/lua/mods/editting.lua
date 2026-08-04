---@type LazySpec
return {
	{
		"tpope/vim-unimpaired",
		dependencies = "afreakk/unimpaired-which-key.nvim",
		event = "BufEnter",
		config = function()
			require("which-key").add(require("unimpaired-which-key"))
		end,
	},
	-- sets shiftwidth expandtab heuristically
	{ "tpope/vim-sleuth", event = { "BufReadPost", "BufNewFile" } },
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		event = { "BufReadPost", "BufNewFile" },
		opts = {},
	},
	{ "kylechui/nvim-surround", event = { "BufReadPost", "BufNewFile" }, opts = {} },
	{
		"mbbill/undotree",
		keys = {
			{
				"<Leader>u",
				vim.cmd.UndotreeToggle,
				desc = "Toggle [u]ndo tree",
			},
		},
		cmd = { "UndotreeToggle", "UndotreeShow" },
		config = function()
			vim.g.undotree_WindowLayout = 2
		end,
	},
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		opts = { check_ts = true, fast_wrap = {} },
	},
	{
		"windwp/nvim-ts-autotag",
		dependencies = "nvim-treesitter/nvim-treesitter",
		event = function()
			local ft = { "astro", "html", "jsx", "md", "tsx", "vue", "xml" }
			return { "InsertEnter *.{" .. table.concat(ft, ",") .. "}" }
		end,
		opts = {}, -- required
	},
	-- TODO: need to compare more align plugins
	{ "echasnovski/mini.align", event = { "BufReadPost", "BufNewFile" }, opts = {} },
	{ "echasnovski/mini.cursorword", event = { "BufReadPost", "BufNewFile" }, opts = {} },
	{
		"folke/ts-comments.nvim",
		event = { "BufReadPost", "BufNewFile" },
		keys = {
			{ "<C-/>", "gcc", remap = true, desc = "toggle comment", mode = { "n", "i" } },
			{ "<C-/>", "gc", remap = true, desc = "toggle comment", mode = "v" },
		},
	},
}
