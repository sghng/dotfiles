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
			highlight = { enable = true },
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
		"nvim-treesitter/nvim-treesitter-refactor",
		dependencies = "nvim-treesitter/nvim-treesitter",
		event = { "BufReadPost", "BufNewFile" }, -- for definition highlights
		config = function()
			---@diagnostic disable-next-line: missing-fields
			require("nvim-treesitter.configs").setup({
				-- NOTE: most refactoring features should be supported by LSP
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
							desc = "Select inner of a [f]unction",
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
		-- TODO: use [c to jump to beginning of context, currently it's used by
		-- git gutter to navigate between hunks
		-- TODO: adjust highlihgt of context, so that it looks different from
		-- selection
		"nvim-treesitter/nvim-treesitter-context",
		dependencies = "nvim-treesitter/nvim-treesitter",
		event = { "BufReadPost", "BufNewFile" },
		opts = { multiwindow = true, min_window_height = 30 },
		config = function(_, opts)
			require("nvim-treesitter.configs").setup(opts)
		end,
	},
}
