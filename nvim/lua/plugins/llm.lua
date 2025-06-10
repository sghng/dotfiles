---@type LazySpec
return {
	{
		"olimorris/codecompanion.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
			-- "MeanderingProgrammer/render-markdown.nvim", -- delayed
		},
		cmd = {
			"CodeCompanion",
			"CodeCompanionActions",
			"CodeCompanionChat",
			"CodeCompanionCmd",
		},
		keys = {
			{ "<C-a>", "<Cmd>CodeCompanionActions<CR>", mode = { "n", "v" } },
			{
				"<Leader>a",
				"<Cmd>CodeCompanionChat Toggle<CR>",
				mode = { "n", "v" },
			},
			-- conflicts with mini.align
			-- { "ga", "<Cmd>CodeCompanionChat Add<CR>", mode = "v", noremap = true },
		},
		init = function()
			vim.cmd.cab("cc", "CodeCompanion")
		end,
		opts = {
			---@module "codecompanion"
			---@type CodeCompanion.Strategies
			---@diagnostic disable-next-line: missing-fields
			strategies = {
				chat = { adapter = "anthropic" },
				inline = { adapter = "anthropic" },
			},
			adapters = {
				anthropic = function()
					return require("codecompanion.adapters").extend("anthropic", {
						env = {
							api_key = "cmd:op read op://dev/anthropic/adapta --no-newline",
						},
						schema = { thinking = nil },
					})
				end,
			},
		},
	},
	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		event = "InsertEnter",
		opts = {}, -- required
	},
}
