-- Started from init.lua as a separate rex do script so events stay subscribed.
local history = require("tab_history")
require("repeat_keys").watch()
local state = history.read()
local function view(session_id)
	return assert(rex.call("session.view", { session_id = session_id }))
end

rex.on("active_window_changed", function(ctx, event)
	if history.observe(state, ctx.session_id, event.window_id) then history.write(state) end
end)
rex.on("window_closed", function(ctx)
	history.prune(state, ctx.session_id, view(ctx.session_id))
	history.write(state)
end)
rex.on("session_created", function(_, event)
	local id = event.session.session_id
	history.observe(state, id, view(id).active_window_id)
	history.write(state)
end)
rex.on("session_destroyed", function(_, event)
	state[event.session_id] = nil
	history.write(state)
end)

-- Only structural/session events are needed; don't subscribe to terminal output.
local sessions = assert(rex.call("session.attach_all", { event_scope = "session" })).sessions or {}
local existing = {}
for _, session in ipairs(sessions) do
	local id = session.session_id
	existing[id] = true
	local current = view(id)
	history.prune(state, id, current)
	history.observe(state, id, current.active_window_id)
end
for id in pairs(state) do if not existing[id] then state[id] = nil end end
history.write(state)
