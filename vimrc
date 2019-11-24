if $VIM !~ "nvim"
    source $VIMRUNTIME/defaults.vim
endif

" ========== plugins ==========
if empty(glob('~/.vim/autoload/plug.vim'))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
                \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')

if has("macunix")
    Plug '/usr/local/opt/fzf'
else
    Plug '/usr/share/doc/fzf/examples'
endif
Plug 'junegunn/fzf.vim'

Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-repeat'
Plug 'airblade/vim-gitgutter'
Plug 'thalesmello/tabfold'
Plug 'raimondi/delimitmate'

Plug 'itchyny/lightline.vim'
Plug 'ap/vim-buftabline'

Plug 'neoclide/coc.nvim', {'branch': 'release'}

Plug 'altercation/vim-colors-solarized'

call plug#end()

" ========== General ==========
let mapleader = ","

set clipboard=unnamed

set undofile
set autowrite
set inccommand=nosplit

set mouse=a

set foldmethod=indent
set foldlevelstart=99 " start file with all folds opened

set signcolumn=yes " always show sign columns

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

" center
nnoremap <Space> zz
nnoremap n nzzzv
nnoremap N Nzzzv
nnoremap * *zzzv
nnoremap # #zzzv

" buffer navigation
nnoremap <C-x> :bnext<CR>
nnoremap <C-z> :bprev<CR>

" leader
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>
nnoremap <leader><space> :nohlsearch<CR>

" terminal
tnoremap <Esc> <C-\><C-n>

" ========== netrw ==========
let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_browse_split = 4
let g:netrw_altv = 1
let g:netrw_winsize = 20

" ========== auto ==========

" automatically source .vimrc on save
autocmd! bufwritepost .vimrc source $MYVIMRC

" remember last cursor position
autocmd! BufReadPost *
            \ if line("'\"") > 1 && line("'\"") <= line("$") |
            \     exe "normal! g`\"" |
            \ endif

" spell check for git commits
autocmd! FileType gitcommit setlocal spell

" resize panes when window resizes
autocmd! VimResized * :wincmd =

" enter insert mode when enter terminal emulator
autocmd! TermOpen,BufEnter,BufNew *
            \ if &buftype == 'terminal' |
            \     startinsert |
            \ endif

" ========== fugitive ==========

nnoremap <leader>ga :Git add %:p<CR>
nnoremap <leader>gc :Gcommit -q<CR>
nnoremap <leader>gg :Gstatus<CR>
nnoremap <leader>gd :Gdiffsplit<CR>
nnoremap <leader>gp :Gpush<CR>
nnoremap <leader>gb :Gblame<CR>
vnoremap <leader>gb :Gblame<CR>

" ========== FZF ==========

nnoremap <C-p> :Files<CR>
nnoremap <leader>b :Buffers<CR>
nnoremap <leader>c :Commands<CR>
nnoremap <leader>M :Maps<CR>
nnoremap <leader>l :Lines<CR>
nnoremap <leader>t :Filetypes<CR>

autocmd! FileType fzf
autocmd FileType fzf set laststatus=0 noruler nonumber norelativenumber |
            \ autocmd BufLeave <buffer> set laststatus=2 ruler

" ========== solarized ==========

let g:solarized_termcolors=256
colorscheme solarized

" ========== lightline ==========

set noshowmode

let g:lightline = {
            \   'active': {
            \     'left': [ [ 'mode', 'paste' ],
            \               [ 'readonly', 'filename', 'modified', 'cocstatus', 'currentfunction' ] ]
            \   },
            \   'component_function': {
            \     'cocstatus': 'coc#status',
            \     'currentfunction': 'CocCurrentFunction'
            \   },
            \ }

" ========== coc ==========

if has_key(g:plugs, 'coc.nvim')
    set updatetime=300

    set shortmess+=c

    " Use tab for trigger completion with characters ahead and navigate.
    " Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
    inoremap <silent><expr> <TAB>
                \ pumvisible() ? "\<C-n>" :
                \ <SID>check_back_space() ? "\<TAB>" :
                \ coc#refresh()
    inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

    function! s:check_back_space() abort
        let col = col('.') - 1
        return !col || getline('.')[col - 1]  =~# '\s'
    endfunction

    " Use <cr> to confirm completion, `<C-g>u` means break undo chain at current position.
    " Coc only does snippet and additional edit on confirm.
    inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
    " Or use `complete_info` if your vim support it, like:
    " inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"
    
    " Use `[g` and `]g` to navigate diagnostics
    nmap <silent> [g <Plug>(coc-diagnostic-prev)
    nmap <silent> ]g <Plug>(coc-diagnostic-next)

    " Remap keys for gotos
    nmap <silent> gd <Plug>(coc-definition)

    " Use K to show documentation in preview window
    nnoremap <silent> K :call <SID>show_documentation()<CR>

    function! s:show_documentation()
        if (index(['vim','help'], &filetype) >= 0)
            execute 'h '.expand('<cword>')
        else
            call CocAction('doHover')
        endif
    endfunction

    " Remap for rename current word
    nmap <leader>rn <Plug>(coc-rename)

    " Remap for format selected region
    xmap <leader>f <Plug>(coc-format-selected)
    nmap <leader>f <Plug>(coc-format-selected)

    " Add status line support, for integration with other plugin, checkout `:h coc-status`
    function! CocCurrentFunction()
        return get(b:, 'coc_current_function', '')
    endfunction
    
endif
