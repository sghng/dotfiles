local linters_by_ft = {
	dockerfile = { "hadolint" },
	haskell = { "hlint" },
	lua = { "selene" },
	make = { "checkmake" },
	markdown = { "markdownlint-cli2", "cspell" },
	quarto = { "markdownlint-cli2", "cspell" },
	text = { "vale" },
	vim = { "vint" },
	["*"] = { "cspell" },
}

local linters = vim.iter(vim.tbl_values(linters_by_ft)):flatten():totable()

-- linters as language server
for _, linter in ipairs({ "biome", "rubocop" }) do
	table.insert(linters, linter)
end

-- not in Mason registry
for _, ft in ipairs({ "bash", "fish" }) do
	linters_by_ft[ft] = { ft }
end

---@type LazySpec
return {
	{
		"mfussenegger/nvim-lint",
		dependencies = "WhoIsSethDaniel/mason-tool-installer.nvim",
		event = { "BufReadPost", "BufNewFile" },
		init = function()
			vim.diagnostic.config({ virtual_text = true })
		end,
		config = function()
			local lint = require("lint")
			-- certain linters are activated along with language server
			lint.linters_by_ft = linters_by_ft
			--- calling the linters with debouncing, inspired by LazyVim
			local timer = assert(vim.uv.new_timer())
			vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged", "BufWritePost", "BufReadPost" }, {
				group = vim.api.nvim_create_augroup("Linting", { clear = true }),
				callback = function()
					timer:stop()
					timer:start(500, 0, function()
						timer:stop()
						vim.schedule(function()
							lint.try_lint(nil, { cwd = root() })
						end)
					end)
				end,
			})
		end,
	},
	{
		-- does not support YAML config files!
		"davidmh/cspell.nvim",
		cond = false,
		dependencies = "nvimtools/none-ls.nvim",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			local cspell = require("cspell")
			local null_ls = require("null-ls")
			null_ls.register(cspell.diagnostics)
			null_ls.register(cspell.code_actions)
		end,
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		opts_extend = { "ensure_installed" },
		opts = { ensure_installed = linters },
	},
}
