"copy and paste in and out easy
vmap <C-c> "+yi
vmap <C-x> "+c
vmap <C-v> c<ESC>"+p
imap <C-v> <C-r><C-o>+
"set clipboard=unnamed

set number
set relativenumber
set autoindent
set tabstop=4
set shiftwidth=4
set smarttab
set softtabstop=4
"set mouse=a

"compile and run c code with f8
map <F8> :w <CR> :!gcc % -o %< && ./%< <CR>

"compile and run nim code
map <F7> :w <CR> :!nim c -r % <CR>

call plug#begin()(has('nvim') ? stdpath('data') . '/plugged' : '~/.config/nvim/')
" NERD tree will be loaded on the first invocation of NERDTreeToggle command
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }

Plug 'scrooloose/syntastic'

Plug 'neoclide/coc.nvim', {'branch': 'release'} , {'do': 'yarn install --frozen-lockfile'}

Plug 'vim-airline/vim-airline'

Plug 'tyru/open-browser.vim'
call plug#end()

" Highlight cursor line underneath the cursor horizontally.
set cursorline

"stop bell
set noeb vb t_vb=

nnoremap <C-f> :NERDTreeFocus<CR>
nnoremap <C-n> :NERDTree<CR>
nnoremap <C-t> :NERDTreeToggle<CR>
nnoremap <C-l> :call CocActionAsync('jumpDefinition')<CR>

nmap <F8> :TagbarToggle<CR>

:set completeopt-=preview " For No Previews

let g:NERDTreeDirArrowExpandable="+"
let g:NERDTreeDirArrowCollapsible="~"

" Have nerdtree ignore certain files and directories.
let NERDTreeIgnore=['\.git$', '\.jpg$', '\.mp4$', '\.ogg$', '\.iso$', '\.pdf$', '\.pyc$', '\.odt$', '\.png$', '\.gif$', '\.db$']

syntax on
"Syntasic 
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

"COC Pluign install
let g:coc_global_extensions = ['coc-markdownling', 'coc-sh', 'coc-pyright', 'coc-rome', 'coc-yank', 'coc-git', 'coc-lists']
