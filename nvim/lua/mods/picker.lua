local key_defs = {
	-- key suffix, Snacks.picker function, description
	{ "b", "buffers", "[b]uffers" },
	{ "c", "commands", "[c]ommands" },
	{ "f", "files", "[f]iles" },
	{ "h", "help", "[h]elp tags" },
	{ "k", "keymaps", "[k]eymaps" },
	{ "n", "notifications", "[n]otifications" },
	{ "r", "recent", "[r]ecent files" },
	{ "s", "lsp_symbols", "[s]ymbols" },
}
---@type LazyKeysSpec[]
local keys = {
	{ "<Leader>f", "<Nop>", desc = "[f]ind (with picker)" },
	{
		"<Leader>/",
		function()
			Snacks.picker.grep()
		end,
		desc = "live grep",
	},
	{
		"<Leader><Space>",
		function()
			Snacks.picker.smart()
		end,
		desc = "Smart Find Files (Snacks)",
	},
}
for _, def in ipairs(key_defs) do
	table.insert(keys, {
		"<Leader>f" .. def[1],
		function()
			Snacks.picker[def[2]]()
		end,
		desc = "[f]ind " .. def[3],
	})
end

---@type LazySpec
return {
	{
		"folke/snacks.nvim",
		keys = keys,
		opts = { picker = {} },
	},
}
