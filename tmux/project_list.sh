#!/usr/bin/env zsh

# Rows for project_picker.sh: tmux sessions, project dirs and zoxide history.
#
# Ordering, in one place:
#
#   1. live tmux sessions
#   2. project dirs — ~/Workspace/* plus the dotfiles repos — interleaved and
#      ranked by zoxide
#   3. everything else zoxide knows, minus anything nested inside those projects
#      (zoxide still tracks those, so `z` reaches them)
#
# Directories that do not exist are skipped, so the project list stays valid on
# machines that only have some of them.
#
# Modes:
#   (default)   the full list above
#   --tmux      only live tmux sessions
#   --dirs      directory search under $HOME
#
# Rows are "<icon> <label>\t<target>": the icon is joined to the label with a
# space, the way sesh renders it, and the picker connects to the second field so
# nothing has to strip the icon back off. Icons are ours rather than sesh's, which
# is why projects get a glyph of their own instead of the generic zoxide one.

emulate -L zsh
setopt null_glob

TAB=$'\t'
DIM=$'\e[2;90m'
RESET=$'\e[0m'
WINDOW_LIMIT=4

# Nerd Font glyphs, coloured in the spirit of sesh's own source glyphs.
ICON_TMUX=$'\e[34m\e[39m'      # sesh's tmux glyph
ICON_PROJECT=$'\e[36m\e[39m'   # folder
ICON_DOTFILES=$'\e[35m\e[39m'  # folder-git
ICON_DIR=$'\e[36m\e[39m'       # sesh's zoxide glyph
ICON_NOTIFICATION=$'\e[33m󰂞\e[39m'  # bell, matching Catppuccin's tmux flag
ICON_AGENT=$'\e[32m󰚩\e[39m'     # completed agent turn

DOTFILES=${${(%):-%N}:A:h:h}
DOTFILE_DIRS=($DOTFILES ~/dotfiles)
PROJECTS=(~/Workspace/*(/) $DOTFILE_DIRS)

MODE=${1:-}

# Keep every associative-array subscript unquoted; assignment and lookup have to
# agree or the lookups silently miss.
typeset -A IS_PROJECT IS_DOTFILES
for DIR in $DOTFILE_DIRS; do
  DIR=${DIR%/}
  [[ -d $DIR ]] && IS_DOTFILES[$DIR]=1
done
for DIR in $PROJECTS; do
  DIR=${DIR%/}
  [[ -d $DIR ]] && IS_PROJECT[$DIR]=1
done

# True for paths *inside* a project, but not the project dirs themselves.
is_nested() {
  local path=$1 dots
  (( ${+IS_PROJECT[$path]} )) && return 1
  [[ $path == ~/Workspace/*/* ]] && return 0
  for dots in $DOTFILE_DIRS; do
    [[ $path == $dots/* ]] && return 0
  done
  return 1
}

# row <icon> <label> <target> — <target> is what gets passed to `sesh connect`.
# For live tmux sessions that is the session name, so sesh switches to the session
# instead of treating the path as a new one; everything else is a path.
row() {
  print -r -- "$1 $2$TAB$3"
}

# Window names trailing a tmux session, dimmed and capped like sesh's picker.
windows_text() {
  local -a names shown
  names=(${(f)"$(tmux list-windows -t "$1" -F '#{window_name}' 2>/dev/null)"})
  (( $#names )) || return
  shown=($names)
  if (( $#names > WINDOW_LIMIT )); then
    shown=(${names[1,WINDOW_LIMIT]} "+$(( $#names - WINDOW_LIMIT ))")
  fi
  print -r -- "$DIM ${(j: :)shown}$RESET"
}

session_has_agent_notification() {
  tmux list-windows -t "$1" -F '#{@agent_notification}' 2>/dev/null |
    grep -qx 1
}

# -- tmux sessions -------------------------------------------------------------

# A live session and its directory are the same destination, so remember the
# paths here and skip the duplicate row further down — same as `sesh list -d`,
# where the first (tmux) row wins.
typeset -A HAS_SESSION

if [[ $MODE != --dirs ]]; then
  while IFS=$TAB read -r NAME SPATH ALERTS; do
    [[ -n $NAME ]] || continue
    HAS_SESSION[${SPATH%/}]=1
    if session_has_agent_notification "$NAME"; then
      NOTICE=" $ICON_AGENT"
    elif [[ $ALERTS == *'!'* ]]; then
      NOTICE=" $ICON_NOTIFICATION"
    else
      NOTICE=
    fi
    row $ICON_TMUX "$NAME$NOTICE$(windows_text $NAME)" "$NAME"
  done < <(tmux list-sessions -F "#{session_name}${TAB}#{session_path}${TAB}#{session_alerts}" 2>/dev/null)
fi

[[ $MODE == --tmux ]] && exit 0

# -- plain directory search ----------------------------------------------------

if [[ $MODE == --dirs ]]; then
  # Depth 4 keeps this under a second; unbounded is ~300k dirs and ~25s.
  fd --type d --hidden --follow --exclude .git --max-depth 4 . $HOME 2>/dev/null |
    while read -r DIR; do
      DIR=${DIR%/}
      row $ICON_DIR "${DIR/#$HOME/~}" "$DIR"
    done
  exit 0
fi

# -- zoxide, split into projects and the rest ----------------------------------

PROJECT_ROWS=()
OTHER_ROWS=()
typeset -A LISTED

if (( $+commands[zoxide] )); then
  while read -r SCORE DIR; do
    (( ${+HAS_SESSION[$DIR]} )) && continue
    if (( ${+IS_PROJECT[$DIR]} )); then
      PROJECT_ROWS+=("$SCORE $DIR")
      LISTED[$DIR]=1
    elif ! is_nested $DIR; then
      OTHER_ROWS+=("$SCORE $DIR")
    fi
  done < <(zoxide query --list --score)
fi

# Projects zoxide has never seen still belong in the list, after the ranked ones.
for DIR in $PROJECTS; do
  DIR=${DIR%/}
  (( ${+IS_PROJECT[$DIR]} )) || continue
  (( ${+LISTED[$DIR]} )) && continue
  (( ${+HAS_SESSION[$DIR]} )) && continue
  LISTED[$DIR]=1
  PROJECT_ROWS+=("0 $DIR")
done

for ROW in $PROJECT_ROWS; do
  DIR=${ROW#* }
  if (( ${+IS_DOTFILES[$DIR]} )); then
    row $ICON_DOTFILES "${DIR:t}" "$DIR"
  else
    row $ICON_PROJECT "${DIR:t}" "$DIR"
  fi
done

for ROW in $OTHER_ROWS; do
  DIR=${ROW#* }
  row $ICON_DIR "${DIR/#$HOME/~}" "$DIR"
done
