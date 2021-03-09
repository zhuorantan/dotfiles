" ========== plugins ==========
call plug#begin('~/.local/share/nvim/site/plugged')

" Vim enhancements
Plug 'mhinz/vim-sayonara', { 'on': 'Sayonara' }
Plug 'mbbill/undotree', {'on': 'UndotreeToggle'}
Plug 'thalesmello/tabfold'
Plug 'preservim/nerdtree', { 'on': 'NERDTreeFind' }

Plug 'tpope/vim-dispatch'

Plug 'sheerun/vim-polyglot'
Plug 'ap/vim-buftabline'

" Edit enchancements
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-sleuth' " auto change shiftwidth
Plug 'raimondi/delimitmate'
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}

" UI
Plug 'altercation/vim-colors-solarized'
Plug 'itchyny/lightline.vim'

" FZF
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'

" Git
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'
Plug 'junegunn/gv.vim'

" COC
Plug 'neoclide/coc.nvim', {'branch': 'release'}

call plug#end()

" ========== General ==========

set clipboard=unnamed

set undofile
set autowrite
set inccommand=nosplit

set mouse=nvi

set foldmethod=indent
set foldlevelstart=99 " start file with all folds opened

set cursorline

set hidden

set scrolloff=1
set sidescrolloff=5

set exrc " read project sepecific vimrc
set secure

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
let mapleader = "\<Space>"

nnoremap <Space> <Nop>
nnoremap <silent><leader><C-h> :bprevious<CR>
nnoremap <silent><leader><C-l> :bnext<CR>
nnoremap <silent><leader><Space> zz:nohlsearch<CR>
nnoremap <silent><leader>w :w<CR>
nnoremap <silent><leader>q :Sayonara<CR>
nnoremap <silent><leader>Q :Sayonara!<CR>
nnoremap <silent><leader>N :enew<CR>
nnoremap <leader><Tab> <C-^>

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
let NERDTreeShowHidden = 1
let NERDTreeQuitOnOpen = 1
let NERDTreeAutoDeleteBuffer = 1
let NERDTreeIgnore=['\.vim$', '\~$', '\.git$', '.DS_Store']
nnoremap <silent><Leader>n :call <SID>nerdtreeToggle()<CR>

" close vim if the only window left open is a NERDTree
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" ========== auto ==========

" save file on focus lost
autocmd! FocusLost * silent! :wa

" remember last cursor position
autocmd! BufReadPost *
            \ if line("'\"") > 1 && line("'\"") <= line("$") |
            \     exe "normal! g`\"" |
            \ endif

" open help vertically
autocmd BufEnter * if &filetype ==# 'help' | wincmd L | endif

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

 " refresh changed content of file
autocmd CursorHold * if getcmdwintype() == '' | checktime | endif
autocmd FileChangedShellPost * echohl WarningMsg | echom "Warning: File changed on disk. Buffer reloaded." | echohl None

augroup terminal
    autocmd!

    " termianl mode Esc map
    autocmd TermOpen * tnoremap <buffer> <Esc> <C-\><C-n>

    " enter insert mode when enter terminal emulator
    autocmd TermOpen,BufEnter,BufNew *
                \ if &buftype == 'terminal' |
                \     startinsert |
                \ endif
augroup END

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

nnoremap <leader>gv :GV --all<CR>
nnoremap <leader>gV :GV<CR>

" ========== FZF ==========

let g:fzf_layout = { 'window': { 'width': 0.9, 'height': 0.6 } }

nnoremap <C-p> :Files<CR>
nnoremap <leader>b :Buffers<CR>
nnoremap <leader>c :Commands<CR>
nnoremap <leader>M :Maps<CR>
nnoremap <leader>l :Lines<CR>
nnoremap <leader>L :BLines<CR>
nnoremap <leader>t :Filetypes<CR>
nnoremap <leader>/ :Rg<CR>

