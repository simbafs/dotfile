-- Set colorscheme
vim.cmd.colorscheme("catppuccin")

require("options")
require("keymaps")
require("commands")
require("filetypes")
require("misc")
require("plugin")

-- Automatically source and re-compile packer whenever you save this init.lua
local packer_group = vim.api.nvim_create_augroup("Packer", { clear = true })
vim.api.nvim_create_autocmd("BufWritePost", {
	command = "source <afile> | silent! LspStop | silent! LspStart | PackerCompile",
	group = packer_group,
	pattern = vim.fn.expand("$MYVIMRC"),
})
