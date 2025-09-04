---@type LazySpec
return {
	{
		"nvim-treesitter/nvim-treesitter",
		build = { "brew install tree-sitter tree-sitter-cli", ":TSUpdate" },
		event = { "BufReadPost", "BufNewFile" },
		---@type TSConfig
		---@diagnostic disable-next-line: missing-fields
		opts = {
			auto_install = true,
			highlight = {
				enable = true,
				disable = { "csv", "tsv" }, -- builtin highlighting is better
			},
			indent = { enable = true },
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "gnn",
					node_incremental = "grn",
					scope_incremental = "grc",
					node_decremental = "grm",
				},
			},
			-- embedded languages may not be recognized from filetypes
			ensure_installed = { "javascript", "latex", "regex", "typescript" },
		},
		-- manual setup required
		config = function(_, opts)
			require("nvim-treesitter.configs").setup(opts)
		end,
	},
	{
		-- prefer vim.lsp for such features
		"nvim-treesitter/nvim-treesitter-refactor",
		dependencies = "nvim-treesitter/nvim-treesitter",
		event = { "BufReadPost", "BufNewFile" }, -- for definition highlights
		config = function()
			---@diagnostic disable-next-line: missing-fields
			require("nvim-treesitter.configs").setup({
				refactor = {
					highlight_definitions = { enable = true },
					highligh_current_scope = { enable = true },
				},
			})
			vim.opt.updatetime = 500
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		dependencies = "nvim-treesitter/nvim-treesitter",
		keys = function()
			local t = {}
			for _, k in ipairs({ "af", "if", "ac", "ic", "as" }) do
				table.insert(t, { k, mode = "v" })
			end
			return t
		end,
		---@module "nvim-treesitter-textobjects"
		opts = {
			textobjects = {
				select = {
					enable = true,
					lookahead = true,
					keymaps = {
						["af"] = {
							query = "@function.outer",
							desc = "Select [a] [f]unction",
						},
						["if"] = {
							query = "@function.inner",
							desc = "Select [i]nner of a [f]unction",
						},
						["ac"] = {
							query = "@class.outer",
							desc = "Select [a] [c]lass",
						},
						["ic"] = {
							query = "@class.inner",
							desc = "Select [i]nner of a [c]lass",
						},
						["as"] = {
							query = "@local.scope",
							desc = "Select [a] [s]cope",
						},
					},
					include_surrounding_whitespace = true,
				},
			},
		},
		config = function(_, opts)
			require("nvim-treesitter.configs").setup(opts)
		end,
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
		opts = { multiwindow = true, min_window_height = 30 },
		config = function(_, opts)
			require("treesitter-context").setup(opts)
			vim.cmd([[highlight TreesitterContextBottom gui=underdashed guisp=Grey]])
			vim.cmd([[highlight TreesitterContextLineNumberBottom gui=NONE]])
		end,
	},
}
