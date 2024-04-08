local hs = hs

local M = {}

M.hyper = { "cmd", "ctrl" }

local function toggleApp(name)
	return function()
		local app = hs.application.find(name)

		if app and hs.application.frontmostApplication() == app and next(app:visibleWindows()) ~= nil then
			app:hide()
		else
			hs.application.launchOrFocus(name)
		end
	end
end

local function bind_window_management(hyper)
	local window = require("window.window")

	hs.hotkey.bind(hyper, "return", window.fullScreen)
	hs.hotkey.bind(hyper, "c", window.moveCenter)
	hs.hotkey.bind(hyper, "h", window.moveLeft)
	hs.hotkey.bind(hyper, "j", window.moveDown)
	hs.hotkey.bind(hyper, "k", window.moveUp)
	hs.hotkey.bind(hyper, "l", window.moveRight)

	hs.hotkey.bind({ "cmd", "ctrl", "shift" }, "p", window.movePrevScreen)
	hs.hotkey.bind({ "cmd", "ctrl", "shift" }, "n", window.moveNextScreen)
	hs.hotkey.bind({ "cmd", "ctrl", "shift" }, "h", window.resizeLeft)
	hs.hotkey.bind({ "cmd", "ctrl", "shift" }, "j", window.resizeDown)
	hs.hotkey.bind({ "cmd", "ctrl", "shift" }, "k", window.resizeUp)
	hs.hotkey.bind({ "cmd", "ctrl", "shift" }, "l", window.resizeRight)
end

function M.set_up()
	local apps = require("apps")
	local layoutApps = require("layouts")

	-- Application keybinding
	hs.hotkey.bind(M.hyper, "t", toggleApp("Alacritty"))
	hs.hotkey.bind(M.hyper, "x", toggleApp(apps.xcodeAppName))
	hs.hotkey.bind(M.hyper, "s", toggleApp(apps.browserAppName))
	hs.hotkey.bind(M.hyper, "5", toggleApp("Finder"))
	hs.hotkey.bind(M.hyper, "4", toggleApp("Mail"))
	hs.hotkey.bind(M.hyper, "u", toggleApp("Telegram"))
	hs.hotkey.bind(M.hyper, "m", toggleApp("Messages"))
	hs.hotkey.bind(M.hyper, "w", toggleApp("WeChat"))
	hs.hotkey.bind(M.hyper, "0", toggleApp("Music"))
	hs.hotkey.bind(M.hyper, "2", toggleApp("Simulator"))

	hs.hotkey.bind(M.hyper, "o", toggleApp("Microsoft Outlook"))
	hs.hotkey.bind(M.hyper, "3", toggleApp("Microsoft Teams"))

	-- Show desktop
	hs.hotkey.bind(M.hyper, "1", function()
		hs.eventtap.keyStroke({ "fn" }, "f11")
	end)

	-- Defeating paste blocking
	hs.hotkey.bind(M.hyper, "v", function()
		hs.eventtap.keyStrokes(hs.pasteboard.getContents())
	end)

	-- Music
	hs.hotkey.bind(M.hyper, "p", hs.itunes.playpause)
	hs.hotkey.bind(M.hyper, "]", hs.itunes.next)
	hs.hotkey.bind(M.hyper, "[", hs.itunes.previous)

	-- Layout
	hs.hotkey.bind(M.hyper, "'", layoutApps)

	bind_window_management(M.hyper)
end

return M
