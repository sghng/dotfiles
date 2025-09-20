--- @type LazySpec
return {
	"hat0uma/csvview.nvim",
	cmd = { "CsvViewEnable", "CsvViewDisable", "CsvViewToggle" },
	keys = {
		{
			"<Localleader>v",
			"<Cmd>CsvViewToggle<CR>",
			desc = "Toggle CSV table [v]iew",
			ft = { "csv", "tsv" },
		},
	},
	--- @module "csvview"
	--- @type CsvView.Options
	opts = { parser = { quote_char = '"' } }, -- somehow needs to be specified
}
