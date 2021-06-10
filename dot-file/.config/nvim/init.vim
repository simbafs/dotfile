syntax on

" load plguin
" install vim-plug:
" sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
"        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
so ~/.config/nvim/vim/plugin.vim

" available color schema
" blue darkblue default delek desert elflord evening industry koehler 
" morning  murphy pablo peachpuff ron shine slate torte zellner 
set t_Co=256
set t_ut=
colorscheme koehler

set showcmd
set nu
set tabstop=4
set shiftwidth=4
set autoindent
set nowrap
set incsearch
set autoindent
set cindent
set smartindent
set cursorline
"make lightline work in single screen
set laststatus=2

" markdown
au FileType markdown set wrap
au FileType text set wrap
" ejs
au BufNewFile,BufRead *.ejs setf ejs
au FileType ejs set syntax=html
" nginx
au BufRead,BufNewFile /etc/nginx/*,/usr/local/nginx/conf/* setfiletype nginx
" ts
autocmd BufNewFile,BufRead *.ts set syntax=javascript
" yaml
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab

" code folding
" za -> toggle folding
" zc -> close
" zo -> open
" zC -> close all
" zo -> open All
set foldmethod=indent
set foldnestmax=10
set nofoldenable
set foldlevel=2

" hotkey
map <tab> :s/^/\t<CR>
map <S-tab> :s/^\t/<CR>
nmap <F3> :r! cat<CR>
nmap <F7> :set invnumber<CR>

" alias
command W w
command Q q
command Wq wq
command WQ wq

" fix bg color error in Pmenu
" https://vi.stackexchange.com/questions/23328/change-color-of-coc-suggestion-box
hi Pmenu ctermbg=black ctermfg=white
hi Ignore ctermbg=black ctermfg=lightblue
