#!/bin/sh

# Agents already emit their own OSC desktop notification. When the agent's tmux
# window is not visible, also mark that window and write BEL to its pane so tmux
# keeps the usual alert state until the window is viewed.
#
# Codex calls this via `notify`; Claude Code via a Stop hook. Both pass a JSON
# event. Codex's thread ID is also exposed by its TUI in the pane title so the
# app-server callback can locate the exact client pane.
pane=${TMUX_PANE:-}

# Codex app-server mode runs notify outside the TUI process tree, so TMUX_PANE is
# not inherited. Match the callback's thread ID to the session ID in the title.
# Codex renders the first 29 characters plus "..." within that item's 32-character
# limit; this still identifies the pane without conflating clients that happen
# to use the same workspace. Claude Code runs hooks as children of the TUI, so
# its TMUX_PANE always wins.
if [ -z "$pane" ]; then
  thread_id=$(printf '%s' "${1:-{}}" | jq -r '."thread-id" // empty' 2>/dev/null)
  [ -n "$thread_id" ] || exit 0
  thread_title=$(printf '%.29s...' "$thread_id")

  pane=$(
    tmux list-panes -a -F '#{pane_id} #{pane_current_command} #{pane_title}' 2>/dev/null |
      awk -v thread="$thread_title" '
        $2 ~ /^codex/ && index($0, thread) { print $1; exit }
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
