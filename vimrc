if $VIM !~ "nvim"
    source $VIMRUNTIME/defaults.vim
endif

" ========== plugins ==========
call plug#begin('~/.vim/plugged')

if has("macunix")
    Plug '/usr/local/opt/fzf'
else
    Plug '/usr/share/doc/fzf/examples'
endif
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'airblade/vim-gitgutter'

call plug#end()

" ========== General ==========
let mapleader = ","

set clipboard=unnamed

set undofile

set mouse=a

set foldmethod=indent
set foldlevelstart=99 " start file with all folds opened

" ========== line number ==========
set number

augroup numbertoggle
    autocmd!
    autocmd BufEnter,FocusGained,InsertLeave * if &buftype != 'terminal' | set relativenumber | endif
    autocmd BufLeave,FocusLost,InsertEnter * set norelativenumber
    autocmd TermOpen * setlocal nonumber norelativenumber
augroup END

highlight LineNr ctermfg=grey

highlight GitGutterAdd    guifg=#009900 ctermfg=2
highlight GitGutterChange guifg=#bbbb00 ctermfg=3
highlight GitGutterDelete guifg=#ff2222 ctermfg=1

" ========== split ==========
set splitright
set splitbelow

highlight VertSplit cterm=NONE

" ========== search ==========
set incsearch
set hlsearch

set ignorecase
set smartcase

" ========== status line ==========
set ruler
set laststatus=2

" ========== indent and tab ==========
set autoindent
set smarttab

set expandtab
set tabstop=4
set shiftwidth=4
set shiftround

" ========== keymaps ==========
" allow saving of files as sudo
cmap w!! w !sudo tee > /dev/null %

nnoremap <Space> zz

nnoremap n nzzzv
nnoremap N Nzzzv

nnoremap <C-x> :bnext<CR>
nnoremap <C-z> :bprev<CR>

nnoremap <space> zz

nmap <leader>w :w<CR>
nmap <leader>q :q<CR>
nmap <leader>f za
nnoremap <leader><space> :nohlsearch<CR>

tnoremap <Esc> <C-\><C-n>

" ========== FZF ==========
nnoremap <C-p> :FZF<CR>

autocmd! FileType fzf
autocmd FileType fzf set laststatus=0 noshowmode noruler nonumber norelativenumber
autocmd BufLeave <buffer> set laststatus=2 showmode ruler

" ========== netrw ==========
let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_browse_split = 4
let g:netrw_altv = 1
let g:netrw_winsize = 20

" ========== auto ==========
" automatically source .vimrc on save
augroup Vimrc
    autocmd! bufwritepost .vimrc source $MYVIMRC
augroup END

" remember last cursor position
autocmd BufReadPost *
            \ if line("'\"") > 1 && line("'\"") <= line("$") |
            \     exe "normal! g`\"" |
            \ endif

" enter insert mode when enter terminal emulator
autocmd TermOpen,BufEnter,BufNew *
            \ if &buftype == 'terminal' |
            \     startinsert |
            \ endif

