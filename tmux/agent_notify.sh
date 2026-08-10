#!/bin/sh

# Agents already emit their own OSC desktop notification. When the agent's tmux
# window is not visible, also mark that window and write BEL to its pane so tmux
# keeps the usual alert state until the window is viewed.
#
# Codex calls this via `notify`; Claude Code via a Stop hook. Both pass a JSON
# event, which is ignored unless the pane has to be located by workspace path.
pane=${TMUX_PANE:-}

# Codex app-server mode runs notify outside the TUI process tree, so TMUX_PANE is
# not inherited. In that case, locate the pane by the callback's workspace path.
# Claude Code runs hooks as children of the TUI, so its TMUX_PANE always wins.
if [ -z "$pane" ]; then
  event_cwd=$(printf '%s' "${1:-{}}" | jq -r '.cwd // empty' 2>/dev/null)
  [ -n "$event_cwd" ] || exit 0

  pane=$(
    tmux list-panes -a -F '#{pane_id}|#{pane_current_command}|#{pane_current_path}' 2>/dev/null |
      awk -F '|' -v cwd="$event_cwd" '
        $3 == cwd && $2 ~ /^(codex|claude)/ { print $1; found = 1; exit }
        $3 == cwd && fallback == "" { fallback = $1 }
        END { if (!found && fallback != "") print fallback }
      '
  )
  [ -n "$pane" ] || exit 0
fi

state=$(tmux display-message -p -t "$pane" '#{pane_tty}|#{window_active_clients_list}' 2>/dev/null) ||
  exit 0
pane_tty=${state%%|*}
viewing=${state#*|}

# A client can be attached to this window while the user looks at another
# session, so "some client is viewing it" is not the same as "it is on screen".
# Treat the window as visible only when a client that is viewing it also holds
# the terminal's focus. tmux has no client_focused format; `focused` appears in
# client_flags, and only while the terminal emulator itself has OS focus -- so
# backgrounding the terminal correctly makes every window not visible.
focused=$(tmux list-clients -F '#{client_name}' \
  -f '#{m:*focused*,#{client_flags}}' 2>/dev/null)
visible=$(printf '%s\n' "$focused" | awk -v list="$viewing" '
  BEGIN { n = split(list, a, ",") }
  NF { for (i = 1; i <= n; i++) if (a[i] == $0) { print 1; exit } }
')
[ -z "$visible" ] || exit 0
[ -w "$pane_tty" ] || exit 0

tmux set-option -w -t "$pane" @agent_notification 1 || exit 0
printf '\a' >"$pane_tty"
