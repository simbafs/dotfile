vim.cmd "command! W w"
vim.cmd "command! Q q"
vim.cmd "command! Wq wq"
vim.cmd "command! WQ wq"

-- vim.o.background = 'light'

local function autocmd(event, pattern, callback)
  vim.api.nvim_create_autocmd(event, {
    pattern = pattern,
    callback = callback,
  })
end
autocmd("FileType", { "markdown", "text", "typst" }, function() vim.o.wrap = true end)
autocmd("BufEnter", { "leetcode.com_*.txt" }, function()
  vim.o.filetype = "javascript"
  vim.cmd "Copilot disable"
end)

os.execute "mkdir -p /tmp/firenvim"
if vim.g.started_by_firenvim == true then
  vim.cmd "set bg=light"
  vim.cmd "set ft=python"
end

-- vim.opt.colorcolumn = "80"

autocmd("FileType", { "ansible" }, function() vim.cmd "setlocal filetype=yaml.ansible" end)

-- autocmd("FileType", { "typst" }, function() vim.o.tabstop = 2 end)  
