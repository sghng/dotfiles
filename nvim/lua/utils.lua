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
