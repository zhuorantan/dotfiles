local M = {}

function M.before()
  local bind = require('utils.bind')
  local autocmd = require('utils.autocmd')

  bind.nmap_cmd('<C-p>', [[lua require('fzf-lua').files()]])
  bind.nmap_cmd('<leader><C-p>', [[lua require('fzf-lua').files({ fd_opts = '--color never --type f --hidden --follow --no-ignore' })]])
  bind.nmap_cmd('<leader>/', [[lua require('fzf-lua').live_grep()]])
  bind.xmap_cmd('<leader>/', [[lua require('fzf-lua').grep_visual()]])
  bind.nmap_cmd('<leader>?', [[lua require('fzf-lua').live_grep_resume()]])
  bind.nmap_cmd('<leader>fw', [[lua require('fzf-lua').grep_cword()]])
  bind.nmap_cmd('<leader>fb', [[lua require('fzf-lua').buffers()]])
  bind.nmap_cmd('<leader>fc', [[lua require('fzf-lua').commands()]])
  bind.nmap_cmd('<leader>fq', [[lua require('fzf-lua').quickfix()]])
  bind.nmap_cmd('<leader>ft', [[lua require('fzf-lua').filetypes()]])
  bind.nmap_cmd('<leader>fr', [[lua require('fzf-lua').registers()]])
  bind.nmap_cmd('<leader>fh', [[lua require('fzf-lua').help_tags()]])

  bind.nmap_cmd('<leader>fs', [[lua require('fzf-lua').git_status()]])
  bind.nmap_cmd('<leader>fg', [[lua require('fzf-lua').git_branches()]])

  autocmd.create_augroup('fzf', {
    [[FileType fzf tunmap <buffer> <esc>]],
  })
end

function M.after()
  local fzf = require('fzf-lua')

  fzf.setup({})
end

return M
