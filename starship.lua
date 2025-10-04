#!/usr/bin/env lua

local MODULES = {
	-- LANGUAGES
	{ name = "bun", bg = "#791A49", symbol = "" },
	{ name = "c", bg = "#1C4679", symbol = "" },
	{ name = "cpp", bg = "#00599C", symbol = "" },
	{ name = "cmake", bg = "#DF3C3C", symbol = "" },
	{ name = "java", bg = "#ED8B00", symbol = "" },
	{ name = "lua", bg = "#000080", symbol = "" },
	{ name = "nodejs", bg = "#339933", symbol = "" },
	{
		name = "python",
		bg = "#987A26",
		symbol = "",
		format = [[$symbol $pyenv_prefix$version( \\($virtualenv\\))]],
	},
	{ name = "quarto", bg = "#447099" },
	{ name = "rlang", bg = "#3867B6", symbol = "" },
	-- ENVIRONMENTS
	{ name = "conda", bg = "#53B553", symbol = "", format = "$symbol $environment" },
}

local function generate_modules()
	local output = {}

	for _, m in ipairs(MODULES) do
		table.insert(output, "[" .. m.name .. "]")

		if m.symbol then
			table.insert(output, 'symbol = "' .. m.symbol .. '"')
		end

		local format = m.format or "$symbol $version"
		table.insert(
			output,
			'format = "([](bg:' .. m.bg .. " fg:prev_bg)[ " .. format .. ' ](bg:prev_bg fg:bright-white))"'
		)
		table.insert(output, "")
	end

	return table.concat(output, "\n")
end

local function generate_format()
	local output = {}
	for _, m in ipairs(MODULES) do
		table.insert(output, "$" .. m.name)
	end
	return table.concat(output, "")
end

local file = assert(io.open(arg[1], "r"))
local content = file:read("*all")
file:close()

local modules = generate_modules()
local format = generate_format()
content = content:gsub("# >>>[%s%S]*# <<<", "# >>>\n\n" .. modules .. "\n# <<<", 1)
content = content:gsub("\n\\[%s%S]*\n\\", "\n\\\n" .. format .. "\\\n\\", 1)

file = assert(io.open(arg[1], "w"))
file:write(content)
file:close()
