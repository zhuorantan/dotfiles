local hs = hs

-- config
hs.window.animationDuration = 0

require('config_auto_load')
require('keybindings').set_up()
require('layouts')()
