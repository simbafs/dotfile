call plug#begin('~/.vim/plugged')

Plug 'airblade/vim-gitgutter'

Plug 'itchyny/lightline.vim'
"make lightline work in single screen
set laststatus=2

Plug 'mattn/emmet-vim'
" let g:user_emmet_install_global = 0
" au FileType html,css,ejs EmmetInstall

Plug 'scrooloose/nerdtree'
nmap <F5> :NERDTreeToggle<CR>
" Exit Vim if NERDTree is the only window left.
autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() |
	\ quit | endif

Plug 'jiangmiao/auto-pairs'
au FileType ejs let b:AutoPairs = AutoPairsDefine({'<%': '%>', '<!--': '-->'})
au FileType html let b:AutoPairs = AutoPairsDefine({'<!--': '-->'})

Plug 'Valloric/YouCompleteMe', { 'do': './install.py --ts-completer ' }
" Start autocompletion after 2 chars
let g:ycm_min_num_of_chars_for_completion = 2
let g:ycm_min_num_identifier_candidate_chars = 2
let g:ycm_enable_diagnostic_highlighting = 0
nmap gd :YcmCompleter GoToDefinition<CR>
" let g:ycm_complete_in_comments = 1
let g:ycm_collect_identifiers_from_comments_and_strings = 1
let g:ycm_autoclose_preview_window_after_insertion = 1
" Apply YCM FixIt
map <F9> :YcmCompleter FixIt<CR>
" nmap f :YcmCompleter Format<CR>
" ycm extra conf
let g:ycm_global_ycm_extra_conf = '/home/simba/.vim/.ycm_extra_conf.py'

Plug 'othree/javascript-libraries-syntax.vim'

Plug 'majutsushi/tagbar'
nmap <F8> :TagbarToggle<CR>

Plug 'junegunn/vim-easy-align'
" Align GitHub-flavored Markdown tables
au FileType markdown vmap <Leader><Bslash> :EasyAlign*<Bar><Enter>

Plug 'suan/vim-instant-markdown', {'for': 'markdown'}

Plug 'dkarter/bullets.vim'
" let g:bullets_enabled_file_types = [
"     \ 'markdown',
"     \ 'text',
"     \ 'gitcommit',
"     \ 'scratch'
"     \]

Plug 'Chiel92/vim-autoformat'
nmap f :Autoformat<CR>

Plug 'preservim/nerdcommenter'
filetype plugin on
" Add spaces after comment delimiters by default
let g:NERDSpaceDelims = 1
" Use compact syntax for prettified multi-line comments
let g:NERDCompactSexyComs = 1
" Align line-wise comment delimiters flush left instead of following code indentation
let g:NERDDefaultAlign = 'left'
" Set a language to use its alternate delimiters by default
let g:NERDAltDelims_java = 1
" Add your own custom formats or override the defaults
let g:NERDCustomDelimiters = { 'c': { 'left': '/**','right': '*/' } }
" Allow commenting and inverting empty lines (useful when commenting a region)
let g:NERDCommentEmptyLines = 1
" Enable trimming of trailing whitespace when uncommenting
let g:NERDTrimTrailingWhitespace = 1
" Enable NERDCommenterToggle to check all selected lines is commented or not 
let g:NERDToggleCheckAllLines = 1

Plug 'ekalinin/Dockerfile.vim'

Plug 'editorconfig/editorconfig-vim'


" js / jsx
Plug 'pangloss/vim-javascript'

Plug 'isruslan/vim-es6'

Plug 'maxmellon/vim-jsx-pretty'
" fix jsx tag color for vim-jsx-pretty
hi link jsxPunct Directory
hi link jsxCloseString Directory


" css
Plug 'ap/vim-css-color'


" c / cpp
" Plug 'bfrg/vim-cpp-modern'


" mindustry
Plug 'purofle/vim-mindustry-logic'

Plug 'mbbill/undotree'
nnoremap <F6> :UndotreeToggle<CR>

call plug#end()
