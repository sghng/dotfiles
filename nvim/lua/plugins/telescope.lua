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
	keys = {
		-- recommended by Telescope
		{
			"<Leader>ff",
			require("telescope.builtin").find_files,
			desc = "[f]ind [f]iles (Telescope)",
		},
		{
			"<Leader>fg",
			require("telescope.builtin").live_grep,
			desc = "[l]ive [g]rep (Telescope)",
		},
		{
			"<Leader>fb",
			require("telescope.builtin").buffers,
			desc = "[f]ind [b]uffers (Telescope)",
		},
		{
			"<Leader>fh",
			require("telescope.builtin").help_tags,
			desc = "[f]ind [h]elp tags (Telescope)",
		},
		-- custom mappings
		{ "<Leader>t", "<Cmd>Telescope<CR>", desc = "Open [t]elescope" },
		{
			"<Leader>fc",
			require("telescope.builtin").commands,
			desc = "[f]ind [c]ommands (Telescope)",
		},
	},
	---@module "telescope"
	opts = {
		defaults = {
			---@type TelescopeLayout.config
			---@diagnostic disable-next-line: missing-fields
			layout_config = { horizontal = {
				preview_cutoff = 30,
				preview_width = 0.8,
			} },
		},
	},
	config = function()
		for _, e in ipairs({ "fzf", "lazy_plugins", "noice" }) do
			require("telescope").load_extension(e)
		end
	end,
}
