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
Plug 'ryanoasis/vim-devicons'
Plug 'machakann/vim-highlightedyank'

" FZF
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'

" Git
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'
Plug 'junegunn/gv.vim'
Plug 'airblade/vim-gitgutter'

" LSP
Plug 'neovim/nvim-lspconfig'
Plug 'nvim-lua/lsp-status.nvim'

" Completion
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-vsnip'
Plug 'hrsh7th/vim-vsnip'
Plug 'windwp/nvim-autopairs'

call plug#end()

" ========== General ==========
:lua require('core')

set clipboard=unnamed

set exrc " read project sepecific vimrc
set secure

set updatetime=300

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

nnoremap <leader>gs :Git<CR>
nnoremap <leader>gg :Git log<CR>
nnoremap <leader>gb :Git blame<CR>
vnoremap <leader>gb :Git blame<CR>
nnoremap <leader>gd :Gdiffsplit<CR>

nnoremap <leader>ga :Git add %:p<CR>
nnoremap <leader>gc :Git commit -q<CR>
nnoremap <leader>gm :Git merge<CR>
nnoremap <leader>gf :Git fetch<CR>
nnoremap <leader>gl :Git pull<CR>
nnoremap <leader>gp :Git push<CR>

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
            \               [ 'readonly', 'filename', 'modified', 'gitbranch', 'cocstatus' ] ]
            \   },
            \   'component_function': {
            \     'gitbranch': 'FugitiveHead',
            \     'cocstatus': 'LspStatus',
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

let g:mkdp_auto_close = 0
nmap <leader>p <Plug>MarkdownPreviewToggle

" ========== gitgutter ==========
nmap [c <Plug>(GitGutterNextHunk)
nmap ]c <Plug>(GitGutterPrevHunk)

" ========== LSP ==========
hi default LspErrorSign     ctermfg=Red     guifg=#ff0000 guibg=NONE
hi default LspWarningSign   ctermfg=Brown   guifg=#ff922b guibg=NONE
hi default LspInfoSign      ctermfg=Yellow  guifg=#fab005 guibg=NONE
hi default LspHintSign      ctermfg=Blue    guifg=#15aabf guibg=NONE

sign define LspDiagnosticsSignError text=>> linehl= texthl=LspErrorSign numhl=LspErrorSign
sign define LspDiagnosticsSignWarning text=⚠  linehl= texthl=LspWarningSign numhl=LspWarningSign
sign define LspDiagnosticsSignInformation text=>> linehl= texthl=LspInfoSign numhl=LspInfoSign
sign define LspDiagnosticsSignHint text=>> linehl= texthl=LspHintSign numhl=LspHintSign

lua << EOF
local lsp_status = require('lsp-status')
-- completion_customize_lsp_label as used in completion-nvim
-- Optional: customize the kind labels used in identifying the current function.
-- g:completion_customize_lsp_label is a dict mapping from LSP symbol kind 
-- to the string you want to display as a label
-- lsp_status.config { kind_labels = vim.g.completion_customize_lsp_label }

-- Register the progress handler
lsp_status.register_progress()
-- Set default client capabilities plus window/workDoneProgress
-- config.capabilities = vim.tbl_extend('keep', config.capabilities or {}, lsp_status.capabilities)

local nvim_lsp = require('lspconfig')

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  -- Enable completion triggered by <c-x><c-o>
  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  local opts = { noremap=true, silent=true }

  -- See `:help vim.lsp.*` for documentation on any of the below functions
  buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
--  buf_set_keymap('n', '<leader>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
--  buf_set_keymap('n', '<leader>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
--  buf_set_keymap('n', '<leader>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  buf_set_keymap('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  buf_set_keymap('n', '<leader>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
  buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
  buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
  buf_set_keymap('n', '<leader>d', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
  buf_set_keymap('v', '<leader>f', '<cmd>lua vim.lsp.buf.range_formatting()<CR>', opts)
  buf_set_keymap('n', '<leader>f', '<cmd>lua vim.lsp.buf.range_formatting()<CR>', opts)
  buf_set_keymap('n', '<leader>F', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)

  -- Register client for messages and set up buffer autocommands to update 
  -- the statusline and the current function.
  -- NOTE: on_attach is called with the client object, which is the "client" parameter below
  lsp_status.on_attach(client)
end

-- Use a loop to conveniently call 'setup' on multiple servers and
-- map buffer local keybindings when the language server attaches
local servers = { 'clangd', 'cmake', 'cssls', 'dockerls', 'html', 'jsonls', 'solargraph', 'sourcekit', 'pyright', 'tsserver' }
for _, lsp in ipairs(servers) do
  nvim_lsp[lsp].setup {
    on_attach = on_attach,
    flags = {
      debounce_text_changes = 150,
    }
  }
end

nvim_lsp.diagnosticls.setup {
  filetypes = {"javascript", "typescript"},
  init_options = {
    linters = {
      eslint = {
        command = "./node_modules/.bin/eslint",
        rootPatterns = {".git"},
        debounce = 100,
        args = { 
          "--stdin",
          "--stdin-filename",
          "%filepath",
          "--format",
          "json"
        },
        sourceName = "eslint",
        parseJson = {
          errorsRoot = "[0].messages",
          line = "line",
          column = "column",
          endLine = "endLine",
          endColumn = "endColumn",
          message = "${message} [${ruleId}]",
          security = "severity"
        },
        securities = {
          [2] = "error",
          [1] = "warning"
        }
      }
    },
    filetypes = {
      javascript = "eslint",
      typescript = "eslint"
    },
  }
}
EOF

function! LspStatus() abort
  if luaeval('#vim.lsp.buf_get_clients() > 0')
    return luaeval("require('lsp-status').status()")
  endif

  return ''
endfunction

" ========== completion ==========
lua <<EOF
local cmp = require'cmp'
cmp.setup {
  snippet = {
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  mapping = {
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<C-c>'] = cmp.mapping.complete(),
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'buffer' },
    { name = 'path' },
  },
  completion = {
    completeopt = 'menu,menuone,noinsert',
  }
}

require('nvim-autopairs').setup{}
require('nvim-autopairs.completion.cmp').setup({
  map_cr = true, --  map <CR> on insert mode
  map_complete = true, -- it will auto insert `(` (map_char) after select function or method item
  auto_select = true, -- automatically select the first item
  insert = false, -- use insert confirm behavior instead of replace
  map_char = { -- modifies the function or method delimiter by filetypes
    all = '(',
    tex = '{'
  }
})
EOF
