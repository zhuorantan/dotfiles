#!/bin/sh

# Agents already emit their own OSC desktop notification. When the agent's tmux
# window is not visible, also mark that window and write BEL to its pane so tmux
# keeps the usual alert state until that window is viewed.
#
# Codex calls this via `notify`; Claude Code via a Stop hook. Both pass a JSON
# event. Codex's thread ID is also exposed by its TUI in the pane title so the
# app-server callback can locate the exact client pane.
pane=${TMUX_PANE:-}

# Codex's shared daemon can inherit TMUX_PANE from the terminal that started it,
# so it is not the callback's pane. Always match Codex's thread ID to the title.
# Codex renders the first 29 characters plus "..." within that item's 32-character
# limit; this still identifies the pane without conflating clients that happen
# to use the same workspace. Claude Code runs hooks as children of the TUI, so
# its events without a Codex thread ID use the inherited TMUX_PANE.
thread_id=$(printf '%s' "${1:-}" | jq -r '."thread-id" // empty' 2>/dev/null)
if [ -n "$thread_id" ]; then
  thread_title=$(printf '%.29s...' "$thread_id")

  pane=$(
    tmux list-panes -a -F '#{pane_id} #{pane_title}' 2>/dev/null |
      awk -v thread="$thread_id" -v short_thread="$thread_title" '
        { for (i = 2; i <= NF; i++)
            if ($i == thread || $i == short_thread) { print $1; exit }
        }
      '
  )
  [ -n "$pane" ] || exit 0
fi
[ -n "$pane" ] || exit 0

state=$(tmux display-message -p -t "$pane" '#{pane_tty}|#{window_id}' 2>/dev/null) ||
  exit 0
pane_tty=${state%%|*}
window_id=${state#*|}

# A completed pane is foreground whenever its window is the focused client's
# current window, regardless of which pane in that window is active. Comparing
# the exact window ID avoids treating the active window of an inactive session
# as visible merely because that session remains attached to the client. tmux
# has no client_focused format; `focused` appears in client_flags.
focused_windows=$(tmux list-clients -F '#{window_id}' \
  -f '#{m:*focused*,#{client_flags}}' 2>/dev/null)
foreground=$(printf '%s\n' "$focused_windows" | awk -v target="$window_id" '
  $0 == target { print 1; exit }
')

[ -z "$foreground" ] || exit 0
tmux set-option -w -t "$pane" @agent_notification 1 || exit 0
[ -w "$pane_tty" ] || exit 0
printf '\a' >"$pane_tty"
