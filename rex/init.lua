local rex = rex
local prefix = "ctrl+a"

local function select_window(ctx, window_id)
	local args = { session_id = ctx.session_id, window_id = window_id }
	if ctx.server and ctx.server ~= "" then
		-- Queued actions run on the home connection. Select remote tabs through
		-- the app's connection to the server that owns this session instead.
		local attachment = assert(rex.call("session.attach", { session_id = ctx.session_id }))
		local client_id = assert(attachment.client_id, "Cannot identify the originating app on the remote server")
		assert(rex.call("client.perform", {
			client_id = client_id, session_id = ctx.session_id, action = "session.select", args = args,
		}))
	else
		rex.client.queue("session.select", args)
	end
end

-- Match the pane and window shortcuts in ../tmux/tmux.conf.
-- Press Ctrl+A, release it, then press the second key. Escape cancels.
rex.bind(prefix .. ">" .. prefix, "pane.send_key", { key = prefix })

-- Sessions.
rex.bind(prefix .. ">ctrl+c", "session.new")
rex.bind(prefix .. ">shift+x", "session.close")
rex.bind(prefix .. ">ctrl+j", "session.next")
rex.bind(prefix .. ">ctrl+k", "session.previous")

-- Splits: lowercase creates after the current pane; uppercase creates before.
rex.bind(prefix .. ">s", "pane.split", { direction = "down" })
rex.bind(prefix .. ">shift+s", "pane.split", { direction = "up" })
rex.bind(prefix .. ">v", "pane.split", { direction = "right" })
rex.bind(prefix .. ">shift+v", "pane.split", { direction = "left" })

-- Focus panes with vi keys.
rex.bind(prefix .. ">h", "pane.focus", { direction = "left" })
rex.bind(prefix .. ">j", "pane.focus", { direction = "down" })
rex.bind(prefix .. ">k", "pane.focus", { direction = "up" })
rex.bind(prefix .. ">l", "pane.focus", { direction = "right" })

-- Rex moves dividers by percentage, whereas tmux uses terminal cells.
-- Resize and previous/next tab keys repeat for 500 ms without another prefix.
require("repeat_keys").install(prefix)

rex.bind(prefix .. ">z", "pane.zoom")
rex.bind(prefix .. ">x", "pane.close")

-- Select tabs in the current session: 1–9, then 0 for the tenth tab.
for index = 1, 10 do
	local name = "session_tab_" .. index
	rex.action({
		name = name,
		title = "Go to Session Tab " .. index,
		category = "Navigation",
		run = function(ctx)
			local view = assert(rex.session.view({ session_id = ctx.session_id }))
			local target = (view.windows or {})[index]
			if target then
				select_window(ctx, target.window_id)
			end
		end,
	})
	rex.bind(prefix .. ">" .. (index % 10), name)
end

local tab_history = require("tab_history")
-- Keep listening for native tab changes between shortcut invocations. The
-- launcher holds a file lock, so config reloads don't create extra listeners.
local config_dir = (os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config")) .. "/rex"
assert(rex.exec.start({ "/bin/sh", config_dir .. "/watch-tabs" }, { detach = true, stdout = false, stderr = false }))
rex.action({
	name = "last_tab",
	title = "Switch to Last Used Tab",
	category = "Navigation",
	run = function(ctx)
		local view = assert(rex.session.view({}))
		local target = tab_history.previous(tab_history.read(), ctx.session_id, view, ctx.block_id)
		if target then
			select_window(ctx, target)
		end
	end,
})
rex.bind(prefix .. ">tab", "last_tab")

rex.bind(prefix .. ">r", "client.config.reload")

-- Use the foreground process's directory, including while an editor is open.
local function current_directory(ctx)
	local process = assert(rex.block.call("com.superlogical.terminal", "process", { block_id = ctx.block_id }))
	local cwd = (process.foreground and process.foreground.cwd) or (process.child and process.child.cwd)
	assert(cwd and cwd ~= "", "Cannot determine the current pane's directory")
	return cwd
end

local function terminal_in_current_directory(ctx, command)
	return rex.layout.block({ flavor = "com.superlogical.terminal.shell",
		options = { cwd = current_directory(ctx), command = command } })
end

rex.action({
	name = "lazygit",
	title = "Open Lazygit",
	category = "Tools",
	run = function(ctx)
		return assert(rex.session.new_layer({
			bounds = { 0.05, 0.05, 0.9, 0.9 },
			focus = true,
			layout = terminal_in_current_directory(ctx, { "lazygit" }),
		}))
	end,
})
rex.bind(prefix .. ">g", "lazygit")

rex.action({
	name = "yazi",
	title = "Open Yazi",
	category = "Tools",
	run = function(ctx)
		local created = assert(rex.session.new_window({
			focus = true,
			-- The y wrapper keeps Yazi's chosen directory when returning to a shell.
			layout = terminal_in_current_directory(ctx, { "zsh", "-ic", "y; exec zsh" }),
		}))
		-- Server focus alone doesn't select the tab in the originating app.
		select_window(ctx, created.window_id)
		return created
	end,
})
rex.bind(prefix .. ">y", "yazi")

-- fzf pickers run inside Rex terminals; pass the originating app explicitly.
local pickers = require("picker")
rex.action({
	name = "yazi_here",
	title = "Open Yazi in Current Pane",
	category = "Tools",
	run = function(ctx)
		return pickers.replace_pane(ctx.session_id, ctx.block_id, current_directory(ctx), pickers.yazi)
	end,
})
rex.bind(prefix .. ">shift+y", "yazi_here")

for _, picker in ipairs({
	{ name = "sessions", title = "Switch Session or Project", key = "space" },
	{ name = "worktrees", title = "Switch Git Worktree", key = "ctrl+w" },
}) do
	rex.action({
		name = picker.name,
		title = picker.title,
		category = "Navigation",
		run = function(ctx)
			assert(ctx.client_id, "A Rex app is required to open the picker")
			return assert(rex.session.new_layer({
				bounds = { 0.1, 0.1, 0.8, 0.8 },
				focus = true,
				layout = pickers.picker_layout(picker.name, ctx),
			}))
		end,
	})
	rex.bind(prefix .. ">" .. picker.key, picker.name)
end

-- Keep Rex's font, theme, and other app preferences in Settings.
