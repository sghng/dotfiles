local PRETTIER = "prettierd" -- prettier or prettierd

---@type {[string]: string[]}
local formatters_by_ft = {
	fish = { "fish_indent" },
	lua = { "stylua" },
	markdown = { "markdownlint-cli2", PRETTIER },
	python = { "ruff_organize_imports", "ruff_format" }, -- don't remove imports
	quarto = { "injected", PRETTIER },
	r = { "air" },
	toml = { "taplo" },
	["_"] = { "trim_whitespace", "trim_newlines" },
}

for _, ft in ipairs({ "sh", "zsh" }) do
	formatters_by_ft[ft] = { "shfmt" }
end

for _, ft in ipairs({ "tex", "sty", "bib" }) do
	formatters_by_ft[ft] = { "tex-fmt" }
end

for _, ft in ipairs({
	"css",
	"json",
	"javascript",
	"typescript",
	"svg",
	"vue",
	"yaml",
}) do
	formatters_by_ft[ft] = { PRETTIER }
end

---@type LazySpec
return {
	{
		"stevearc/conform.nvim",
		dependencies = "WhoIsSethDaniel/mason-tool-installer.nvim",
		cmd = "ConformInfo",
		event = "BufWritePre", -- in case format on save
		keys = {
			{
				"<Leader>cf", -- avoid prefix conflict with Telescope
				function()
					require("conform").format()
				end,
				desc = "[c]ode [f]ormat (Conform)",
			},
		},
		---@module "conform"
		---@type conform.setupOpts
		opts = {
			formatters_by_ft = formatters_by_ft,
			default_format_opts = { async = true, lsp_format = "fallback" },
			format_on_save = { async = false, lsp_format = "fallback" },
			formatters = {
				prettierd = {
					env = {
						PRETTIERD_DEFAULT_CONFIG = vim.fn.expand("$DOTS/.prettierrc.yaml"),
					},
				},
				prettier = {
					-- Manually search for config files, if not present,
					-- fallback to global default.
					prepend_args = function(_, ctx)
						local error = vim.system({
							"prettier",
							"--find-config-path",
							ctx.filename,
						}, { text = true })
							:wait().stderr
						if error == "" then
							return {}
						else
							return {
								"--config",
								vim.fn.expand("$DOTS/.prettierrc.yaml"),
							}
						end
					end,
				},
			},
		},
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		lazy = true,
		opts_extend = { "ensure_installed" },
		opts = {
			ensure_installed = {
				"prettier",
				"prettierd",
				"shfmt",
				"stylua",
				"tex-fmt", -- LaTeX
				"typstyle", -- Typst
			},
			auto_update = true,
		},
	},
}
