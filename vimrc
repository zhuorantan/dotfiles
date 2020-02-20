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
Plug 'thinca/vim-quickrun'
Plug 'mbbill/undotree', {'on': 'UndotreeToggle'}
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeFind' }
Plug 'mhinz/vim-sayonara', { 'on': 'Sayonara' }

Plug 'christoomey/vim-tmux-navigator'

Plug 'itchyny/lightline.vim'
Plug 'ap/vim-buftabline'
Plug 'machakann/vim-highlightedyank'

Plug 'neoclide/coc.nvim', {'branch': 'release'}

Plug 'altercation/vim-colors-solarized'

call plug#end()

" ========== General ==========

let mapleader = "\<Space>"

set clipboard=unnamed

set undofile
set autowrite
set inccommand=nosplit

set mouse=a

set foldmethod=indent
set foldlevelstart=99 " start file with all folds opened

set cursorline

set hidden

" ========== line number ==========

set number

augroup numbertoggle
    autocmd!
    autocmd BufEnter,FocusGained,InsertLeave * if &buftype != 'terminal' && &filetype != 'nerdtree' | set relativenumber | endif
    autocmd BufLeave,FocusLost,InsertEnter * set norelativenumber
    autocmd TermOpen * setlocal nonumber norelativenumber
augroup END

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

" fix
nnoremap Y y$

" center
nnoremap n nzzzv
nnoremap N Nzzzv
nnoremap * *zzzv
nnoremap # #zzzv

" leader
nnoremap <silent><leader><Space> zz:nohlsearch<CR>
nnoremap <silent><leader>w :w<CR>
nnoremap <silent><leader>q :Sayonara<CR>
nnoremap <silent><leader>Q :Sayonara!<CR>
nnoremap <leader><Tab> <C-^>

" terminal
tnoremap <Esc> <C-\><C-n>

" ========== nerdtree ==========

function! s:nerdtreeToggle()
    if &filetype == 'nerdtree'
        :NERDTreeToggle
    else
        :NERDTreeFind
    endif
endfunction

" disable netrw
let loaded_netrwPlugin = 1
let NERDTreeMinimalUI = 1
let NERDTreeShowHidden=1
let NERDTreeQuitOnOpen=1
let NERDTreeIgnore=['\.vim$', '\~$', '\.git$', '.DS_Store']
nnoremap <silent><Leader>n :call <SID>nerdtreeToggle()<CR>

" close vim if the only window left open is a NERDTree
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" ========== auto ==========

" save file on focus lost
autocmd! FocusLost * silent! :wa

" automatically source .vimrc on save
autocmd! Bufwritepost .vimrc source $MYVIMRC

" remember last cursor position
autocmd! BufReadPost *
            \ if line("'\"") > 1 && line("'\"") <= line("$") |
            \     exe "normal! g`\"" |
            \ endif

" open help vertically
autocmd! FileType help wincmd L

" spell check for git commits
autocmd! FileType gitcommit setlocal spell

" resize panes when window resizes
autocmd! VimResized * :wincmd =

" prevent unintended write
autocmd BufReadPost fugitive:///*//0/* setlocal nomodifiable readonly

" only show cursor line in active window
augroup cusorlineToggle
    autocmd!
    autocmd InsertLeave,WinEnter * set cursorline
    autocmd InsertEnter,WinLeave * set nocursorline
augroup END

" load file when changed in disk
autocmd! FocusGained,BufEnter,CursorHold,CursorHoldI * if mode() != 'c' | checktime | endif
autocmd! FileChangedShellPost * echohl WarningMsg | echo "File changed on disk. Buffer reloaded." | echohl None

" enter insert mode when enter terminal emulator
autocmd! TermOpen,BufEnter,BufNew *
            \ if &buftype == 'terminal' |
            \     startinsert |
            \ endif

" ========== fugitive ==========

