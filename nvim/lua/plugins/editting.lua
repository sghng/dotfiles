---@type LazySpec
return {
	{ "tummetott/unimpaired.nvim", event = { "BufReadPost", "BufNewFile" } },
	-- sets shiftwidth expandtab heuristically
	{ "tpope/vim-sleuth", event = { "BufReadPost", "BufNewFile" } },
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		event = { "BufReadPost", "BufNewFile" },
		opts = {},
	},
	-- TODO: potential overlapping keymaps in Which Key
	{ "kylechui/nvim-surround", event = { "BufReadPost", "BufNewFile" }, opts = {} },
	{
		"mbbill/undotree",
		keys = {
			{
				"<Leader>u",
				vim.cmd.UndotreeToggle,
				{ desc = "Toggle [u]ndo tree" },
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
	-- TODO: potential overlapping keymaps in Which Key
	{
		"numToStr/Comment.nvim",
		dependencies = {
			"JoosepAlviste/nvim-ts-context-commentstring",
			-- auto cmd must be disabled for integration with comment plugins
			---@type ts_context_commentstring.Config
			opts = { enable_autocmd = false },
		},
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			require("Comment").setup(
				---@module "Comment"
				---@type CommentConfig
				---@diagnostic disable-next-line: missing-fields
				{
					-- Must be dynamically configured, hook required for JSX
					pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
				}
			)
		end,
	},
}
