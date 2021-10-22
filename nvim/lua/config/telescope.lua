local config = {}

function config.before()
  local bind = require('utils.bind')

  bind.nmap_cmd('<C-p>', 'Telescope find_files')
  bind.nmap_cmd('<leader>/', 'Telescope live_grep')
  bind.nmap_cmd('<leader>fb', 'Telescope buffers')
  bind.nmap_cmd('<leader>fc', 'Telescope commands')
  bind.nmap_cmd('<leader>fq', 'Telescope quickfix')
  bind.nmap_cmd('<leader>ft', 'Telescope filetypes')
  bind.nmap_cmd('<leader>fy', 'Telescope neoclip')
  bind.nmap_cmd('<leader>fo', 'Telescope treesitter')
  bind.nmap_cmd('<leader>fr', 'Telescope frecency')
  bind.nmap_cmd('<leader>fh', 'Telescope help_tags')
end

function config.after()
  local telescope = require('telescope')

  telescope.setup({
    defaults = {
      sorting_strategy = 'ascending',
      layout_strategy = 'flex',
      layout_config = {
        horizontal = {
          prompt_position = 'top',
        },
        vertical = {
          prompt_position = 'top',
        },
      },
    },
  })
  telescope.load_extension('fzf')
  telescope.load_extension('frecency')
  telescope.load_extension('neoclip')
end

return config