autocmd! FileType fzf tunmap <buffer> <Esc>

" ========== solarized ==========

let g:solarized_termcolors=256
colorscheme solarized
highlight CursorLineNr ctermbg=235
highlight SignColumn ctermbg=235

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

" ========== buftabline ==========

let g:buftabline_show = 1
let g:buftabline_numbers = 2
let g:buftabline_indicators = 1

for s:n in range(10)
    let s:b = s:n == 0 ? -1 : s:n
    execute printf("nmap <leader>%d <Plug>BufTabLine.Go(%d)", s:n, s:b)
endfor

" ========== undotree ==========

nnoremap <silent><leader>u :UndotreeToggle<CR>

" ========== dispatch ==========

let g:dispatch_no_maps = 1
let g:dispatch_no_tmux_make = 1

" ========== markdown preview ==========

nmap <leader>p <Plug>MarkdownPreviewToggle

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

    " Use <cr> to confirm completion, `<C-g>u` means break undo chain at current
    " position. Coc only does snippet and additional edit on confirm.
    inoremap <expr> <cr> pumvisible() ? coc#_select_confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
    
    " Use `[g` and `]g` to navigate diagnostics
    nmap <silent> [g <Plug>(coc-diagnostic-prev)
    nmap <silent> ]g <Plug>(coc-diagnostic-next)

    " Remap keys for gotos
    nmap <silent> gd <Plug>(coc-definition)
    nmap <silent> gy <Plug>(coc-type-definition)
    nmap <silent> gi <Plug>(coc-implementation)
    nmap <silent> gr <Plug>(coc-references)

    " navigate chunks of current buffer
    nmap [c <Plug>(coc-git-prevchunk)
    nmap ]c <Plug>(coc-git-nextchunk)

    " Use K to show documentation in preview window
    nnoremap <silent> K :call <SID>show_documentation()<CR>

    function! s:show_documentation()
        if (index(['vim','help'], &filetype) >= 0)
            execute 'h '.expand('<cword>')
        else
            call CocAction('doHover')
        endif
    endfunction

    let g:coc_global_extensions = ['coc-git', 'coc-snippets', 'coc-python', 'coc-solargraph', 'coc-tsserver', 'coc-eslint', 'coc-pairs', 'coc-json', 'coc-yank', 'coc-css']

    " Highlight symbol under cursor on CursorHold
    autocmd CursorHold * silent call CocActionAsync('highlight')

    " Remap for rename current word
    nmap <leader>rn <Plug>(coc-rename)

    " Remap for format selected region
    xmap <leader>f <Plug>(coc-format-selected)
    nmap <leader>f <Plug>(coc-format-selected)
    nmap <leader>F <Plug>(coc-format)

    augroup cochighlight
        autocmd!
        " Setup formatexpr specified filetype(s).
        autocmd FileType python,typescript,json setl formatexpr=CocAction('formatSelected')
        " Update signature help on jump placeholder
        autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
    augroup END

    " Applying codeAction to the selected region.
    " Example: `<leader>aap` for current paragraph
    xmap <leader>a  <Plug>(coc-codeaction-selected)
    nmap <leader>a  <Plug>(coc-codeaction-selected)

    " Remap keys for applying codeAction to the current line.
    nmap <leader>ac  <Plug>(coc-codeaction)
    " Apply AutoFix to problem on the current line.
    nmap <leader>gq  <Plug>(coc-fix-current)

    " Introduce function text object
    " NOTE: Requires 'textDocument.documentSymbol' support from the language server.
    xmap if <Plug>(coc-funcobj-i)
    xmap af <Plug>(coc-funcobj-a)
    omap if <Plug>(coc-funcobj-i)
    omap af <Plug>(coc-funcobj-a)

    " Add status line support, for integration with other plugin, checkout `:h coc-status`
    function! CocCurrentFunction()
        return get(b:, 'coc_current_function', '')
    endfunction
    
endif
