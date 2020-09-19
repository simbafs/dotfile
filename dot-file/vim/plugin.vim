call plug#begin('~/.vim/plugged')

Plug 'airblade/vim-gitgutter'
"Plug 'editorconfig/editorconfig-vim'
Plug 'itchyny/lightline.vim'
"Plug 'junegunn/fzf'
"Plug 'junegunn/fzf.vim'
Plug 'mattn/emmet-vim'
Plug 'scrooloose/nerdtree'
"Plug 'terryma/vim-multiple-cursors'
Plug 'tpope/vim-surround'
"Plug 'w0rp/ale'
"Plug 'marijnh/tern_for_vim', {'for': 'javascript'}
Plug 'Valloric/YouCompleteMe', { 'do': './install.py --ts-completer ' }
"Plug 'ternjs/tern_for_vim', { 'do' : 'npm install' }
Plug 'pangloss/vim-javascript'
Plug 'othree/javascript-libraries-syntax.vim'
"Plug 'vim-syntastic/syntastic'
Plug 'ap/vim-css-color'
"Plug 'vimscript/taglist'
"Plug 'yazug/vim-taglist-plus'
Plug 'majutsushi/tagbar'
Plug 'bfrg/vim-cpp-modern'
Plug 'mxw/vim-jsx'
Plug 'isruslan/vim-es6'
" Plug 'godlygeek/tabular'
Plug 'junegunn/vim-easy-align'

" Plug 'plasticboy/vim-markdown'
Plug 'suan/vim-instant-markdown', {'for': 'markdown'}
Plug 'Chiel92/vim-autoformat'
Plug 'preservim/nerdcommenter'
Plug 'ekalinin/Dockerfile.vim'
" Plug 'kevinhwang91/vim-ibus-sw'

call plug#end()
"autocmd FileType javascript setlocal omnifunc=tern#Complete
"set completeopt-=preview
