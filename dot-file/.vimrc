syntax on

set showcmd
" blue default desert vening koehler murphy hpuff ron late zellner
" darkblue delek lflord industry morning blo hine torte
" colorscheme murphy
colorscheme koehler
set nu
set tabstop=4
set shiftwidth=4
set autoindent
set nowrap
set incsearch
set autoindent
set cindent
set smartindent

" code folding
set foldmethod=indent   
set foldnestmax=10
set nofoldenable
set foldlevel=2

so ~/.vim/plugin.vim

" add by simba
map <tab> :s/^/\t<CR>
map <S-tab> :s/^\t/<CR>
nmap <F3> :r! cat<CR>
nmap <S-@> :%s/  /\t/g<CR>
nmap <C-b> :!bash<CR>
au FileType markdown set wrap
au FileType text set wrap

" ejs
au BufNewFile,BufRead *.ejs setf ejs
au FileType ejs set syntax=html

" alias W to w
command W w
