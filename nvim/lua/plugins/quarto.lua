local key_defs = {
	-- key suffix, Quarto command suffix, description
	{ "p", "Preview", "[p]review" },
	{ "u", "UpdatePreview", "[u]pdate preview" },
	{ "q", "ClosePreview", "[q]uiet preview" },
	{ "ra", "SendAll", "run [a]bove" },
	{ "rA", "SendAll", "run [A]LL" },
	{ "rb", "SendBelow", "run [b]elow" },
	{ "rl", "SendLine", "run to [l]ine" },
	{ "rr", "Send", "run, just [r]un (the cell)" },
	{ "rg", "Send", "run ran[g]e" },
}
---@type LazyKeysSpec[]
local keys = {}
for _, def in ipairs(key_defs) do
	table.insert(keys, {
		"<Localleader>" .. def[1],
		"<Cmd>Quarto" .. def[2] .. "<CR>",
		desc = "Qurto " .. def[3],
		ft = "quarto",
	})
end

---@type LazySpec
return {
	"quarto-dev/quarto-nvim",
	dependencies = {
		"jmbuhr/otter.nvim",
		"nvim-treesitter/nvim-treesitter",
		"benlubas/molten-nvim",
	},
	ft = "quarto",
	keys = keys,
	opts = { codeRunner = { default_method = "molten" } },
}
