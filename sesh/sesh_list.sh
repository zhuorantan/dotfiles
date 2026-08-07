#!/usr/bin/env zsh

# Frecency provider for sesh (wired up via `[frecency] list_command`).
#
# Emits "<score> <path>" lines and sesh keeps this order, so this is where the
# session list is shaped:
#
#   1. project roots (~/Workspace/* and the dotfiles repo) come first, in
#      zoxide's own ranking order
#   2. directories nested inside those roots are dropped, since a session per
#      subdirectory is rarely useful — zoxide still tracks them for `z`
#   3. everything else zoxide knows follows, untouched
#
# Directories that do not exist are skipped, so the project list stays valid on
# machines that only have some of them.

emulate -L zsh
setopt null_glob

DOTFILES=${${(%):-%N}:A:h:h}
ROOTS=(~/Workspace $DOTFILES)
PROJECTS=(~/Workspace/*(/) $DOTFILES)

# Subscript quoting has to match between assignment and lookup, so keep every
# subscript unquoted.
typeset -A IS_PROJECT
for DIR in $PROJECTS; do
  DIR=${DIR%/}
  [[ -d $DIR ]] || continue
  IS_PROJECT[$DIR]=1
done

# True for paths nested *inside* a root, excluding the project dirs themselves.
is_nested() {
  local path=$1 root
  (( ${+IS_PROJECT[$path]} )) && return 1
  for root in $ROOTS; do
    [[ $path == $root/*/* || $path == $DOTFILES/* ]] && return 0
  done
  return 1
}

PROJECT_ROWS=()
OTHER_ROWS=()
typeset -A LISTED

if (( $+commands[zoxide] )); then
  while read -r SCORE DIR; do
    if (( ${+IS_PROJECT[$DIR]} )); then
      PROJECT_ROWS+=("$SCORE $DIR")
      LISTED[$DIR]=1
    elif ! is_nested $DIR; then
      OTHER_ROWS+=("$SCORE $DIR")
    fi
  done < <(zoxide query --list --score)
fi

# Projects zoxide has never seen still belong in the list, at the bottom of the
# group. Iterate $PROJECTS so their order is stable.
for DIR in $PROJECTS; do
  DIR=${DIR%/}
  (( ${+IS_PROJECT[$DIR]} )) || continue
  (( ${+LISTED[$DIR]} )) && continue
  LISTED[$DIR]=1
  PROJECT_ROWS+=("0 $DIR")
done

print -rl -- $PROJECT_ROWS $OTHER_ROWS
