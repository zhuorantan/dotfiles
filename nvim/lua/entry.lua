local vim = vim
local disable_builtin_plugins = require('utils.disable_builtin_plugins')

disable_builtin_plugins()
require('options')
require('keybindings')
require('commands')
require('events')
