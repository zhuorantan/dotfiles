if $VIM !~ "nvim"
    source $VIMRUNTIME/defaults.vim
endif

set clipboard=unnamed
set number relativenumber

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

highlight LineNr ctermfg=grey
