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

" alias
command W w
command Q q
command Wq wq
command WQ wq

" nginx
" au BufRead,BufNewFile /etc/nginx/*,/usr/local/nginx/conf/* if &ft == '' | setfiletype nginx | endif
au BufRead,BufNewFile /etc/nginx/*,/usr/local/nginx/conf/* setfiletype nginx

" toggle nu
nmap <F7> :set invnumber<CR>
" xclip

" for powerline
python3 from powerline.vim import setup as powerline_setup
python3 powerline_setup()
python3 del powerline_setup

set laststatus=2
