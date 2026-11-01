-- fzf pickers driven by Rex's Lua runtime. Also loaded by init.lua.
local rex = rex
local M = {}
local config_dir = (os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config")) .. "/rex"
local script = config_dir .. "/picker.lua"
local home = os.getenv("HOME")

local function exec(argv, options)
	return assert(rex.exec(argv, options))
end

local function checked(result)
	assert(result.ok, result.stderr ~= "" and result.stderr or result.stdout)
	return result.stdout
end

local function split(text, separator)
	local values, start = {}, 1
	while true do
		local first, last = text:find(separator, start, true)
		if not first then
			table.insert(values, text:sub(start))
			return values
		end
		table.insert(values, text:sub(start, first - 1))
		start = last + 1
	end
end

local function lines(text)
	local values = {}
	for _, line in ipairs(split(text, "\n")) do
		if line ~= "" then table.insert(values, line) end
	end
	return values
end

local function basename(directory)
	return directory:match("([^/]+)/*$") or "/"
end

local function canonical(directory)
	return (checked(exec({ "realpath", "--", directory })):gsub("\n$", ""))
end

local function is_directory(directory)
	return exec({ "test", "-d", directory }).ok
end

-- Normalize and filter directory lists in one subprocess rather than one per row.
local function directories(candidates)
	local argv = { "sh", "-c", 'for directory do if [ -d "$directory" ]; then (cd -- "$directory" && pwd -P); fi; done', "sh" }
	for _, directory in ipairs(candidates) do table.insert(argv, directory) end
	return lines(checked(exec(argv)))
end

local function git(directory, ...)
	local argv = { "git", "--no-optional-locks", "-C", directory }
	for _, argument in ipairs({ ... }) do table.insert(argv, argument) end
	return exec(argv)
end

local attached = {}
local function api(method, args)
	-- Unlike one-shot CLI calls, a Lua script keeps a control stream open.
	local session_id = args and args.session_id
	if session_id and not attached[session_id] then
		assert(rex.call("session.attach", { session_id = session_id }))
		attached[session_id] = true
	end
	return assert(rex.call(method, args or {}))
end

local executable
local function cli()
	if executable then return executable end
	local found = exec({ "sh", "-c", "command -v rex" })
	if found.ok then
		executable = found.stdout:gsub("\n$", "")
	else
		for _, app in ipairs({ "Rex Beta.app", "Rex.app" }) do
			local candidate = "/Applications/" .. app .. "/Contents/Helpers/Rex Server.rex/Contents/MacOS/rex"
			if exec({ "test", "-x", candidate }).ok then
				executable = candidate
				break
			end
		end
	end
	return assert(executable, "Cannot find the Rex CLI")
end

local function command(kind, ctx, directory)
	return { cli(), "do", script, "action=pick", "kind=" .. kind,
		"session_id=" .. ctx.session_id, "client_id=" .. ctx.client_id,
		"origin_block_id=" .. ctx.block_id, "directory=" .. directory }
end

local function shell_quote(value)
	return "'" .. value:gsub("'", "'\\''") .. "'"
end

local function helper(action, args)
	local argv = { cli(), "do", script, "action=" .. action }
	for key, value in pairs(args or {}) do table.insert(argv, key .. "=" .. value) end
	for index, value in ipairs(argv) do argv[index] = shell_quote(value) end
	return table.concat(argv, " ")
end

local function clean_label(text)
	return (text:gsub("%c", " "))
end

local function styled(text, color)
	return "\27[" .. color .. "m" .. clean_label(text) .. "\27[0m"
end

local function row(label, data, style)
	style = style or {}
	label = clean_label(label)
	if style.icon then label = styled(style.icon, style.color or 39) .. " " .. label end
	if style.current ~= nil then label = (style.current and styled("●", 32) or " ") .. " " .. label end
	if style.suffix then label = label .. styled(style.suffix, "2;90") end
	-- fzf callbacks receive only hex-encoded JSON, never raw paths or labels.
	local token = assert(rex.json.encode(data)):gsub(".", function(byte)
		return string.format("%02x", byte:byte())
	end)
	return label .. "\t" .. token
end

local function decode(token)
	assert(token and token:match("^[0-9a-f]+$") and #token % 2 == 0, "Invalid picker selection")
	local json = token:gsub("..", function(byte) return string.char(tonumber(byte, 16)) end)
	return assert(rex.json.decode(json))
end

local function tiled_blocks(window)
	local blocks = {}
	for _, layer in ipairs(window.layers or {}) do
		if layer.kind == "tiled" then
			for _, block in ipairs(layer.blocks or {}) do table.insert(blocks, block) end
		end
	end
	return blocks
end

local function block_directory(session_id, block, strict)
	if block.creator_name ~= "com.superlogical.terminal" then return nil end
	local process, err = rex.call("com.superlogical.terminal.process", {
		session_id = session_id, block_id = block.block_id, args = {},
	})
	-- Listing can skip a pane that disappeared. Destructive worktree actions
	-- must finish inspecting the panes before they change files or stop apps.
	if strict then assert(process, err) end
	if not process then return nil end
	local cwd = (process.foreground and process.foreground.cwd) or (process.child and process.child.cwd)
	if not cwd then return nil end
	local resolved = exec({ "realpath", "--", cwd })
	return resolved.ok and resolved.stdout:gsub("\n$", "") or nil
end

local function terminal(directory, command)
	return rex.layout.block({ flavor = "com.superlogical.terminal.shell",
		options = { cwd = directory, command = command } })
end

local editor = { "zsh", "-ic", "nvim; exec zsh" }
M.yazi = { "zsh", "-ic", "y; exec zsh" }

-- A temporary floating layer lets us swap a fresh terminal into the exact
-- split, then close the old process without changing split sizes or siblings.
function M.replace_pane(session_id, block_id, directory, command, focus)
	local window_id
	for _, window in ipairs(api("session.view", { session_id = session_id }).windows or {}) do
		for _, layer in ipairs(window.layers or {}) do
			for _, block in ipairs(layer.blocks or {}) do
				if block.block_id == block_id then window_id = window.window_id end
			end
		end
	end
	assert(window_id, "The original pane no longer exists")
	local created = api("session.new_layer", { session_id = session_id, window_id = window_id,
		bounds = { 0.1, 0.1, 0.8, 0.8 }, focus = false, layout = terminal(directory, command) })
	local replacement = created.block_ids[1]
	local ok, err = pcall(api, "session.swap_blocks", {
		session_id = session_id, block_id = block_id, other_block_id = replacement,
	})
	if not ok then
		api("block.close", { session_id = session_id, block_id = replacement })
		error(err)
	end
	api("block.close", { session_id = session_id, block_id = block_id })
	if focus ~= false then api("session.focus_block", { session_id = session_id, block_id = replacement }) end
	return replacement
end

local function session_entries()
	local sessions = api("session.list").sessions or {}
	for _, session in ipairs(sessions) do
		session.view = api("session.view", { session_id = session.session_id })
		for _, window in ipairs(session.view.windows or {}) do
			for _, block in ipairs(tiled_blocks(window)) do
				session.directory = block_directory(session.session_id, block)
				if session.directory then break end
			end
			if session.directory then break end
		end
	end
	return sessions
end

local function session_rows(mode)
	local rows = {}
	if mode == "dirs" then
		local found = checked(exec({ "fd", "--type", "d", "--hidden", "--follow", "--exclude", ".git",
			"--max-depth", "4", ".", home }))
		for _, directory in ipairs(lines(found)) do
			table.insert(rows, row(directory, { kind = "directory", directory = directory }, { icon = "", color = 36 }))
		end
		return rows
	end
	local listed = {}
	for _, session in ipairs(session_entries()) do
		local windows, names = session.view.windows or {}, {}
		for index = 1, math.min(#windows, 4) do table.insert(names, windows[index].label or "") end
		if #windows > 4 then table.insert(names, "+" .. (#windows - 4)) end
		table.insert(rows, row(session.label, {
			kind = "session", session_id = session.session_id, directory = session.directory,
		}, { icon = "", color = 34, suffix = "   " .. table.concat(names, " · ") }))
		if session.directory then listed[session.directory] = true end
	end
	if mode == "sessions" then return rows end

	local dotfiles = canonical(config_dir):match("^(.*)/[^/]+$")
	local candidates = { dotfiles, home .. "/dotfiles" }
	if is_directory(home .. "/Workspace") then
		for _, directory in ipairs(lines(checked(exec({ "fd", "--type", "d", "--max-depth", "1", ".", home .. "/Workspace" })))) do
			table.insert(candidates, directory)
		end
	end
	local projects, project_set = directories(candidates), {}
	for _, directory in ipairs(projects) do project_set[directory] = true end
	local ranked, ordered, others = {}, {}, {}
	local history = rex.exec({ "zoxide", "query", "--list" })
	if history and history.ok then ranked = directories(lines(history.stdout)) end
	for _, directory in ipairs(ranked) do
		if project_set[directory] then
			table.insert(ordered, directory)
		else
			local nested = false
			for _, project in ipairs(projects) do
				if directory:sub(1, #project + 1) == project .. "/" then nested = true; break end
			end
			if not nested then table.insert(others, directory) end
		end
	end
	for _, directory in ipairs(projects) do table.insert(ordered, directory) end
	for _, directory in ipairs(others) do table.insert(ordered, directory) end
	for _, directory in ipairs(ordered) do
		if not listed[directory] then
			listed[directory] = true
			local label = project_set[directory] and basename(directory) or directory
			if label:sub(1, #home + 1) == home .. "/" then label = "~" .. label:sub(#home + 1) end
			local is_dotfiles = directory == dotfiles or directory == home .. "/dotfiles"
			table.insert(rows, row(label, { kind = "directory", directory = directory }, {
				icon = is_dotfiles and "" or (project_set[directory] and "" or ""),
				color = is_dotfiles and 35 or 36,
			}))
		end
	end
	return rows
end

local function worktrees(directory)
	local trees, tree = {}, {}
	for _, field in ipairs(split(checked(git(directory, "worktree", "list", "--porcelain", "-z")), "\0")) do
		if field == "" then
			if next(tree) then table.insert(trees, tree); tree = {} end
		else
			local key, value = field:match("^(%S+)%s?(.*)$")
			tree[key] = value
		end
	end
	-- Git's linked-worktree metadata records creation/reuse order, as in wt.
	for index = 2, #trees do
		local tree = trees[index]
		local admin = git(tree.worktree, "rev-parse", "--path-format=absolute", "--git-dir")
		tree.order = math.huge
		if admin.ok then
			tree.admin = admin.stdout:gsub("\n$", "")
			local stamp = exec({ "zsh", "-fc", 'zmodload zsh/stat && zstat +mtime "$1/gitdir"', "zsh", tree.admin })
			if stamp.ok then tree.order = tonumber(stamp.stdout) or math.huge end
		end
	end
	local main = table.remove(trees, 1)
	table.sort(trees, function(a, b)
		if a.order ~= b.order then return a.order < b.order end
		return (a.admin or a.worktree) < (b.admin or b.worktree)
	end)
	if main then table.insert(trees, 1, main) end
	return trees
end

local function worktree_rows(directory)
	local trees, rows, attached = worktrees(directory), {}, {}
	local current = canonical(checked(git(directory, "rev-parse", "--show-toplevel")):gsub("\n$", ""))
	for index, tree in ipairs(trees) do
		local branch = (tree.branch or ""):gsub("^refs/heads/", "")
		attached[branch] = true
		local label = branch ~= "" and branch or ("detached " .. (tree.HEAD or ""):sub(1, 8))
		local suffix = index == 1 and " (main checkout)" or ""
		if tree.prunable then suffix = suffix .. " (missing)" end
		table.insert(rows, row(label, { kind = "worktree", directory = tree.worktree, branch = branch }, {
			icon = "", color = index == 1 and 35 or 33, suffix = suffix,
			current = tree.worktree == current,
		}))
	end
	local root = trees[1].worktree
	for _, branch in ipairs(lines(checked(git(root, "for-each-ref", "--sort=refname", "--format=%(refname:short)", "refs/heads")))) do
		if not attached[branch] then
			table.insert(rows, row(branch, { kind = "branch", directory = root, branch = branch }, {
				icon = "", color = 90, current = false, suffix = " (create worktree)",
			}))
		end
	end
	return rows
end

function M.picker_layout(kind, ctx)
	local process = api("com.superlogical.terminal.process", {
		session_id = ctx.session_id, block_id = ctx.block_id, args = {},
	})
	local directory = canonical(assert((process.foreground and process.foreground.cwd)
		or (process.child and process.child.cwd), "Cannot determine the current pane's directory"))
	local cwd = kind == "worktrees" and worktrees(directory)[1].worktree or directory
	return terminal(cwd, command(kind, ctx, directory))
end

local function open_tab(session_id, directory, reuse, focus, command)
	directory = canonical(directory)
	assert(is_directory(directory), "Not a directory: " .. directory)
	if focus == nil then focus = true end
	if reuse then
		for _, window in ipairs(api("session.view", { session_id = session_id }).windows or {}) do
			for _, block in ipairs(tiled_blocks(window)) do
				local cwd = block_directory(session_id, block)
				local root = cwd and git(cwd, "rev-parse", "--show-toplevel")
				if root and root.ok and root.stdout:gsub("\n$", "") == directory then
					if focus then api("session.focus_window", { session_id = session_id, window_id = window.window_id }) end
					return window.window_id
				end
			end
		end
	end
	local branch = git(directory, "branch", "--show-current").stdout:gsub("\n$", "")
	local created = api("session.new_window", {
		session_id = session_id, focus = focus,
		window_label = (branch ~= "" and branch or basename(directory)):sub(1, 128),
		layout = terminal(directory, command),
	})
	return created.window_id
end

-- Keep unrelated tabs in place relative to each other, then append existing
-- linked-worktree tabs in creation/reuse order, matching wt's reorder_windows.
local function reorder_worktrees(session_id, directory)
	local by_root = {}
	for _, window in ipairs(api("session.view", { session_id = session_id }).windows or {}) do
		for _, block in ipairs(tiled_blocks(window)) do
			local cwd = block_directory(session_id, block)
			local root = cwd and git(cwd, "rev-parse", "--show-toplevel")
			if root and root.ok then
				local path = root.stdout:gsub("\n$", "")
				by_root[path] = by_root[path] or window.window_id
			end
		end
	end
	local moved = {}
	for index, tree in ipairs(worktrees(directory)) do
		local id = by_root[tree.worktree]
		if index > 1 and id and not moved[id] then
			api("session.move_window", { session_id = session_id, window_id = id })
			moved[id] = true
		end
	end
end

local function open_worktree(session_id, directory)
	local window_id = open_tab(session_id, directory, true)
	reorder_worktrees(session_id, directory)
	return window_id
end

local function spread(session_id, directory)
	for _, tree in ipairs(worktrees(directory)) do
		if not tree.prunable then open_tab(session_id, tree.worktree, true, false) end
	end
	reorder_worktrees(session_id, directory)
end

-- Match sesh's project rules. Ordinary directories still open a plain shell.
local function project_windows(directory)
	local dotfiles = canonical(config_dir):match("^(.*)/[^/]+$")
	local workspace = directory:sub(1, #home + 11) == home .. "/Workspace/"
	local project = workspace or directory == dotfiles or directory == home .. "/dotfiles"
	local windows = { { window_label = project and "code" or basename(directory),
		layout = terminal(directory, project and editor or nil) } }
	if workspace then table.insert(windows, { window_label = "dev", layout = terminal(directory) }) end
	if project and git(directory, "rev-parse", "--show-toplevel").ok then
		for index, tree in ipairs(worktrees(directory)) do
			if index > 1 and tree.worktree ~= directory and not tree.prunable then
				local label = (tree.branch or ""):gsub("^refs/heads/", "")
				table.insert(windows, { window_label = (label ~= "" and label or basename(tree.worktree)):sub(1, 128),
					layout = terminal(tree.worktree) })
			end
		end
	end
	return windows
end

local function worktree_command(root, check, action, directory, branch)
	local helper_path = canonical(config_dir):match("^(.*)/[^/]+$") .. "/tmux/worktree.sh"
	local argv = { "zsh", "-c", 'cd -- "$1" && shift && exec "$@"', "zsh", root, helper_path, "--git-only" }
	if check then table.insert(argv, "--check") end
	table.insert(argv, action)
	table.insert(argv, directory)
	if branch then table.insert(argv, branch) end
	return checked(exec(argv))
end

-- Snapshot all affected terminal panes before moving/removing their directory.
-- The picker itself runs from the main checkout, so it survives either action.
local function worktree_panes(directory)
	local panes = {}
	for _, session in ipairs(api("session.list").sessions or {}) do
		for _, window in ipairs(api("session.view", { session_id = session.session_id }).windows or {}) do
			for _, layer in ipairs(window.layers or {}) do
				for _, block in ipairs(layer.blocks or {}) do
					local cwd = block_directory(session.session_id, block, true)
					if cwd and (cwd == directory or cwd:sub(1, #directory + 1) == directory .. "/") then
						table.insert(panes, { session_id = session.session_id, window_id = window.window_id,
							block_id = block.block_id, directory = cwd })
					end
				end
			end
		end
	end
	return panes
end

local function rename_worktree(directory, branch)
	directory = canonical(directory)
	local root = worktrees(directory)[1].worktree
	worktree_command(root, true, "rename", directory, branch)
	local panes = worktree_panes(directory)
	worktree_command(root, false, "rename", directory, branch)
	local target = root .. "/.worktrees/" .. branch:gsub("/", "+")
	for _, pane in ipairs(panes) do
		M.replace_pane(pane.session_id, pane.block_id, target .. pane.directory:sub(#directory + 1), nil, false)
		api("session.set_window_label", { session_id = pane.session_id, window_id = pane.window_id, label = branch:sub(1, 128) })
		api("session.move_window", { session_id = pane.session_id, window_id = pane.window_id })
	end
	return target
end

local function remove_worktree(directory)
	directory = canonical(directory)
	local root = worktrees(directory)[1].worktree
	worktree_command(root, true, "remove", directory)
	for _, pane in ipairs(worktree_panes(directory)) do
		api("block.close", { session_id = pane.session_id, block_id = pane.block_id })
	end
	-- Run the same safeguards again after stopping the worktree's processes.
	worktree_command(root, false, "remove", directory)
end

local function create_worktree(directory, branch)
	checked(git(directory, "check-ref-format", "--branch", branch))
	local trees = worktrees(directory)
	for _, tree in ipairs(trees) do
		if tree.branch == "refs/heads/" .. branch then return tree.worktree end
	end
	local root = trees[1].worktree
	local target = root .. "/.worktrees/" .. branch:gsub("/", "+")
	assert(not exec({ "test", "-e", target }).ok and not exec({ "test", "-L", target }).ok, "Path already exists: " .. target)
	if git(root, "show-ref", "--verify", "--quiet", "refs/heads/" .. branch).ok then
		checked(git(root, "worktree", "add", "--", target, branch))
	else
		checked(git(root, "worktree", "add", "-b", branch, "--", target, os.getenv("WORKTREE_BASE_BRANCH") or "main"))
	end
	return target
end

local function select_session(client_id, selection)
	local session_id = selection.session_id
	if selection.kind ~= "session" then
		local directory = canonical(selection.directory)
		assert(is_directory(directory), "Not a directory: " .. directory)
		for _, session in ipairs(session_entries()) do
			if session.directory == directory then session_id = session.session_id; break end
		end
		if not session_id then
			local created = api("session.create", {
				label = basename(directory):sub(1, 128),
				initial_windows = project_windows(directory),
			})
			session_id = created.session_id
			api("session.focus_window", { session_id = session_id, window_id = created.initial_windows[1].window_id })
		end
	end
	-- Focus on the server alone does not switch the originating app's session.
	api("client.perform", { client_id = client_id, action = "session.select", args = { session_id = session_id } })
	return session_id
end

local function preview(selection)
	if selection.kind == "session" then
		local view = api("session.view", { session_id = selection.session_id })
		print(styled(view.label or "Session", "1;34"))
		for _, window in ipairs(view.windows or {}) do
			print((window.window_id == view.active_window_id and styled("●", 32) or " ") .. " " .. clean_label(window.label or ""))
		end
		print()
	end
	local directory = selection.directory
	if not directory then return end
	print(styled(directory, 36) .. "\n")
	if selection.kind == "worktree" or selection.kind == "branch" then
		local branch = selection.branch ~= "" and selection.branch or "HEAD"
		io.write(checked(git(directory, "log", "--oneline", "--graph", "--decorate", "--color=always", "-20", branch, "--")))
	else
		local status = git(directory, "-c", "color.status=always", "status", "--short", "--branch")
		if status.ok then io.write(status.stdout) end
		local entries = lines(checked(exec({ "ls", "-1Ap", "--", directory })))
		table.sort(entries, function(a, b)
			local ad, bd = a:sub(-1) == "/", b:sub(-1) == "/"
			if ad ~= bd then return ad end
			return a < b
		end)
		for index = 1, math.min(#entries, 40) do
			local name = entries[index]
			print(name:sub(-1) == "/" and styled(name, 36) or clean_label(name))
		end
	end
end

local function choose(rows, options)
	local argv = { "fzf", "--ansi", "--style=minimal", "--height=100%", "--layout=reverse", "--delimiter=\t",
		"--with-nth=1", "--nth=1", "--print-query", "--query=" .. (options.query or ""),
		"--prompt=" .. options.prompt, "--header=" .. options.header, "--expect=" .. options.expect,
		"--preview=" .. helper("preview") .. " token={2}", "--preview-window=right,60%",
		"--bind=tab:down,btab:up,ctrl-u:half-page-up,ctrl-d:half-page-down" }
	for _, binding in ipairs(options.bindings or {}) do table.insert(argv, "--bind=" .. binding) end
	local result = exec(argv, { stdin = table.concat(rows, "\n") })
	if result.code == 130 then return nil end
	assert(result.code == 0 or result.code == 1, result.stderr)
	local output = split(result.stdout, "\n")
	if not output[2] or output[2] == "" then return nil end
	return { key = output[2], query = output[1],
		selection = output[3] and output[3] ~= "" and decode(output[3]:match("\t([^\t]+)$")) or nil }
end

local function confirm(message)
	local result = exec({ "fzf", "--style=minimal", "--disabled", "--no-info", "--height=100%",
		"--prompt=" .. message, "--header=enter/y confirm · esc/n cancel", "--bind=y:accept,n:abort" }, { stdin = "confirm\n" })
	return result.ok and result.stdout == "confirm\n"
end

local function branch_prompt(header)
	local result = exec({ "fzf", "--height=100%", "--print-query", "--prompt=branch: ",
		"--header=" .. (header or "enter create · esc cancel") }, { stdin = "" })
	if result.code ~= 0 and result.code ~= 1 then return nil end
	local branch = split(result.stdout, "\n")[1]
	return branch ~= "" and branch or nil
end

local function perform(kind, selected, session_id, client_id, directory, origin_block_id)
	local key, selection = selected.key, selected.selection
	local window_id
	if kind == "sessions" then
		if not selection then return false end
		if key == "ctrl-x" then
			if selection.kind ~= "session" then return false end
			assert(selection.session_id ~= session_id, "Cannot close the session hosting this picker")
			local view = api("session.view", { session_id = selection.session_id })
			if confirm("close " .. clean_label(view.label or "session") .. "? ") then
				api("session.destroy", { session_id = selection.session_id })
			end
			return false
		elseif key == "ctrl-o" or key == "ctrl-r" then
			assert(selection.directory, "This session has no readable terminal directory")
			if key == "ctrl-r" then
				M.replace_pane(session_id, origin_block_id, selection.directory, editor)
			else
				window_id = open_tab(session_id, selection.directory, false, true, editor)
			end
		else
			select_session(client_id, selection)
		end
	elseif key == "ctrl-s" then
		spread(session_id, directory)
		return false
	elseif key == "ctrl-r" or key == "ctrl-x" then
		if not selection or selection.kind ~= "worktree" then return false end
		if key == "ctrl-r" then
			local branch = branch_prompt("reuse " .. clean_label(selection.branch) .. " + restart panes · enter rename · esc cancel")
			if branch then rename_worktree(selection.directory, branch) end
		elseif confirm("delete " .. clean_label(selection.branch) .. "? ") then
			remove_worktree(selection.directory)
		end
		return false
	elseif key == "ctrl-o" then
		local branch = branch_prompt()
		if not branch then return false end
		window_id = open_worktree(session_id, create_worktree(directory, branch))
	elseif selection then
		local target = selection.directory
		if selection.kind == "branch" then target = create_worktree(target, selection.branch) end
		window_id = open_worktree(session_id, target)
	else
		return false
	end
	if window_id then
		api("client.perform", { client_id = client_id, action = "session.select",
			args = { session_id = session_id, window_id = window_id } })
	end
	return true
end

local function pause(message)
	io.stderr:write(tostring(message) .. "\nPress Enter to continue…")
	io.stderr:flush()
	io.read("*l")
end

local function pick(args)
	assert(args.session_id and args.client_id, "Open this picker through its Rex shortcut")
	local directory = canonical(args.directory or ".")
	local root = args.kind == "worktrees" and worktrees(directory)[1].worktree
	local query = ""
	while true do
		if root and not is_directory(directory) then directory = root end
		local rows, options
		if args.kind == "sessions" then
			options = { prompt = "  ", expect = "enter,ctrl-o,ctrl-r,ctrl-x", query = query,
				header = "^e all · ^t sessions · ^f dirs\n^o editor tab · ^r editor pane · ^x close session", bindings = {} }
			-- Ctrl+A remains Rex's prefix inside floating terminals.
			for _, mode in ipairs({ { "e", "all" }, { "t", "sessions" }, { "f", "dirs" } }) do
				table.insert(options.bindings, "ctrl-" .. mode[1] .. ":change-prompt(" .. mode[2]
					.. " )+reload(" .. helper("list", { kind = "sessions", mode = mode[2] }) .. ")")
			end
			rows = session_rows("all")
		else
			options = { prompt = "  ", expect = "enter,ctrl-o,ctrl-w,ctrl-r,ctrl-s,ctrl-x", query = query,
				header = "enter open · ^o new · ^w create selected\n^r rename · ^s spread · ^x delete" }
			rows = worktree_rows(directory)
		end
		local selected = choose(rows, options)
		if not selected then return end
		query = selected.query
		local ok, done = pcall(perform, args.kind, selected, args.session_id, args.client_id, directory, args.origin_block_id)
		if not ok then pause(done) elseif done then return end
	end
end

if rex.args and rex.args.action then
	local ok, err = pcall(function()
		local args = rex.args
		if args.action == "preview" then
			preview(decode(args.token))
		elseif args.action == "list" then
			local rows = args.kind == "sessions" and session_rows(args.mode or "all") or worktree_rows(canonical("."))
			io.write(table.concat(rows, "\n") .. "\n")
		elseif args.action == "pick" then
			assert(args.kind == "sessions" or args.kind == "worktrees", "Unknown picker")
			pick(args)
		else
			error("Unknown picker action")
		end
	end)
	if not ok then
		if rex.args.action == "pick" then pause(err) else io.stderr:write(tostring(err) .. "\n") end
		rex.stop(1)
	end
else
	return M
end