nnoremap <leader>gs :Gstatus<CR>
nnoremap <leader>gg :Glog<CR>
nnoremap <leader>gb :Gblame<CR>
vnoremap <leader>gb :Gblame<CR>
nnoremap <leader>gd :Gdiffsplit<CR>

nnoremap <leader>ga :Git add %:p<CR>
nnoremap <leader>gc :Gcommit -q<CR>
nnoremap <leader>gm :Gmerge<CR>
nnoremap <leader>gf :Gfetch<CR>
nnoremap <leader>gl :Gpull<CR>
nnoremap <leader>gp :Gpush<CR>

" ========== FZF ==========

nnoremap <C-p> :Files<CR>
nnoremap <leader>b :Buffers<CR>
nnoremap <leader>c :Commands<CR>
nnoremap <leader>M :Maps<CR>
nnoremap <leader>l :Lines<CR>
nnoremap <leader>L :BLines<CR>
nnoremap <leader>t :Filetypes<CR>
nnoremap <leader>/ :Rg<CR>

autocmd! FileType fzf
autocmd FileType fzf set laststatus=0 noruler nonumber norelativenumber |
            \ autocmd BufLeave <buffer> set laststatus=2 ruler

" ========== solarized ==========

let g:solarized_termcolors=256
colorscheme solarized
highlight CursorLineNr ctermbg=235

" ========== lightline ==========

set noshowmode

let g:lightline = {
            \   'active': {
            \     'left': [ [ 'mode', 'paste' ],
            \               [ 'readonly', 'filename', 'modified', 'gitbranch', 'cocstatus', 'currentfunction' ] ]
            \   },
            \   'component_function': {
            \     'gitbranch': 'FugitiveHead',
            \     'cocstatus': 'coc#status',
            \     'currentfunction': 'CocCurrentFunction'
            \   },
            \ }

" hide when lost focus
autocmd FocusGained * call setwinvar(winnr(), '&statusline', lightline#statusline(0))
autocmd FocusLost * call setwinvar(winnr(), '&statusline', lightline#statusline(1))

" ========== delimitMate ==========

let g:delimitMate_expand_cr = 1
let g:delimitMate_expand_space = 1

" ========== buftabline ==========

let g:buftabline_show = 1
let g:buftabline_numbers = 2
let g:buftabline_indicators = 1

for s:n in range(10)
    let s:b = s:n == 0 ? -1 : s:n
    execute printf("nmap <leader>%d <Plug>BufTabLine.Go(%d)", s:n, s:b)
endfor

" ========== tmux navigator ==========
let g:tmux_navigator_no_mappings = 1

nnoremap <silent> <C-w>h :TmuxNavigateLeft<cr>
nnoremap <silent> <C-w>j :TmuxNavigateDown<cr>
nnoremap <silent> <C-w>k :TmuxNavigateUp<cr>
nnoremap <silent> <C-w>l :TmuxNavigateRight<cr>

" ========== undotree ==========

nnoremap <silent><leader>u :UndotreeToggle<CR>

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
    imap <expr> <cr> pumvisible() ? coc#_select_confirm() : "\<Plug>delimitMateCR"
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

    " Highlight symbol under cursor on CursorHold
    autocmd CursorHold * silent call CocActionAsync('highlight')

    " Remap for rename current word
    nmap <leader>rn <Plug>(coc-rename)

    " Remap for format selected region
    xmap <leader>f <Plug>(coc-format-selected)
    nmap <leader>f <Plug>(coc-format-selected)

    augroup cochighlight
        autocmd!
        " Setup formatexpr specified filetype(s).
        autocmd FileType python,typescript,json setl formatexpr=CocAction('formatSelected')
        " Update signature help on jump placeholder
        autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
    augroup END

    " Add status line support, for integration with other plugin, checkout `:h coc-status`
    function! CocCurrentFunction()
        return get(b:, 'coc_current_function', '')
    endfunction
    
endif
