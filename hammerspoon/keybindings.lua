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

function M.set_up()
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

	-- Show desktop
	hs.hotkey.bind(M.hyper, "1", function()
		hs.eventtap.keyStroke({ "fn" }, "f11")
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
