-- Markdown-ish file types
local MD_FT = { "markdown", "quarto", "codecompanion" }

local OBSIDIAN_VAULT = vim.fn.resolve(vim.fn.expand("~/obsidian"))
local obsidian_key_defs = {
	-- key suffix, Obsidian sub command, description
	{ "b", "backlinks", "[b]acklinks" },
	{ "d", "dailies", "[d]ailies" },
	{ "j", "today", "[j]in tian (today)" },
	{ "l", "links", "[l]inks" },
	{ "m", "tomorrow", "[m]ing tian (tomorrow)" },
	{ "r", "rename", "[r]ename" },
	{ "t", "tags", "[t]ags" },
	{ "o", "open", "[o]pen" },
	{ "w", "workspace", "[w]orkspace" },
	{ "z", "yesterday", "[z]uo tian (yesterday)" },
}
---@type LazyKeysSpec[]
local obsidian_keys = {}
for _, def in ipairs(obsidian_key_defs) do
	table.insert(obsidian_keys, {
		"<Localleader>o" .. def[1],
		"<Cmd>Obsidian " .. def[2] .. "<CR>",
		desc = "[o]bsidian " .. def[3],
		ft = "markdown",
	})
end

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
				ft = MD_FT,
			},
		},
		ft = MD_FT,
		---@module "render-markdown"
		---@type render.md.Config
		---@diagnostic disable: missing-fields
		opts = {
			file_types = MD_FT,
			win_options = { conceallevel = { rendered = 2 } },
			-- handover math rendering to nabla
			-- latex = { enabled = false },
			-- TODO: nabla inline rendering doesn't look well, report
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
			ft = MD_FT,
		} },
		opts = {},
	},
	{
		"iamcco/markdown-preview.nvim",
		build = function()
			vim.fn["mkdp#util#install"]() -- more robust than yarn install
		end,
		ft = MD_FT,
		keys = {
			{
				"<LocalLeader>p",
				"<Plug>MarkdownPreview",
				desc = "Toggle Markdown [p]review",
				ft = MD_FT,
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
				ft = MD_FT,
			},
		},
	},
	{
		-- mermaid rendering
		"3rd/diagram.nvim",
		build = "brew install mermaid-cli",
		cond = not vim.g.neovide, -- image not supported in Neovide
		dependencies = "3rd/image.nvim",
		ft = MD_FT,
		keys = {
			{
				"<Localleader>d",
				function()
					require("diagram").show_diagram_hover()
				end,
				mode = "n",
				ft = MD_FT,
				desc = "Show [d]iagram",
			},
		},
		config = function()
			require("diagram").setup({
				integrations = { require("diagram.integrations.markdown") },
				-- NOTE: setting this ensures that diagram doesn't persist across
				-- tmux windows, but it has unintended side effects.
				-- events = { clear_buffer = { "FocusLost" } },

				-- NOTE: this effectively disables rendering
				events = { render_buffer = {} },
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
		"obsidian-nvim/obsidian.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
			"nvim-telescope/telescope.nvim",
		},
		cmd = "Obsidian",
		keys = obsidian_keys, -- smart_action bound to <CR> by default
		event = { "BufReadPost " .. OBSIDIAN_VAULT .. "/**.md" },
		---@module "obsidian"
		---@type obsidian.config.ClientOpts
		---@diagnostic disable: missing-fields
		opts = {
			ui = { enable = false }, -- use render-markdown instead
			workspaces = { { name = "TECH", path = OBSIDIAN_VAULT } },
			completion = { blink = true, min_chars = 0, create_new = false },
			disable_frontmatter = true, -- do not mess with front matter
			-- TODO: suppresses deprecation warning, should be removed in v4.0
			legacy_commands = false,
			note_id_func = function(title)
				return title
			end,
		},
		config = function(_, opts)
			require("obsidian").setup(opts)
			-- remove default binding
			vim.api.nvim_create_autocmd("User", {
				pattern = "ObsidianNoteEnter",
				callback = function(ev)
					vim.keymap.del("n", "<CR>", { buffer = ev.buf })
				end,
			})
		end,
	},
}
