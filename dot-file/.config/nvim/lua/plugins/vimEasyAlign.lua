vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
	pattern = "*.md",
	callback = function()
		vim.keymap.set("v", "<Leader><Bslash>", ":EasyAlign*<Bar><Enter>")
	end,
})
