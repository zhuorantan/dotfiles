-- ### Advanced Microphone Mute Module ###
--
-- Provides a tap-to-toggle and hold-to-talk functionality for the microphone,
-- controlled by a configurable hotkey.
--
-- To use, require this file and call the `init` function from your main `init.lua`:
-- local micMute = require("micMute")
-- micMute.setUp({"cmd", "shift", "ctrl"}, "m")

local hs = hs

local M = {}

-- ## Initialization Function ##
-- Takes the hotkey combination as input and sets everything up.
-- @param mods A table of modifier keys, e.g., {"cmd", "shift"}
-- @param key A string for the key, e.g., "m"
function M.set_up(mods, key)
	local mic = hs.audiodevice.defaultInputDevice()

	-- Configuration for the hotkey behavior
	local micMuteMenuBar = nil

	local function getMicMuted()
		return mic:inputVolume() == 0
	end

	local function setMicMuted(muted)
		mic:setInputVolume(muted and 0 or 100)
	end

	local function setMicMuteMenuBar(muted)
		if muted then
			micMuteMenuBar = hs.menubar.new()
			micMuteMenuBar:setTitle("📵")
			micMuteMenuBar:setTooltip("Mic is muted")
			micMuteMenuBar:setClickCallback(function()
				setMicMuted(false)
				setMicMuteMenuBar(false)
			end)
		elseif micMuteMenuBar then
			micMuteMenuBar:delete()
			micMuteMenuBar = nil
		end
	end

	-- Bind the hotkey with tap-vs-hold logic using the provided key combo
	hs.hotkey.bind(mods, key, function()
		local muted = getMicMuted()
		setMicMuted(not muted)
		setMicMuteMenuBar(not muted)
	end)

	hs.audiodevice.watcher.setCallback(function(arg)
		if not string.find(arg, "dIn ") then
			return
		end

		local new_mic = hs.audiodevice.defaultInputDevice()
		if new_mic:uid() ~= mic:uid() then
			mic = new_mic

			setMicMuteMenuBar(getMicMuted())
		end
	end)
	hs.audiodevice.watcher.start()

	setMicMuteMenuBar(getMicMuted())
end

return M
