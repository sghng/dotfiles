local linters_by_ft = {
	fish = { "fish" },
	bash = { "bash" },
	vim = { "vint" },
	-- FIXME: some linter is creating a node process when running in Neovide
	markdown = { "markdownlint-cli2", "cspell" },
	text = { "vale" },
	["*"] = { "cspell" },
}

for _, ft in ipairs({ "css", "json", "javascript", "typescript", "vue" }) do
	linters_by_ft[ft] = { "eslint_d" }
end

---@type LazySpec
return {
	"mfussenegger/nvim-lint",
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
}
