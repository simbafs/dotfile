-- modified from https://github.com/RRethy/dotfiles/blob/195d7c9bb7be0198e522d05fd528c9fb48121fba/nvim/init.lua#L546
local function autocmd(event, pattern, callback)
    vim.api.nvim_create_autocmd(event, {
        pattern = pattern,
        callback = callback,
    })
end

-- markdown
autocmd('FileType', { 'markdown', 'text' }, function() vim.o.wrap = true end)
vim.g.markdown_fenced_languages = { 'html', 'javascript', 'typescript', 'go', 'bash=sh', 'nasm' }

-- ejs
-- https://vi.stackexchange.com/questions/16341/what-is-the-difference-between-set-ft-and-setfiletype
autocmd({ 'BufNew', 'BufNewFile', 'BufRead' }, '*.ejs', function() vim.o.filetype = 'ejs' end)
autocmd('Filetype', 'ejs', function() vim.o.syntax = 'html' end)

-- nginx
autocmd({ 'BufNew', 'BufNewFile', 'BufRead' }, '/etc/nginx/*,/usr/local/nginx/conf/*', function() vim.o.filetype = 'nginx' end)

-- nas
autocmd({ 'BufNew', 'BufNewFile', 'BufRead' }, '*.nas', function() vim.o.filetype = 'nasm' end)

-- arista
autocmd({ 'BufNew', 'BufNewFile', 'BufRead' }, '*.desc', function() vim.o.syntax = 'json' end)
