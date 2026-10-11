---Add which-key mappings safely from anywhere
---@param spec wk.Spec
function _G.wk_add(spec)
	local attempts = 0
	local function try()
		local success, wk = pcall(require, "which-key")
		if success then
			wk.add(spec)
		elseif attempts < 600 then
			attempts = attempts + 1
			-- timer-based retry yields the main loop (vim.schedule recursion starves
			-- it, deadlocking startup when which-key isn't installed yet)
			vim.defer_fn(try, 100)
		else
			vim.notify("wk_add: which-key unavailable, mappings dropped", vim.log.levels.WARN)
		end
	end
	try()
end

---Get the root directory from LSP for the **current** buffer
function _G.root()
	for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
		if client.name ~= "copilot" and client.root_dir then
			return client.root_dir
		end
	end
	return nil
end
