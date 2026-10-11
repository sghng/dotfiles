-- requires imagemagick and tmux config
---@type LazySpec
return {
	"3rd/image.nvim",
	build = function()
		if vim.fn.executable("magick") == 1 then
			return
		elseif vim.fn.has("macunix") == 1 then
			vim.system({ "brew", "install", "imagemagick" })
		else
			-- no passwordless sudo here; install once manually
			vim.notify("image.nvim: run `sudo apt install imagemagick`", vim.log.levels.WARN)
		end
	end,
	cond = not vim.g.neovide, -- not supported in neovide yet
	lazy = true, -- delay until needed
	opts = { processor = "magick_cli" },
}
