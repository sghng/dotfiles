---@type {[string]: string[]}
local formatters_by_ft = {
	fish = { "fish_indent" },
	lua = { "stylua" },
	markdown = { "markdownlint-cli2", "prettierd" },
	python = { "ruff_organize_imports", "ruff_format" }, -- don't remove imports
	quarto = { "injected", "prettierd" },
	r = { "air" },
	toml = { "taplo" },
	["_"] = { "trim_whitespace", "trim_newlines" },
}

for _, ft in ipairs({ "sh", "zsh" }) do
	formatters_by_ft[ft] = { "shfmt" }
end

for _, ft in ipairs({
	"css",
	"json",
	"javascript",
	"typescript",
	"vue",
	"yaml",
}) do
	formatters_by_ft[ft] = { "prettierd" }
end

---@type LazySpec
return {
	"stevearc/conform.nvim",
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
		},
	},
}
