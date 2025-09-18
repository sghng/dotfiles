local key_defs = {
	-- key suffix, Telescope sub command, description
	{ "b", "buffers", "[b]uffers" },
	{ "c", "commands", "[c]ommands" },
	{ "f", "find_files", "[f]iles" },
	{ "g", "live_grep", "live [g]rep" },
	{ "h", "help_tags", "[h]elp tags" },
	{ "k", "keymaps", "[k]eymaps" },
	{ "s", "symbols", "[s]ymbols" },
	{ "m", "", "[m]ore in Telescope" },
	{ "n", "<Cmd>Noice telescope<CR>", "[n]otifications in Telescope" },
}
---@type LazyKeysSpec[]
local keys = { { "<Leader>t", "<Cmd>Telescope<CR>", desc = "Telescope" } }
for _, def in ipairs(key_defs) do
	table.insert(keys, {
		"<Leader>f" .. def[1],
		"<Cmd>Telescope " .. def[2] .. "<CR>",
		desc = "[f]ind " .. def[3],
	})
end

---@type LazySpec
return {
	"nvim-telescope/telescope.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		"polirritmico/telescope-lazy-plugins.nvim",
		"nvim-treesitter/nvim-treesitter",
		"nvim-tree/nvim-web-devicons",
	},
	build = "brew install rg fd", -- for extended functionality
	cmd = "Telescope",
	keys = keys,
	---@module "telescope"
	opts = {
		defaults = {
			layout_strategy = "flex",
			layout_config = {
				flex = {
					flip_columns = 100, -- Switch to vertical when width < 100 columns
					flip_lines = 20, -- Switch to horizontal when height < 20 lines
				},
				horizontal = {
					preview_cutoff = 30,
					preview_width = 0.6,
				},
			},
		},
	},
	config = function(_, opts)
		local ts = require("telescope")
		ts.setup(opts)
		for _, e in ipairs({ "fzf", "lazy_plugins", "noice" }) do
			ts.load_extension(e)
		end
	end,
}
