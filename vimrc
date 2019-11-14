if $VIM !~ "nvim"
    source $VIMRUNTIME/defaults.vim
endif

set clipboard=unnamed
set number relativenumber

augroup numbertoggle
    autocmd!
    autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
    autocmd BufLeave,FocusLost,InsertEnter * set norelativenumber
augroup END

set splitright
set splitbelow
set laststatus=2

set ruler
set incsearch
set hlsearch
set ignorecase
set smartcase

set autoindent
set smarttab

set expandtab
set tabstop=4
set shiftwidth=4

set shiftround

set mouse=a

" allow saving of files as sudo
cmap w!! w !sudo tee > /dev/null %

let mapleader = ","
let g:mapleader = ","

nnoremap <leader><space> :nohlsearch<CR>

nnoremap n nzz
nnoremap N Nzz

highlight LineNr ctermfg=grey

if has("macunix")
    set rtp+=/usr/local/opt/fzf
else
    set rtp+=/usr/share/doc/fzf/examples
endif
