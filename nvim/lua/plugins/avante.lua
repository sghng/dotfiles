---@type LazySpec
return {
	{
		"yetone/avante.nvim",
		build = "make",
		event = "VeryLazy",
		---@module "avante"
		---@type avante.Config
		---@diagnostic disable-next-line: missing-fields
		opts = {
			-- provider = "dashscope",
			provider = "claude",
			providers = {
				["dashscope"] = {
					__inherited_from = "openai",
					api_key_name = "DASHSCOPE_API_KEY",
					endpoint = "https://dashscope.aliyuncs.com/compatible-mode/v1/",
					model = "deepseek-v3",
				},
				claude = { model = "claude-sonnet-4-20250514" },
			},
			auto_suggestions_provider = "dashscope",
			behaviour = { auto_suggestions = true },
		},
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"stevearc/dressing.nvim",
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			--- optional dependencies
			"nvim-telescope/telescope.nvim", -- for file_selector provider telescope
			"ibhagwan/fzf-lua", -- for file_selector provider fzf
			"nvim-tree/nvim-web-devicons",
			"zbirenbaum/copilot.lua", -- for providers='copilot'
			{
				-- support for image pasting
				"HakonHarnes/img-clip.nvim",
				event = "VeryLazy",
				opts = {
					-- recommended settings
					default = {
						embed_image_as_base64 = false,
						prompt_for_file_name = false,
						drag_and_drop = { insert_mode = true },
					},
				},
			},
			-- "MeanderingProgrammer/render-markdown.nvim", -- lazy load
		},
	},
	{
		"Kaiser-Yang/blink-cmp-avante",
		dependencies = {
			"saghen/blink.cmp",
			---@module "blink-cmp"
			---@type blink.cmp.Config
			opts = {
				sources = {
					default = { "avante" },
					providers = {
						avante = {
							module = "blink-cmp-avante",
							name = "Avante",
						},
					},
				},
			},
			opts_extend = { "sources.default" },
		},
		event = "InsertEnter",
	},
}
