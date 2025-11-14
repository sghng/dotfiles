---@type LazySpec
return {
	"nvimdev/dashboard-nvim",
	dependencies = "nvim-tree/nvim-web-devicons",
	lazy = vim.fn.argc() ~= 0, -- load as requested if opening a dir entry
	cmd = "Dashboard",
	init = function()
		vim.opt.shortmess:append("I") -- disables msg to prevent flashing
	end,
	opts = {
		hide = { tabline = false }, -- allow navigating back to buffers
		config = {
			-- TODO: a custom header
			week_header = { enable = true },
			footer = { "", "󰝗 尽心，知性，知天󰉾 " },
			project = {
				action = function(path)
					vim.fn.chdir(path)
					require("snacks").picker.files()
				end,
			},
			shortcut = {
				{
					key = "g",
					icon = " ",
					desc = "GitHub",
					group = "@property",
					action = "!open https://github.com/sghng/",
				},
				{
					icon = " ",
					desc = "Files",
					group = "@number",
					action = function()
						require("snacks").picker.smart()
					end,
					key = "f",
				},
				{
					icon = " ",
					desc = "Dots",
					group = "@label",
					action = "cd ~/dev/dotfiles | e .",
					key = "d",
				},
				{
					icon = "󰒲 ",
					desc = "Lazy",
					group = "@string",
					action = "Lazy",
					key = "l",
				},
				{
					icon = " ",
					desc = "Obsidian",
					group = "@attribute",
					action = "cd ~/obsidian | e .",
					key = "o",
				},
			},
		},
	},
}
