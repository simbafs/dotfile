-- This will run last in the setup process and is a good place to configure
-- things like custom filetypes. This just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

-- Set up custom filetypes
-- vim.filetype.add {
--   extension = {
--     foo = "fooscript",
--   },
--   filename = {
--     ["Foofile"] = "fooscript",
--   },
--   pattern = {
--     ["~/%.config/foo/.*"] = "fooscript",
--   },
-- }
vim.cmd "command! W w"
vim.cmd "command! Q q"
vim.cmd "command! Wq wq"
vim.cmd "command! WQ wq"

-- modified from https://github.com/RRethy/dotfiles/blob/195d7c9bb7be0198e522d05fd528c9fb48121fba/nvim/init.lua#L546
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
-- mv ~/.local/share/nvim/lazy/nvim-treesitter/queries/dart/indents.scm ~/.local/share/nvim/lazy/nvim-treesitter/queries/dart/indents.scm.disable

-- firenvim
if vim.g.started_by_firenvim == true then
  vim.cmd "set bg=light"
  vim.cmd "set ft=python"
end

-- vim.cmd "set guicursor=n-v-c-i:block"
