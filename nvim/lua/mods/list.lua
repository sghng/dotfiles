-- Quickfix List, Location List, and other lists equivalents

wk_add({ "<Leader>l", group = "[l]ist" })

-- TODO: more bindings as we use it more
local key_defs = {
	{ "d", "lsp_definitions toggle", "[d]efinitions" },
	{ "s", "lsp_document_symbols toggle focus=false", "[s]ymbols" },
	{ "x", "diagnostics toggle filter.buf=0'", "diagnostics (buffer)" },
	{ "X", "diagnostics toggle", "diagnostics (global)" },
}
---@type LazySpec[]
local keys = {}
for _, def in ipairs(key_defs) do
	table.insert(keys, {
		"<Leader>l" .. def[1],
		"<Cmd>Trouble " .. def[2] .. "<CR>",
		desc = "[l]ist " .. def[3] .. " (Trouble)",
	})
end

--- @type LazySpec
return {
	{ "folke/trouble.nvim", cmd = "Trouble", keys = keys, opts = {} },
	{ "stevearc/quicker.nvim", ft = { "lf", "qf" } },
	{ "kevinhwang91/nvim-bqf", ft = { "lf", "qf" } },
	{
		-- TODO: need to figure this out
		"LintaoAmons/bookmarks.nvim",
		dependencies = {
			"kkharji/sqlite.lua",
			"nvim-telescope/telescope.nvim",
			"stevearc/dressing.nvim", -- optional: better UI
		},
		event = { "BufReadPost", "BufNewFile" }, -- needed for bookmarks rendering
		cmd = {
			"BookmarksCommands",
			"BookmarksGrep",
			"BookmarksInfo",
			"BookmarksLists",
			"BookmarksNewLists",
			"BookmarksQuery",
		},
		config = function()
			require("bookmarks").setup() -- required for DB initailization
		end,
	},
	{
		"folke/todo-comments.nvim",
		dependencies = "nvim-lua/plenary.nvim",
		event = { "BufReadPost", "BufNewFile" },
		cmd = {
			"TodoTelescope",
			"TodoLocList",
			"TodoTrouble",
			"TodoQuickFix",
		},
		keys = {
			{
				"<Leader>ft",
				"<Cmd>TodoTelescope<CR>",
				desc = "[f]ind [t]odos in Telescope",
			},
			{
				"<Leader>lt",
				"<Cmd>TodoLocList<CR>",
				desc = "[l]ist [t]odos",
			},
			-- overrides tag navigation, which is obsolete now
			{
				"]t",
				function()
					require("todo-comments").jump_next()
				end,
				desc = "next [t]odo comment",
			},
			{
				"[t",
				function()
					require("todo-comments").jump_prev()
				end,
				desc = "next [t]odo comment",
			},
		},
		opts = {}, -- required
	},
}
