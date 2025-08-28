local OBSIDIAN_VAULT = vim.fn.resolve(vim.fn.expand("~/obsidian"))

---@type LazySpec
return {
	{
		"MeanderingProgrammer/render-markdown.nvim",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
			"nvim-treesitter/nvim-treesitter",
			"jbyuki/nabla.nvim",
		},
		cmd = "RenderMarkdown",
		keys = {
			{
				"<LocalLeader>r",
				"<Cmd>RenderMarkdown toggle<CR>",
				desc = "[r]ender Markdown",
				ft = "markdown",
			},
		},
		ft = { "markdown", "codecompanion" },
		---@module "render-markdown"
		---@type render.md.Config
		---@diagnostic disable: missing-fields
		opts = {
			file_types = { "markdown", "codecompanion" },
			completions = { blink = { enabled = true } },
			win_options = { conceallevel = { rendered = 2 } },
			-- handover math rendering to nabla
			-- TODO: nabla inline rendering doesn't look well, report
			-- latex = { enabled = false },
			on = {
				attach = function()
					-- must be called after render-markdown is attached
					-- require("nabla").enable_virt({ autogen = true })
				end,
			},
			-- code border doesn't work with transparent background
			code = { highlight_border = false },
			inline_highlight = { highlight = "Cursor" }, -- HL Group required
		},
		---@diagnostic enable: missing-fields
	},
	{
		"ellisonleao/glow.nvim",
		cmd = "Glow",
		keys = { {
			"<LocalLeader>g",
			"<Cmd>Glow<CR>",
			desc = "[G]low preview",
			ft = "markdown",
		} },
		opts = {},
	},
	{
		"iamcco/markdown-preview.nvim",
		build = function()
			vim.fn["mkdp#util#install"]() -- more robust than yarn install
		end,
		ft = "markdown", -- cannot load lazier since the commands are not global
		keys = {
			{
				"<LocalLeader>p",
				"<Plug>MarkdownPreview",
				desc = "Toggle Markdown [p]review",
			},
		},
	},
	{
		"jbyuki/nabla.nvim",
		dependencies = "nvim-treesitter/nvim-treesitter",
		build = function()
			---@diagnostic disable-next-line: missing-fields
			require("nvim-treesitter.configs").setup({ ensure_installed = "latex" })
		end,
		keys = {
			{
				"<LocalLeader>m",
				function()
					require("nabla").popup({ border = "rounded" })
				end,
				desc = "Show Nabla [m]ath preview popup",
				ft = "markdown",
			},
		},
	},
	{
		-- mermaid rendering
		"3rd/diagram.nvim",
		build = "brew install mermaid-cli",
		cond = not vim.g.neovide, -- image not supported in Neovide
		dependencies = "3rd/image.nvim",
		ft = "markdown",
		keys = {
			{
				"<Localleader>d",
				function()
					require("diagram").show_diagram_hover()
				end,
				mode = "n",
				ft = { "markdown", "codecompanion" },
				desc = "Show [d]iagram",
			},
		},
		config = function()
			require("diagram").setup({
				integrations = { require("diagram.integrations.markdown") },
				-- NOTE: setting this ensures that diagram doesn't persist across
				-- tmux windows, but it has unintended side effects.
				-- events = { clear_buffer = { "FocusLost" } },
				events = { render_buffer = {} }, -- effectively disables rendering
				renderer_options = {
					mermaid = {
						theme = "dark",
						background = "transparent",
						scale = 3,
					},
				},
			})
		end,
	},
	{
		-- this plugin is oriented for Zettelkasten/all-in-one method
		"obsidian-nvim/obsidian.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
			"nvim-telescope/telescope.nvim",
		},
		cmd = "Obsidian",
		keys = {
			{
				"<LocalLeader>oo",
				"<Cmd>Obsidian open<CR>",
				ft = "markdown",
				desc = "[o]pen note in [o]bsidian",
			},
			-- smart_action bound to <CR> by default
		},
		event = { "BufReadPost " .. OBSIDIAN_VAULT .. "/*.md" },
		---@module "obsidian"
		---@type obsidian.config.ClientOpts
		---@diagnostic disable: missing-fields
		opts = {
			ui = { enable = false }, -- use render-markdown instead
			workspaces = { { name = "TECH", path = OBSIDIAN_VAULT } },
			-- FIXME: completion not working
			completion = { blink = true },
			disable_frontmatter = true, -- do not mess with front matter
			picker = { name = "telescope.nvim" },
			open = {
				func = function(uri)
					vim.ui.open(uri, { cmd = { "open", "-a", "/Applications/Obsidian.app" } })
				end,
			},
		},
		---@diagnostic enable: missing-fields
	},
}
