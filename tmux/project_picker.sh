#!/usr/bin/env zsh

# Picker over tmux sessions, projects and directories (see project_list.sh).
# Bound to prefix + Space; takes no arguments.
#
# Enter attaches to the selection; ^o and ^r open it as a window or in the
# current pane instead, so one picker covers every way of getting somewhere.
#
# Sources, switched with a key instead of automatically:
#
#   ^a  everything — tmux sessions, projects, zoxide history
#   ^t  live tmux sessions only
#   ^f  directory search under $HOME
#
# Also: ^u/^d scroll the list by half a page, ^x kills the selected session, and
# ^o / ^r open the selection as a new window or in the current pane instead of
# attaching to it. Both decline session rows, which have no directory to cd into.
#
# Rows are "<icon> <label>\t<target>". fzf shows the first field (--with-nth) and
# returns the second (--accept-nth), so the icon never has to be stripped back off
# the selection.

emulate -L zsh

SELF=${${(%):-%N}:A}
LIST=${SELF:h}/project_list.sh

# These --* branches are how the fzf bindings re-enter this script. fzf
# shell-quotes field placeholders, so each one unquotes $2 before using it.
if [[ ${1:-} == --open-bind ]]; then
  TARGET=$(eval print -r -- "$3")
  # Only a directory can be opened this way; decline session rows.
  [[ $TARGET == /* ]] || { print -r -- ignore; exit 0 }
  print -r -- "become($SELF --open $2 {2})"
  exit 0
fi

# Unlike transform, become() substitutes {2} unquoted, so $3 arrives verbatim.
if [[ ${1:-} == --open ]]; then
  case $2 in
    new-window)   exec tmux new-window -c ${3%/} 'nvim; zsh' ;;
    respawn-pane) exec tmux respawn-pane -k -c ${3%/} 'nvim; zsh' ;;
  esac
fi

# Killing the session the picker runs in would take the picker down with it, so
# that one case is refused rather than hidden from the list.
if [[ ${1:-} == --kill ]]; then
  [[ -n $2 && $2 != /* ]] || exit 0
  [[ $2 == $(tmux display-message -p '#{session_name}' 2>/dev/null) ]] && exit 0
  tmux kill-session -t $2 2>/dev/null
  exit 0
fi

# One prompt glyph per mode, so the source is obvious at a glance.
PROMPT_ALL=$'\uf120  '
PROMPT_TMUX=$'\uebc8  '
PROMPT_DIRS=$'\uf07c  '

# The border label is never drawn — the tmux popup supplies the visible title —
# but fzf still tracks it and exports it as $FZF_BORDER_LABEL, which makes it a
# convenient place to keep the current mode for bindings that need to read it.
MODE_ALL=all
MODE_TMUX=tmux
MODE_DIRS=dirs

TARGET=$(
  $LIST | fzf \
    --style minimal \
    --ansi \
    --no-sort \
    --delimiter=$'\t' \
    --with-nth 1 \
    --accept-nth 2 \
    --border-label=$MODE_ALL \
    --prompt=$PROMPT_ALL \
    --header='^a all · ^t tmux · ^f dirs · ^o window · ^r pane · ^x kill' \
    --preview 'sesh preview {2}' \
    --preview-window 'right,60%' \
    --bind "ctrl-a:change-border-label($MODE_ALL)+change-prompt($PROMPT_ALL)+reload($LIST)" \
    --bind "ctrl-t:change-border-label($MODE_TMUX)+change-prompt($PROMPT_TMUX)+reload($LIST --tmux)" \
    --bind "ctrl-o:transform:$SELF --open-bind new-window {2}" \
    --bind "ctrl-r:transform:$SELF --open-bind respawn-pane {2}" \
    --bind "ctrl-x:execute-silent($SELF --kill {2})+transform:
      case \$FZF_BORDER_LABEL in
        $MODE_TMUX) echo 'reload($LIST --tmux)' ;;
        $MODE_DIRS) echo 'reload($LIST --dirs)' ;;
        *) echo 'reload($LIST)' ;;
      esac" \
    --bind "ctrl-f:change-border-label($MODE_DIRS)+change-prompt($PROMPT_DIRS)+reload($LIST --dirs)" \
    --bind 'tab:down,btab:up' \
    --bind 'ctrl-u:half-page-up' \
    --bind 'ctrl-d:half-page-down'
)

[[ -n $TARGET ]] || exit 0

# Directory rows come straight from fd, which may leave a trailing slash.
TARGET=${TARGET%/}

exec sesh connect $TARGET
