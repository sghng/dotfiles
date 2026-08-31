---@type LazySpec
return {
	{
		"nvim-treesitter/nvim-treesitter",
		event = { "BufReadPost", "BufNewFile" },
		-- TODO: enable tree sitter features
		config = function()
			vim.api.nvim_create_autocmd("FileType", {
				callback = function(args)
					local lang = vim.treesitter.language.get_lang(args.match)
					if lang and require("nvim-treesitter.parsers")[lang] then
						require("nvim-treesitter").install({ lang })
					end
				end,
			})
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		branch = "main", -- TODO: remove this once main is released
		dependencies = "nvim-treesitter/nvim-treesitter",
		---@module "nvim-treesitter-textobjects"
		-- TODO: define objects
	},
	{
		"nvim-treesitter/nvim-treesitter-context",
		dependencies = "nvim-treesitter/nvim-treesitter",
		event = { "BufReadPost", "BufNewFile" },
		keys = {
			{
				"[c",
				function()
					require("treesitter-context").go_to_context(vim.v.count1)
				end,
				desc = "Start of [c]ontext",
			},
		},
		opts = { max_lines = "20%", multiwindow = true, min_window_height = 30 },
		config = function(_, opts)
			require("treesitter-context").setup(opts)
			vim.cmd([[highlight TreesitterContextBottom gui=underdashed guisp=Grey]])
			vim.cmd([[highlight TreesitterContextLineNumberBottom gui=NONE]])
		end,
	},
}
