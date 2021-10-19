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

    -- spell check for git commits
    [[FileType gitcommit setlocal spell]],

    -- refresh changed content of file
    [[CursorHold * if getcmdwintype() == '' | checktime | endif]],
    [[FileChangedShellPost * echohl WarningMsg | echom "Warning: File changed on disk. Buffer reloaded." | echohl None]],
  },
  wins = {
    -- resize panes when window resizes
    [[VimResized * :wincmd =]],
  },
  visual = {
    -- only show cursor line in active window
    [[InsertLeave,WinEnter * set cursorline]],
    [[InsertEnter,WinLeave * set nocursorline]],
  },
  terminal = {
    -- termianl mode Esc map
    [[TermOpen * tnoremap <buffer> <Esc> <C-\><C-n>]],

    -- enter insert mode when enter terminal emulator
    [[TermOpen,BufEnter,BufNew * if &buftype == 'terminal' | startinsert | endif]],
  },
}

enable_augroups(groups)
