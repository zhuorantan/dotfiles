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

local function moveWindowToScreen(direction)
	return function()
		local win = hs.window.focusedWindow()
		if not win then
			return
		end

		local currentScreen = win:screen()
		if not currentScreen then
			return
		end

		local targetScreen
		if direction == "next" then
			targetScreen = currentScreen:next()
		else
			targetScreen = currentScreen:previous()
		end

		if not targetScreen then
			return
		end

		if not win:isFullScreen() then
			win:moveToScreen(targetScreen)
			return
		end

		-- Leave fullscreen before moving so the window can change displays, then restore it.
		win:setFullScreen(false)
		win:moveToScreen(targetScreen)
		hs.timer.doAfter(0.6, function()
			win:setFullScreen(true)
		end)
	end
end

function M.set_up()
	local hyperWithShift = { table.unpack(M.hyper) }
	hyperWithShift[#hyperWithShift + 1] = "shift"

	-- -- Application keybinding
	hs.hotkey.bind(M.hyper, "t", toggleApp("Ghostty"))
	hs.hotkey.bind(M.hyper, "s", toggleApp("Safari"))
	hs.hotkey.bind(M.hyper, "x", toggleApp("Xcode"))
	hs.hotkey.bind(M.hyper, "i", toggleApp("Mail"))
	hs.hotkey.bind(M.hyper, "2", toggleApp("Finder"))
	hs.hotkey.bind(M.hyper, "u", toggleApp("Telegram"))
	hs.hotkey.bind(M.hyper, "m", toggleApp("Messages"))
	hs.hotkey.bind(M.hyper, "w", toggleApp("WeChat"))
	hs.hotkey.bind(M.hyper, "0", toggleApp("Music"))
	hs.hotkey.bind(M.hyper, "4", toggleApp("Simulator"))

	hs.hotkey.bind(M.hyper, "o", toggleApp("Microsoft Outlook"))
	hs.hotkey.bind(M.hyper, "3", toggleApp("Slack"))

	hs.hotkey.bind(M.hyper, "return", function()
		local win = hs.window.focusedWindow()
		if win then
			win:maximize()
		end
	end)

	hs.hotkey.bind(hyperWithShift, "n", moveWindowToScreen("next"))
	hs.hotkey.bind(hyperWithShift, "p", moveWindowToScreen("previous"))

	-- Show desktop
	hs.hotkey.bind(M.hyper, "1", function()
		hs.spaces.toggleShowDesktop()
	end)

	-- Defeating paste blocking
	hs.hotkey.bind(M.hyper, "v", function()
		hs.eventtap.keyStrokes(hs.pasteboard.getContents())
	end)

	local has_envs, envs = pcall(require, "envs")
	if has_envs and envs.work_password then
		hs.hotkey.bind(M.hyper, "l", function()
			hs.eventtap.keyStrokes(envs.work_password)
			hs.eventtap.keyStroke({}, "return")
		end)
	end
end

return M
