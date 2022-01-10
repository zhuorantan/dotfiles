local autocmd = require('utils.autocmd')

local function enable_augroups(augroups)
  for name, commands in pairs(augroups) do
    autocmd.create_augroup(name, commands)
  end
end

local groups = {
  bufs = {
    -- remember last cursor position
    [[BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif]],

    -- open help vertically
    [[BufEnter * if &filetype ==# 'help' | wincmd L | endif]],

    -- spell check for git commits and texts
    [[FileType gitcommit,txt,markdown setlocal spell]],

    -- refresh changed content of file
    [[CursorHold * if getcmdwintype() == '' | checktime | endif]],
    [[FileChangedShellPost * echohl WarningMsg | echom "Warning: File changed on disk. Buffer reloaded." | echohl None]],

    [[CursorHold,CursorHoldI * lua vim.lsp.buf.document_highlight()]],
    [[CursorMoved * lua vim.lsp.buf.clear_references()]],
  },
  wins = {
    -- resize panes when window resizes
    [[VimResized * :wincmd =]],
  },
  visual = {
    -- only show cursor line in active window
    [[InsertLeave,BufEnter,WinEnter * set cursorline]],
    [[InsertEnter,BufLeave,WinLeave * set nocursorline]],

    -- highlight yank
    [[TextYankPost * silent! lua vim.highlight.on_yank({ timeout = 500 })]],
  },
  terminal = {
    -- termianl mode Esc map
    [[TermOpen * tnoremap <buffer> <Esc> <C-\><C-n>]],
  },
}

enable_augroups(groups)
