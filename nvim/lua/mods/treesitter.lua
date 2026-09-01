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
		opts = {
			select = {
				lookahead = true, -- jump forward to textobj like targets.vim
				selection_modes = {
					["@parameter.outer"] = "v", -- charwise
					["@function.outer"] = "V", -- linewise
				},
			},
			move = { set_jumps = true }, -- record jumps in the jumplist
		},
		keys = (function()
			local select_defs = {
				-- key, capture, query group, description
				{ "am", "@function.outer", "textobjects", "[a]round [m]ethod/function" },
				{ "im", "@function.inner", "textobjects", "[i]nner [m]ethod/function" },
				{ "ac", "@class.outer", "textobjects", "[a]round [c]lass" },
				{ "ic", "@class.inner", "textobjects", "[i]nner [c]lass" },
				{ "a,", "@parameter.outer", "textobjects", "around parameter" },
				{ "i,", "@parameter.inner", "textobjects", "inner parameter" },
				{ "aC", "@call.outer", "textobjects", "around [C]all" },
				{ "iC", "@call.inner", "textobjects", "inner [C]all" },
			}
			local move_defs = {
				-- key, direction, capture(s), query group, description
				{
					"]m",
					"goto_next_start",
					"@function.outer",
					"textobjects",
					"next [m]ethod/function start",
				},
				{
					"[m",
					"goto_previous_start",
					"@function.outer",
					"textobjects",
					"previous [m]ethod/function start",
				},
				{
					"]M",
					"goto_next_end",
					"@function.outer",
					"textobjects",
					"next [m]ethod/function end",
				},
				{
					"[M",
					"goto_previous_end",
					"@function.outer",
					"textobjects",
					"previous [m]ethod/function end",
				},
				{
					"]]",
					"goto_next_start",
					"@class.outer",
					"textobjects",
					"next class start",
				},
				{
					"[[",
					"goto_previous_start",
					"@class.outer",
					"textobjects",
					"previous class start",
				},
				{
					"][",
					"goto_next_end",
					"@class.outer",
					"textobjects",
					"next class end",
				},
				{
					"[]",
					"goto_previous_end",
					"@class.outer",
					"textobjects",
					"previous class end",
				},
				{
					"]o",
					"goto_next_start",
					{ "@loop.inner", "@loop.outer" },
					"textobjects",
					"next l[o]op",
				},
				{
					"[o",
					"goto_previous_start",
					{ "@loop.inner", "@loop.outer" },
					"textobjects",
					"previous l[o]op",
				},
				{
					"],",
					"goto_next_start",
					"@parameter.inner",
					"textobjects",
					"next parameter",
				},
				{
					"[,",
					"goto_previous_start",
					"@parameter.inner",
					"textobjects",
					"previous parameter",
				},
			}
			---@type LazyKeysSpec[]
			local keys = {
				-- swap: exchange node under cursor with neighbor
				{
					"<Leader>a",
					function()
						require("nvim-treesitter-textobjects.swap").swap_next("@parameter.inner")
					end,
					desc = "swap with next parameter",
				},
				{
					"<Leader>A",
					function()
						require("nvim-treesitter-textobjects.swap").swap_previous("@parameter.outer")
					end,
					desc = "swap with previous parameter",
				},
				-- repeatable moves: ; and , repeat the last motion
				{
					";",
					function()
						require("nvim-treesitter-textobjects.repeatable_move").repeat_last_move_next()
					end,
					mode = { "n", "x", "o" },
					desc = "repeat last move forward",
				},
				{
					",",
					function()
						require("nvim-treesitter-textobjects.repeatable_move").repeat_last_move_previous()
					end,
					mode = { "n", "x", "o" },
					desc = "repeat last move backward",
				},
			}
			-- make builtin f/F/t/T also repeatable with ; and ,
			for _, lhs in ipairs({ "f", "F", "t", "T" }) do
				table.insert(keys, {
					lhs,
					function()
						return require("nvim-treesitter-textobjects.repeatable_move")["builtin_" .. lhs .. "_expr"]()
					end,
					mode = { "n", "x", "o" },
					expr = true,
				})
			end
			-- select: like ip/ap but syntax-aware
			for _, def in ipairs(select_defs) do
				table.insert(keys, {
					def[1],
					function()
						require("nvim-treesitter-textobjects.select").select_textobject(def[2], def[3])
					end,
					mode = { "x", "o" },
					desc = def[4],
				})
			end
			-- move: upgraded [m ]m that works via syntax tree in any language
			for _, def in ipairs(move_defs) do
				table.insert(keys, {
					def[1],
					function()
						require("nvim-treesitter-textobjects.move")[def[2]](def[3], def[4])
					end,
					mode = { "n", "x", "o" },
					desc = def[5],
				})
			end
			return keys
		end)(),
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
