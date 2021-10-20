" ========== plugins ==========
call plug#begin('~/.local/share/nvim/site/plugged')

" Vim enhancements
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
:lua require('entry')

" ========== keymaps ==========

nnoremap <silent><leader>q :Sayonara<CR>
nnoremap <silent><leader>Q :Sayonara!<CR>

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
" nmap <leader>p <Plug>MarkdownPreviewToggle

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
