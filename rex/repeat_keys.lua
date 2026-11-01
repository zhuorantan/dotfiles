-- Rex has key modes but no mode timeout. Share expiry requests with the
-- existing event listener; keep each app's repeat window independent.
local history = require("tab_history")
local M = {}
local path = history.path:gsub("tab%-history.json$", "repeat-keys.json")
local timeout = 0.5
local mode = "tmux_repeat"

local function request(client_id, active)
	assert(client_id, "Timed repeats require a Rex app")
	local requests = history.read(path)
	local previous = requests[client_id] or {}
	requests[client_id] = { sequence = (previous.sequence or 0) + 1, active = active }
	history.write(requests, path)
end

function M.install(prefix)
	for _, binding in ipairs({
		{ "shift+h", "resize_left", "pane.resize", { direction = "left", amount = 5 } },
		{ "shift+j", "resize_down", "pane.resize", { direction = "down", amount = 5 } },
		{ "shift+k", "resize_up", "pane.resize", { direction = "up", amount = 5 } },
		{ "shift+l", "resize_right", "pane.resize", { direction = "right", amount = 5 } },
		{ "ctrl+h", "tab_previous", "client.tab.previous" },
		{ "ctrl+l", "tab_next", "client.tab.next" },
	}) do
		local key, name, action, args = binding[1], binding[2], binding[3], binding[4]
		name = "repeat_" .. name
		rex.action({
			name = name,
			title = "Repeat " .. name:gsub("^repeat_", ""):gsub("_", " "),
			category = "Navigation",
			repeats = true,
			run = function(ctx)
				request(ctx.client_id, true)
				rex.client.queue(action, args)
				-- The previous one-shot mode is consumed before this action runs.
				rex.client.queue("client.mode.enter", { name = mode, once = true })
			end,
		})
		rex.bind(prefix .. ">" .. key, name)
		rex.bind(mode .. "/" .. key, name)
		-- Repeating the prefix must also consume the previous mode.
		rex.bind(mode .. "/" .. prefix .. ">" .. key, name)
	end
	rex.action({
		name = "repeat_cancel",
		title = "Cancel Repeat Keys",
		category = "Navigation",
		run = function(ctx)
			request(ctx.client_id, false)
		end,
	})
	rex.bind(mode .. "/escape", "repeat_cancel")
end

function M.watch()
	local seen, timers = {}, {}
	return rex.every(0.025, function()
		for client_id, request in pairs(history.read(path)) do
			if seen[client_id] ~= request.sequence then
				seen[client_id] = request.sequence
				if timers[client_id] then timers[client_id]:cancel() end
				timers[client_id] = nil
				if request.active then
					local sequence = request.sequence
					timers[client_id] = rex.after(timeout, function()
						timers[client_id] = nil
						local current = history.read(path)[client_id]
						-- A repeat may arrive between polling and this callback.
						if current and current.active and current.sequence == sequence then
							-- Disconnected apps are harmless; keep the listener alive.
							rex.call("client.perform", { client_id = client_id, action = "client.mode.exit" })
						end
					end)
				end
			end
		end
	end)
end

return M
