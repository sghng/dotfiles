local linters_by_ft = {
	bash = { "bash" },
	fish = { "fish" },
	markdown = { "markdownlint-cli2", "cspell" },
	quarto = { "markdownlint-cli2", "cspell" },
	text = { "vale" },
	vim = { "vint" },
	["*"] = { "cspell" },
}
-- eslint only
for _, ft in ipairs({ "css", "json" }) do
	linters_by_ft[ft] = { "eslint_d" }
end
-- both eslint and oxlint
-- TODO: if eslint config is not present, enable oxlint only
for _, ft in ipairs({ "javascript", "typescript", "vue" }) do
	linters_by_ft[ft] = { "eslint_d", "oxlint" }
end

---@type LazySpec
return {
	{
		"mfussenegger/nvim-lint",
		dependencies = "WhoIsSethDaniel/mason-tool-installer.nvim",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			local lint = require("lint")
			-- certain linters are activated along with language server
			lint.linters_by_ft = linters_by_ft
			--- calling the linters with debouncing, inspired by LazyVim
			local timer = vim.uv.new_timer()
			vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged", "BufWritePost", "BufReadPost" }, {
				group = vim.api.nvim_create_augroup("Linting", { clear = true }),
				callback = function()
					timer:stop()
					timer:start(500, 0, function()
						timer:stop()
						vim.schedule(lint.try_lint)
					end)
				end,
			})
			vim.diagnostic.config({ virtual_text = true })
		end,
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		lazy = true,
		opts_extend = { "ensure_installed" },
		opts = {
			ensure_installed = {
				"checkmake", -- Makefile
				"cspell",
				"eslint_d",
				"markdownlint-cli2",
				"stylua",
				"vint", -- Vim script
			},
			auto_update = true,
		},
	},
}
