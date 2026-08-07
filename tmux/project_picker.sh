#!/usr/bin/env zsh

# Picker over tmux sessions, projects and directories (see project_list.sh).
#
#   project_picker.sh session           attach or create a session   (prefix + T)
#   project_picker.sh session --tmux    live tmux sessions only      (prefix + t)
#   project_picker.sh window            open the dir in a new window (prefix + o)
#   project_picker.sh window --replace  ... in this pane instead     (prefix + O)
#
# The action is required. window never lists tmux sessions, since a session name
# is not something you can cd into.
#
# Sources, switched with a key instead of automatically:
#
#   ^a  everything — tmux sessions, projects, zoxide history
#   ^t  live tmux sessions only
#   ^f  directory search under $HOME
#
# Also: ^u/^d scroll the list by half a page, ^x kills the selected session, and
# ^o opens the selection in a new window instead of attaching to it.
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
  TARGET=$(eval print -r -- "$2")
  # Only a directory can be opened as a window; decline session rows.
  [[ $TARGET == /* ]] || { print -r -- ignore; exit 0 }
  print -r -- "become($SELF --new-window {2})"
  exit 0
fi

# Unlike transform, become() substitutes {2} unquoted, so $2 arrives verbatim.
if [[ ${1:-} == --new-window ]]; then
  exec tmux new-window -c ${2%/} 'nvim; zsh'
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

ACTION=${1:-}
shift 2>/dev/null

REPLACE_PANE=
START_MODE=
case $ACTION in
  session)
    [[ ${1:-} == --tmux ]] && START_MODE=--tmux ;;
  window)
    [[ ${1:-} == --replace ]] && REPLACE_PANE=1
    # A session name cannot be cd'd into, so never offer one here.
    START_MODE=--no-tmux ;;
  *)
    print -ru2 -- "usage: ${0:t} session [--tmux] | window [--replace]"
    exit 1 ;;
esac

case $START_MODE in
  --tmux) START_PROMPT=$PROMPT_TMUX; START_LABEL=$MODE_TMUX ;;
  *)      START_PROMPT=$PROMPT_ALL; START_LABEL=$MODE_ALL ;;
esac

if [[ $ACTION == window ]]; then
  # Only directories are on offer here, so there is no session to switch to,
  # kill, or escalate into a window.
  HEADER='^a all · ^f dirs'
  EXTRA_BINDS=(
    --bind "ctrl-a:change-border-label($MODE_ALL)+change-prompt($PROMPT_ALL)+reload($LIST --no-tmux)"
  )
else
  HEADER='^a all · ^t tmux · ^f dirs · ^o window · ^x kill'
  EXTRA_BINDS=(
    --bind "ctrl-a:change-border-label($MODE_ALL)+change-prompt($PROMPT_ALL)+reload($LIST)"
    --bind "ctrl-t:change-border-label($MODE_TMUX)+change-prompt($PROMPT_TMUX)+reload($LIST --tmux)"
    # ^o declines session rows: they have no directory to cd into, and switching
    # to one is what Enter already does.
    --bind "ctrl-o:transform:$SELF --open-bind {2}"
    --bind "ctrl-x:execute-silent($SELF --kill {2})+transform:
      case \$FZF_BORDER_LABEL in
        $MODE_TMUX) echo 'reload($LIST --tmux)' ;;
        $MODE_DIRS) echo 'reload($LIST --dirs)' ;;
        *) echo 'reload($LIST)' ;;
      esac"
  )
fi

TARGET=$(
  $LIST $START_MODE | fzf \
    --style minimal \
    --ansi \
    --no-sort \
    --delimiter=$'\t' \
    --with-nth 1 \
    --accept-nth 2 \
    --border-label=$START_LABEL \
    --prompt=$START_PROMPT \
    --header=$HEADER \
    --preview 'sesh preview {2}' \
    --preview-window 'right,60%' \
    $EXTRA_BINDS \
    --bind "ctrl-f:change-border-label($MODE_DIRS)+change-prompt($PROMPT_DIRS)+reload($LIST --dirs)" \
    --bind 'tab:down,btab:up' \
    --bind 'ctrl-u:half-page-up' \
    --bind 'ctrl-d:half-page-down'
)

[[ -n $TARGET ]] || exit 0

# Directory rows come straight from fd, which may leave a trailing slash.
TARGET=${TARGET%/}

case $ACTION in
  window)
    if [[ -n $REPLACE_PANE ]]; then
      exec tmux respawn-pane -k -c $TARGET 'nvim; zsh'
    fi
    exec tmux new-window -c $TARGET 'nvim; zsh' ;;
  session)
    exec sesh connect $TARGET ;;
esac
