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
		ft = { "markdown", "codecompanion"},
		---@module "render-markdown"
		---@type render.md.Config
		---@diagnostic disable: missing-fields
		opts = {
			render_modes = true,
			file_types = { "markdown", "Avante", "AvanteInput" },
			completions = { lsp = { enabled = true } },
			win_options = { conceallevel = { rendered = 2 } },
			-- handover math rendering to nabla
			latex = { enabled = false },
			on = {
				attach = function()
					-- must be called after render-markdown is attached
					require("nabla").enable_virt({ autogen = true })
				end,
			},
		},
		---@diagnostic enable: missing-fields
		--TODO: blink.cmp integration
	},
	{ "ellisonleao/glow.nvim", cmd = "Glow", opts = {} },
	{
		"iamcco/markdown-preview.nvim",
		build = function()
			vim.fn["mkdp#util#install"]() -- more robust than yarn install
		end,
		ft = "markdown", -- cannot load lazier since the commands are not global
		keys = {
			{
				"<C-s>",
				"<Plug>MarkdownPreview",
				desc = "[s]tart Markdown preview",
			},
			{
				"<M-s>",
				"<Plug>MarkdownPreviewStop",
				desc = "[s]top Markdown preview",
			},
			{
				"<C-p>",
				"<Plug>MarkdownPreviewToggle",
				desc = "Toggle Markdown [p]review",
			},
		},
	},
	-- { "Thiago4532/mdmath.nvim", build = "brew install librsvg" },
	{
		"jbyuki/nabla.nvim",
		dependencies = "nvim-treesitter/nvim-treesitter",
		build = function()
			---@diagnostic disable-next-line: missing-fields
			require("nvim-treesitter.configs").setup({
				ensure_installed = "latex",
			})
		end,
		keys = {
			{
				"<Leader>m",
				function()
					require("nabla").popup()
				end,
				desc = "Show Nabla [m]ath preview popup",
			},
		},
		cmd = "NablaToggleVirt",
		init = function()
			vim.api.nvim_create_user_command("NablaToggleVirt", function()
				local nabla = require("nabla")
				nabla.toggle_virt()
				print("Nabla " .. (nabla.is_virt_enabled() and "enabled" or "disabled"))
			end, { nargs = 0 })
		end,
	},
	{
		-- mermaid rendering
		"3rd/diagram.nvim",
		build = "bun install -g @mermaid-js/mermaid-cli",
		dependencies = "3rd/image.nvim",
		ft = "markdown",
		cond = false, -- FIXME: currently not working due to a bug
		config = function()
			require("diagram").setup({
				integrations = { require("diagram.integrations.markdown") },
				renderer_options = {},
			})
		end,
	},
	{
		-- this plugin is oriented for Zettelkasten/all-in-one method
		"epwalsh/obsidian.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
			"nvim-telescope/telescope.nvim",
		},
		cmd = {
			"ObsidianCheck",
			"ObsidianDebug",
			"ObsidianNew",
			"ObsidianNewFromTemplate",
			"ObsidianQuickSwitch",
		},
		keys = { {
			"<Leader>oo",
			"<Cmd>ObsidianOpen<CR>",
			desc = "[o]pen note in [o]bsidian",
		} },
		event = { "BufReadPost " .. OBSIDIAN_VAULT .. "/*.md" },
		---@module "obsidian"
		---@type obsidian.config.ClientOpts
		---@diagnostic disable: missing-fields
		opts = {
			ui = { enable = false }, -- use render-markdown instead
			workspaces = { { name = "TECH", path = OBSIDIAN_VAULT } },
			disable_frontmatter = true,
			open_app_foreground = true,
			picker = { "telescope.nvim" },
			mappings = {}, -- disable default mappings
		},
		---@diagnostic enable: missing-fields
	},
	{
		-- TODO: understand the keymaps
		-- TODO: integrate with Blink
		"jakewvincent/mkdnflow.nvim",
		ft = "markdown",
	},
}
