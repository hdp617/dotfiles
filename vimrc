set nocompatible " not vi compatible

"------------------
" Syntax and indent
"------------------
syntax on " turn on syntax highlighting
set showmatch " show matching braces when text indicator is over them

" highlight current line, but only in active window
augroup CursorLineOnlyInActiveWindow
    autocmd!
    autocmd VimEnter,WinEnter,BufWinEnter * setlocal cursorline
    autocmd WinLeave * setlocal nocursorline
augroup END

"------------------
" Color scheme
"------------------
let g:material_terminal_italics = 1
let g:material_theme_style = 'default'
let g:lightline = { 'colorscheme': 'material_vim' }
colorscheme material

"---------------------
" Basic editing config
"---------------------
set shortmess+=I " disable startup message
set nu " number lines
set rnu " relative line numbering
set incsearch " incremental search (as string is being typed)
set hls " highlight search
set noshowmode " hide mode
set laststatus=2


"--------------------
" Misc configurations
"--------------------


"---------------------
" Plugin configuration
"---------------------

" nerdtree
nnoremap <Leader>n :NERDTreeToggle<CR>
nnoremap <Leader>f :NERDTreeFind<CR>

" incsearch
map / <Plug>(incsearch-forward)
map ? <Plug>(incsearch-backward)
map g/ <Plug>(incsearch-stay)
