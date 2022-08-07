syntax on

" load plguin
" install vim-plug:
" sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
"        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
so ~/.config/nvim/plugin.vim

" available color schema
" blue darkblue default delek desert elflord evening industry koehler
" morning  murphy pablo peachpuff ron shine slate torte zellner
set t_Co=256
set t_ut=
" colorscheme koehler
colorscheme solarized
so ~/.config/nvim/transparent.vim
" set background=dark

set termguicolors
set showcmd
set nu
set tabstop=4
set shiftwidth=4
set nowrap
set incsearch
set autoindent
set cindent
set smartindent
set cursorline
set mouse=a

" markdown
au FileType markdown set wrap
au FileType text set wrap
" ejs
" https://vi.stackexchange.com/questions/16341/what-is-the-difference-between-set-ft-and-setfiletype
au BufNew,BufNewFile,BufRead *.ejs :set filetype=ejs
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
map <tab> >>
map <S-tab> <<
nmap cs :noh<CR>
au BufNewFile,BufRead *.go nmap gr :GoRun<CR>

" alias
command W w
command Q q
command Wq wq
command WQ wq

" fix bg color error in Pmenu
" https://vi.stackexchange.com/questions/23328/change-color-of-coc-suggestion-box
hi Pmenu ctermbg=black ctermfg=white
hi Ignore ctermbg=black ctermfg=lightblue
hi CursorLine cterm=none ctermbg=238
hi CursorLineNr cterm=bold ctermfg=33 ctermbg=245

if exists('+wrap')
	map <UP> gk
	map <DOWN> gj
	map j gj
	map k gk
endif

if exists('+colorcolumn')
	set colorcolumn=120
	hi ColorColumn ctermbg=240
endif

let g:markdown_fenced_languages = ['html', 'javascript', 'typescript', 'go', 'bash=sh']
