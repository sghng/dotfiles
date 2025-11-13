---Add which-key mappings safely from anywhere
---@param spec wk.Spec
function _G.wk_add(spec)
	vim.schedule(function()
		local success, wk = pcall(require, "which-key")
		if success then
			wk.add(spec)
		else
			wk_add(spec)
		end
	end)
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
