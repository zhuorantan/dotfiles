#!/bin/sh

# Agents already emit their own OSC desktop notification. Mark the tmux window
# whenever a turn completes so its tab shows the completion icon. When the
# agent's pane is not focused, also write BEL so tmux keeps the usual alert
# state until that pane is focused.
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

state=$(tmux display-message -p -t "$pane" '#{pane_tty}|#{pane_active}|#{window_active_clients_list}' 2>/dev/null) ||
  exit 0
pane_tty=${state%%|*}
state=${state#*|}
pane_active=${state%%|*}
viewing=${state#*|}

# A completed pane is foreground only when it is the window's active pane and a
# focused client is viewing that window. An inactive split is still background
# work and should leave a robot marker even though the containing window is on
# screen. tmux has no client_focused format; `focused` appears in client_flags.
focused=$(tmux list-clients -F '#{client_name}' \
  -f '#{m:*focused*,#{client_flags}}' 2>/dev/null)
foreground=$(printf '%s\n' "$focused" | awk -v active="$pane_active" -v list="$viewing" '
  active != 1 { exit }
  BEGIN { n = split(list, a, ",") }
  NF { for (i = 1; i <= n; i++) if (a[i] == $0) { print 1; exit } }
')

tmux set-option -w -t "$pane" @agent_notification 1 || exit 0
[ -z "$foreground" ] || exit 0
[ -w "$pane_tty" ] || exit 0
printf '\a' >"$pane_tty"
