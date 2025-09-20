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
--- @type LazyKeysSpec[]
local keys = {}
for _, def in ipairs(key_defs) do
	table.insert(keys, {
		"<Localleader>" .. def[1],
		"<Cmd>Quarto" .. def[2] .. "<CR>",
		desc = "Qurto " .. def[3],
		ft = "quarto",
	})
end

-- TODO: these plugins are not actively maintained... is it possible to have a
-- better Jupyter setup in Neovim? Currently the output rendering is terrible,
-- plus there's no official REPL support.

--- @type LazySpec
return {
	"quarto-dev/quarto-nvim",
	dependencies = {
		"jmbuhr/otter.nvim",
		"nvim-treesitter/nvim-treesitter",
		{
			"benlubas/molten-nvim",
			build = ":UpdateRemotePlugins",
			init = function()
				vim.g.molten_image_provider = "image.nvim"
				vim.g.molten_virt_text_output = true -- output always shown
				-- FIXME: offset of 1 conflicts with render-markdown, plus the
				-- image output is also misaligned.
				-- see https://github.com/benlubas/molten-nvim/issues/332
				-- vim.g.molten_virt_lines_off_by_1 = true -- display output after ```
				vim.g.molten_output_win_cover_gutter = false
				vim.g.molten_use_border_highlights = true
				vim.g.molten_output_show_more = true
			end,
		},
	},
	ft = "quarto",
	keys = keys,
	opts = { codeRunner = { default_method = "molten" } },
}
