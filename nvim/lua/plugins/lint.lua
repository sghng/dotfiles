local linters_by_ft = {
	fish = { "fish" },
	bash = { "bash" },
	vint = { "vint" },
	markdown = { "markdownlint-cli2" },
	["*"] = { "cspell" },
}

for _, ft in ipairs({ "css", "json", "javascript", "typescript", "vue" }) do
	linters_by_ft[ft] = { "eslint_d" }
end

---@type LazySpec
return {
	"mfussenegger/nvim-lint",
	event = { "BufRead", "BufNewFile" },
	config = function()
		local lint = require("lint")
		-- certain linters are activated along with language server
		lint.linters_by_ft = linters_by_ft
		vim.api.nvim_create_autocmd({ "InsertLeave", "BufReadPost" }, {
			group = vim.api.nvim_create_augroup("Linting", { clear = true }),
			-- FIXME: somehow this is not called on time
			callback = function()
				lint.try_lint()
			end,
		})
		vim.diagnostic.config({ virtual_text = true })
	end,
}
