-- Shared by the event watcher and the prefix-Tab action. History belongs to a
-- Rex session, like tmux's last-window, and uses IDs rather than tab positions.
local M = {}
M.path = (os.getenv("XDG_STATE_HOME") or (os.getenv("HOME") .. "/.local/state")) .. "/rex/tab-history.json"

function M.read(path)
	local file = io.open(path or M.path, "r")
	if not file then return {} end
	local data = file:read("*a")
	file:close()
	local history = rex.json.decode(data)
	return type(history) == "table" and history or {}
end

function M.write(history, path)
	path = path or M.path
	local file = assert(io.open(path .. ".tmp", "w"))
	assert(file:write(assert(rex.json.encode(history))))
	assert(file:close())
	assert(os.rename(path .. ".tmp", path))
end

function M.observe(history, session_id, window_id)
	if not window_id then return false end
	local windows = history[session_id] or {}
	if windows[1] == window_id then return false end
	for index = #windows, 1, -1 do
		if windows[index] == window_id then table.remove(windows, index) end
	end
	table.insert(windows, 1, window_id)
	history[session_id] = windows
	return true
end

function M.prune(history, session_id, view)
	local valid = {}
	for _, window in ipairs(view.windows or {}) do valid[window.window_id] = true end
	local kept = {}
	for _, id in ipairs(history[session_id] or {}) do
		if valid[id] then table.insert(kept, id) end
	end
	history[session_id] = kept
end

function M.previous(history, session_id, view, block_id)
	-- The invoking pane identifies the app's visible tab even when another
	-- client or an automation changed the server's active window.
	local current = view.active_window_id
	for _, window in ipairs(view.windows or {}) do
		for _, layer in ipairs(window.layers or {}) do
			for _, block in ipairs(layer.blocks or {}) do
				if block.block_id == block_id then current = window.window_id end
			end
		end
	end
	M.prune(history, session_id, view)
	for _, id in ipairs(history[session_id] or {}) do
		if id ~= current then return id end
	end
end

return M
