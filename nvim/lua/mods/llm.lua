--- LLM related utilities
--- @type LazySpec
return {
	{
		"olimorris/codecompanion.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
		},
		cmd = {
			"CodeCompanion",
			"CodeCompanionActions",
			"CodeCompanionChat",
			"CodeCompanionCmd",
		},
		keys = {
			{
				"<Leader>aa",
				"<Cmd>CodeCompanionActions<CR>",
				mode = { "n", "v" },
			},
			{
				"<Leader>ac",
				"<Cmd>CodeCompanionChat Toggle<CR>",
				mode = { "n", "v" },
			},
			-- conflicts with mini.align
			-- { "ga", "<Cmd>CodeCompanionChat Add<CR>", mode = "v", noremap = true },
		},
		init = function()
			vim.cmd.cab("cc", "CodeCompanion")
			-- HACK: work around for colorcolumn
			vim.api.nvim_create_autocmd("User", {
				pattern = "CodeCompanionChatOpened",
				callback = function()
					vim.opt_local.colorcolumn = ""
				end,
			})
		end,
		opts = {
			---@module "codecompanion"
			---@type CodeCompanion.Strategies
			---@diagnostic disable-next-line: missing-fields
			strategies = {
				chat = { adapter = "anthropic", model = "claude-sonnet-4-0" },
				inline = { adapter = "anthropic", model = "claude-sonnet-4-0" },
			},
			adapters = {
				http = {
					anthropic = function()
						return require("codecompanion.adapters").extend("anthropic", {
							env = {
								api_key = "cmd:op read op://dev/anthropic-adapta/credential",
							},
						})
					end,
				},
			},
		},
	},
	{
		"nickjvandyke/opencode.nvim",
		dependencies = {
			---@module "snacks"
			"folke/snacks.nvim",
			optional = true,
			opts = {
				input = {}, -- enhances ask()
				picker = { -- enhances select()
					actions = {
						opencode_send = function(...)
							return require("opencode").snacks_picker_send(...)
						end,
					},
					win = {
						input = { keys = {
							["<A-a>"] = { "opencode_send", mode = { "n", "i" } },
						} },
					},
				},
			},
		},
		config = function()
			---@type opencode.Opts
			vim.g.opencode_opts = {}

			vim.o.autoread = true -- required for opts.events.reload
			local opencode = require("opencode")

			vim.keymap.set({ "n", "x" }, "<C-a>", function()
				opencode.ask("@this: ", { submit = true })
			end, { desc = "Ask opencode…" })
			vim.keymap.set({ "n", "x" }, "<C-x>", function()
				opencode.select()
			end, { desc = "Execute opencode action…" })
			vim.keymap.set({ "n", "t" }, "<C-.>", function()
				opencode.toggle()
			end, { desc = "Toggle opencode" })

			vim.keymap.set({ "n", "x" }, "go", function()
				return opencode.operator("@this ")
			end, { desc = "Add range to opencode", expr = true })
			vim.keymap.set("n", "goo", function()
				return opencode.operator("@this ") .. "_"
			end, { desc = "Add line to opencode", expr = true })

			vim.keymap.set("n", "<S-C-u>", function()
				opencode.command("session.half.page.up")
			end, { desc = "Scroll opencode up" })
			vim.keymap.set("n", "<S-C-d>", function()
				opencode.command("session.half.page.down")
			end, { desc = "Scroll opencode down" })

			-- You may want these if you use the opinionated `<C-a>` and `<C-x>` keymaps above — otherwise consider `<leader>o…` (and remove terminal mode from the `toggle` keymap)
			vim.keymap.set("n", "+", "<C-a>", { desc = "Increment under cursor", noremap = true })
			vim.keymap.set("n", "-", "<C-x>", { desc = "Decrement under cursor", noremap = true })
		end,
	},
	{
		"zbirenbaum/copilot.lua",
		dependencies = "copilotlsp-nvim/copilot-lsp",
		cmd = "Copilot",
		event = "TextChanged",
		---@module "copilot"
		---@type CopilotConfig
		---@diagnostic disable: missing-fields
		opts = {
			nes = {
				enabled = true,
				keymap = {
					accept_and_goto = "<Leader>p",
					accept = false,
					dismiss = "<Esc>",
				},
			},
		},
		---@diagnostic enable: missing-fields
		config = function(_, opts)
			require("copilot").setup(opts)
		end,
	},
	{
		"fang2hou/blink-copilot",
		dependencies = {
			"zbirenbaum/copilot.lua",
			{
				"saghen/blink.cmp",
				---@module "blink-cmp"
				---@type blink.cmp.Config
				opts = {
					sources = {
						default = { "copilot" },
						providers = {
							copilot = {
								name = "copilot",
								module = "blink-copilot",
								async = true,
							},
						},
					},
				},
				opts_extend = { "sources.default" },
			},
		},
		event = "InsertEnter",
	},
}
