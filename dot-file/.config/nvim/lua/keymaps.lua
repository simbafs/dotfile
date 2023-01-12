vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
vim.keymap.set('n', '<tab>', '>>')
vim.keymap.set('n', '<S-tab>', '<<')
vim.keymap.set('n', 'ch', ':noh<CR>')
vim.keymap.set('n', '<leader>f', vim.lsp.buf.format)
-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist)

-- Plugin keymaps
vim.keymap.set('n', '<F5>', ':NvimTreeToggle<CR>')
vim.keymap.set('n', '<F6>', ':UndotreeToggle<CR>')
vim.keymap.set('n', '<F7>', ':SymbolsOutline<CR>')
