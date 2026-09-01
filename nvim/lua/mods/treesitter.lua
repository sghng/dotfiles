---@type LazySpec
return {
	{
		"nvim-treesitter/nvim-treesitter",
		lazy = false, -- does not support lazy-loading
		build = ":TSUpdate",
		config = function()
			local function enable()
				vim.treesitter.start()
				local wo = vim.wo[0][0]
				wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
				wo.foldmethod = "expr"
				wo.foldlevel = 99 -- open all folds by default
				vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
			end
			vim.api.nvim_create_autocmd("FileType", {
				callback = function(args)
					local lang = vim.treesitter.language.get_lang(args.match)
					if not lang or not require("nvim-treesitter.parsers")[lang] then
						return
					end
					if vim.list_contains(require("nvim-treesitter.config").get_installed(), lang) then
						enable()
						return
					end
					require("nvim-treesitter").install({ lang }):await(vim.schedule_wrap(function()
						vim.api.nvim_buf_call(args.buf, enable)
					end))
				end,
			})
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
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
