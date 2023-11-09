local vim = vim

local function set_up_autocmd()
  vim.api.nvim_create_augroup('bufs', {})
  vim.api.nvim_create_autocmd('BufReadPost', {
    group = 'bufs',
    pattern = '*',
    desc = 'remember last cursor position',
    command = [[if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif]],
  })
  vim.api.nvim_create_autocmd('BufEnter', {
    group = 'bufs',
    pattern = '*',
    desc = 'open help vertically',
    command = [[if &filetype ==# 'help' | wincmd L | endif]],
  })
  vim.api.nvim_create_autocmd('FileType', {
    group = 'bufs',
    pattern = 'gitcommit,txt,markdown',
    desc = 'spell check for git commits and texts',
    command = [[setlocal spell]],
  })
  vim.api.nvim_create_autocmd('CursorHold', {
    group = 'bufs',
    pattern = '*',
    desc = 'refresh changed content of file',
    command = [[if getcmdwintype() == '' | checktime | endif]],
  })
  vim.api.nvim_create_autocmd('FileChangedShellPost', {
    group = 'bufs',
    pattern = '*',
    desc = 'refresh changed content of file',
    callback = function()
      vim.notify('File changed on disk. Buffer reloaded.', 'warn')
    end,
  })

  vim.api.nvim_create_augroup('wins', {})
  vim.api.nvim_create_autocmd('VimResized', {
    group = 'wins',
    pattern = '*',
    desc = 'resize panes when window resizes',
    command = [[:wincmd =]],
  })

  vim.api.nvim_create_augroup('visual', {})
  vim.api.nvim_create_autocmd({'InsertLeave', 'BufEnter', 'WinEnter'}, {
    group = 'visual',
    pattern = '*',
    desc = 'only show cursor line in active window',
    command = [[set cursorline]],
  })
  vim.api.nvim_create_autocmd({'InsertEnter', 'BufLeave', 'WinLeave'}, {
    group = 'visual',
    pattern = '*',
    desc = 'only show cursor line in active window',
    command = [[set nocursorline]],
  })
  vim.api.nvim_create_autocmd('TextYankPost', {
    group = 'visual',
    pattern = '*',
    desc = 'highlight yank',
    callback = function()
      vim.highlight.on_yank({ timeout = 500 })
    end,
  })

  vim.api.nvim_create_augroup('terminal', {})
  vim.api.nvim_create_autocmd('TermOpen', {
    group = 'terminal',
    pattern = '*',
    desc = 'termianl mode Esc map',
    callback = function()
      vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]], { buffer = true })
    end,
  })
end

set_up_autocmd()
