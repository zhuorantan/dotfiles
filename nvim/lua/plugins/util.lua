return {
  {
    "tpope/vim-dispatch",
    cmd = { "Dispatch", "Make", "Focus", "Start" },
    init = function()
      vim.g.dispatch_no_maps = 1
      vim.g.dispatch_no_tmux_make = 1
    end,
  },
}
