#!/bin/sh

# Codex already emits OSC 9 for the desktop notification. When its tmux window
# is not visible, also mark that window and write BEL to its pane so tmux keeps
# the usual alert state until the window is viewed.
pane=${TMUX_PANE:-}

# App-server mode runs notify outside the TUI process tree, so TMUX_PANE is not
# inherited. In that case, locate the pane by the callback's workspace path.
if [ -z "$pane" ]; then
  event_cwd=$(printf '%s' "${1:-{}}" | jq -r '.cwd // empty' 2>/dev/null)
  [ -n "$event_cwd" ] || exit 0

  pane=$(
    tmux list-panes -a -F '#{pane_id}|#{pane_current_command}|#{pane_current_path}' 2>/dev/null |
      awk -F '|' -v cwd="$event_cwd" '
        $3 == cwd && $2 ~ /^codex/ { print $1; found = 1; exit }
        $3 == cwd && fallback == "" { fallback = $1 }
        END { if (!found && fallback != "") print fallback }
      '
  )
  [ -n "$pane" ] || exit 0
fi

state=$(tmux display-message -p -t "$pane" '#{window_active_clients} #{pane_tty}' 2>/dev/null) ||
  exit 0
visible=${state%% *}
pane_tty=${state#* }
[ "$visible" = 0 ] || exit 0
[ -w "$pane_tty" ] || exit 0

tmux set-option -w -t "$pane" @agent_notification 1 || exit 0
printf '\a' >"$pane_tty"
