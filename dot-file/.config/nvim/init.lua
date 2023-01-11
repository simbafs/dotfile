-- [[ Setting options ]]
-- See `:help vim.o`

vim.o.termguicolors = true
vim.o.showcmd = true
vim.o.nu = true
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.wrap = false
vim.o.incsearch = true
vim.o.autoindent = true
vim.o.cindent = true
vim.o.smartindent = true
vim.o.smarttab = true
vim.o.cursorline = true
vim.o.mouse = 'a'
vim.o.ignorecase = true
vim.o.hlsearch = true


vim.o.breakindent = true
vim.o.undofile = true
vim.o.smartcase = true

-- Decrease update time
vim.o.updatetime = 250
vim.wo.signcolumn = 'yes'

-- Set colorscheme
vim.cmd [[colorscheme catppuccin]]

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- [[ Basic Keymaps ]]

-- map
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


-- command alias
vim.cmd [[command! W w]]
vim.cmd [[command! Q q]]
vim.cmd [[command! Wq wq]]
vim.cmd [[command! WQ wq]]

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
    callback = function()
        vim.highlight.on_yank()
    end,
    group = highlight_group,
    pattern = '*',
})

-- markdown
vim.cmd [[au FileType markdown, text set wrap]]
vim.g.markdown_fenced_languages = { 'html', 'javascript', 'typescript', 'go', 'bash=sh', 'nasm' }

-- ejs
-- https://vi.stackexchange.com/questions/16341/what-is-the-difference-between-set-ft-and-setfiletype
vim.cmd [[au BufNew,BufNewFile,BufRead *.ejs :set filetype=ejs]]
vim.cmd [[au FileType ejs set syntax=html]]

-- nginx
vim.cmd [[au BufRead,BufNewFile /etc/nginx/*,/usr/local/nginx/conf/* setfiletype nginx]]

-- ts
vim.cmd [[autocmd BufNewFile,BufRead *.ts set syntax=javascript]]

-- yaml
vim.cmd [[autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab]]

-- nas
vim.cmd [[autocmd BufEnter,BufNew *.nas set ft=nasm]]

-- load plugins
require 'plugin'
