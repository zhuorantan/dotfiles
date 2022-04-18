#!/bin/sh

osascript <<'END'
use framework "AppKit"
use scripting additions

set icon to "https://github.com/bouk/alacritty/blob/604686ba061c714f37d1db7002258517f062f0d2/extra/osx/Alacritty.app/Contents/Resources/alacritty.icns?raw=true"

set iconURL to current application's NSURL's URLWithString:icon
set iconImage to (current application's NSImage's alloc)'s initWithContentsOfURL:iconURL

set workspace to current application's NSWorkspace's sharedWorkspace()
workspace's setIcon:iconImage forFile:"/Applications/Alacritty.app" options:0
END
