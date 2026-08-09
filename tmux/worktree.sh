#!/usr/bin/env zsh

# Git worktrees as tmux windows, one window per worktree.
#
#   worktree.sh picker            pick a worktree; also creates and deletes them
#   worktree.sh spread            a window for every worktree of this repo
#   worktree.sh open <path>       open (or jump to) a window for one worktree
#   worktree.sh add <branch>      create the worktree, then open its window
#   worktree.sh remove <path>     drop the worktree, its branch, and its window
#   worktree.sh list              "<icon> <branch>\t<path>" rows for the picker
#
# Worktrees live in .worktrees/<branch with / turned into +> inside the repo, so
# they travel with it and a single glob finds them all.
#
# Windows are named after the branch, which doubles as the lookup key: opening an
# existing worktree twice just selects the window that is already there.

emulate -L zsh
setopt null_glob

SELF=${${(%):-%N}:A}
WORKTREE_DIR=.worktrees
BASE_BRANCH=${WORKTREE_BASE_BRANCH:-main}

TAB=$'\t'
DIM=$'\e[2;90m'
RESET=$'\e[0m'
ICON_MAIN=$'\e[35m\ue725\e[39m'      # git-branch, for the main checkout
ICON_WORKTREE=$'\e[33m\ue725\e[39m'  # git-branch, for the rest
ICON_NOTIFICATION=$'\e[33m󰂞\e[39m'  # bell, matching Catppuccin's tmux flag
ICON_AGENT=$'\e[32m󰚩\e[39m'     # completed agent turn
HERE=$'\e[32m\u25cf\e[39m'           # marks the worktree we were opened from
NOT_HERE=' '                          # keeps the label column aligned

die() { print -ru2 -- "$1"; exit 1 }

# The repo this worktree belongs to, whether $PWD is the main checkout or one of
# the worktrees. --git-common-dir points at the shared .git for both.
repo_root() {
  local common
  common=$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null) || return 1
  print -r -- ${common:h}
}

branch_of() {
  git -C $1 rev-parse --abbrev-ref HEAD 2>/dev/null
}

# Worktree paths in the order git created them. git itself does not record a
# timestamp, but it makes one admin directory per worktree under .git/worktrees,
# and that directory's birth time never changes — mtime does, as soon as anything
# commits in the worktree. The main checkout has no admin dir, so it goes first.
worktrees_by_age() {
  local root=$1
  print -r -- $root
  # Sort by birth time, then map each admin dir back to its worktree path.
  stat -f '%B %N' $root/.git/worktrees/*(/) 2>/dev/null |
    sort -n |
    while read -r _ ADMIN; do
      [[ -r $ADMIN/gitdir ]] || continue
      # gitdir holds <worktree>/.git; strip that to get the worktree itself.
      print -r -- "${$(<$ADMIN/gitdir):h}"
    done
}

# tmux window names cannot contain a colon or period without confusing targets.
window_name() {
  print -r -- ${${1//:/-}//./-}
}

# Notification marker for the tmux window represented by a picker row. Missing
# windows are normal: a worktree does not get one until opened or spread.
notification_suffix() {
  local state
  state=$(tmux display-message -p -t "$1" '#{@agent_notification} #{window_bell_flag}' 2>/dev/null) ||
    return
  if [[ $state == '1 '* ]]; then
    print -r -- " $ICON_AGENT"
  elif [[ $state == *' 1' ]]; then
    print -r -- " $ICON_NOTIFICATION"
  fi
}

# Select the window for a worktree if it exists, otherwise create it.
# NB: never name a local "path" in zsh — it is tied to $PATH and would blank it.
open_window() {
  local dir=$1 name
  [[ -d $dir ]] || die "not a directory: $dir"

  # The main checkout is where the session already lives, so it has a window
  # already — the first one — rather than one named after its branch.
  if [[ $dir == $(repo_root) ]]; then
    tmux select-window -t '{start}'
    return 0
  fi

  name=$(window_name "$(branch_of $dir)")
  [[ -n $name ]] || name=${dir:t}

  # $2 is "background" when the caller wants the window made but not focused,
  # which is what spread needs so it does not yank you off the current window.
  if [[ ${2:-} == background ]]; then
    tmux list-windows -F '#{window_name}' | grep -qxF -- "$name" && return 0
    tmux new-window -d -n $name -c $dir
    return 0
  fi

  if tmux select-window -t "=$name" 2>/dev/null; then
    return 0
  fi
  tmux new-window -n $name -c $dir
}

ACTION=${1:-}
shift 2>/dev/null

case $ACTION in
  open)
    [[ -n ${1:-} ]] || die "usage: ${0:t} open <worktree-path>"
    open_window $1 ;;

  spread)
    ROOT=$(repo_root) || die "not in a git repository"
    # Deliberately sequential and oldest-first, so window order matches the order
    # the worktrees were created and stays stable between runs.
    for WT in $(worktrees_by_age $ROOT); do
      [[ $WT == $ROOT ]] && continue   # the session is already here
      open_window $WT background
    done

    # Windows opened earlier in this session, or in a previous run, sit wherever
    # they landed. Walk the same oldest-first order again and shuffle each window
    # to the end, so afterwards the window order matches the creation order.
    # Moving the active window makes tmux jump to window 1, so put focus back.
    WAS_ACTIVE=$(tmux display-message -p '#{window_id}' 2>/dev/null)
    for WT in $(worktrees_by_age $ROOT); do
      [[ $WT == $ROOT ]] && continue
      NAME=$(window_name "$(branch_of $WT)")
      # -a appends after the target; a bare {end} is an index already in use.
      [[ -n $NAME ]] && tmux move-window -d -a -s "=$NAME" -t "{end}" 2>/dev/null
    done
    tmux move-window -r 2>/dev/null   # close the gaps the moves leave behind
    [[ -n $WAS_ACTIVE ]] && tmux select-window -t $WAS_ACTIVE 2>/dev/null
    exit 0 ;;

  add)
    [[ -n ${1:-} ]] || die "usage: ${0:t} add <branch>"
    BRANCH=$1
    ROOT=$(repo_root) || die "not in a git repository"
    WT_PATH=$ROOT/$WORKTREE_DIR/${BRANCH//\//+}

    if [[ -d $WT_PATH ]]; then
      open_window $WT_PATH
      exit 0
    fi

    # Reuse the branch if it already exists; otherwise start it from the base.
    if git -C $ROOT show-ref --quiet --verify "refs/heads/$BRANCH"; then
      git -C $ROOT worktree add $WT_PATH $BRANCH || exit 1
    else
      git -C $ROOT worktree add -b $BRANCH $WT_PATH $BASE_BRANCH || exit 1
    fi
    open_window $WT_PATH ;;

  remove)
    [[ -n ${1:-} ]] || die "usage: ${0:t} remove <worktree-path>"
    WT_PATH=${1%/}
    ROOT=$(repo_root) || die "not in a git repository"
    # Compare resolved paths: tmux hands over /tmp where git reports /private/tmp.
    [[ ${WT_PATH:A} == ${ROOT:A} ]] && die "refusing to remove the main worktree"

    BRANCH=$(branch_of $WT_PATH)
    NAME=$(window_name $BRANCH)

    # Both of these refuse to discard work: `worktree remove` fails on a dirty
    # tree, `branch -d` on unmerged commits. Neither is forced here on purpose.
    git -C $ROOT worktree remove $WT_PATH || exit 1
    [[ -n $BRANCH && $BRANCH != HEAD ]] && git -C $ROOT branch -d $BRANCH
    [[ -n $NAME ]] && tmux kill-window -t "=$NAME" 2>/dev/null
    print -r -- "removed $WT_PATH" ;;

  list)
    ROOT=$(repo_root) || exit 0
    # $PWD needs :A because tmux hands us /tmp where git reports /private/tmp.
    CWD=${PWD:A}
    # Branch is the label because the path is just a sanitised copy of it; a
    # dimmed suffix marks the main checkout. Oldest first, matching `spread`.
    for WT in $(worktrees_by_age $ROOT); do
      BR=$(branch_of $WT)
      [[ ${WT:A} == $CWD ]] && MARK=$HERE || MARK=$NOT_HERE
      if [[ $WT == $ROOT ]]; then
        NOTICE=$(notification_suffix ':{start}')
        print -r -- "$MARK $ICON_MAIN $BR$NOTICE$DIM ${ROOT:t}$RESET$TAB$WT"
      else
        NOTICE=$(notification_suffix ":=$(window_name $BR)")
        print -r -- "$MARK $ICON_WORKTREE $BR$NOTICE$TAB$WT"
      fi
    done
    exit 0 ;;

  picker)
    repo_root >/dev/null || die "not in a git repository"
    TARGET=$(
      $SELF list | fzf \
        --style minimal \
        --ansi \
        --delimiter=$TAB \
        --with-nth 1 \
        --accept-nth 2 \
        --prompt=$'\ue725  ' \
        --header='enter window · ^o new · ^s spread · ^x delete' \
        --preview 'git -C {2} log --oneline --graph --decorate -20' \
        --preview-window 'right,60%' \
        --bind "ctrl-o:become($SELF prompt-add)" \
        --bind "ctrl-s:execute-silent($SELF spread)+reload($SELF list)" \
        --bind "ctrl-x:execute($SELF remove {2} || read -k1)+reload($SELF list)" \
        --bind 'tab:down,btab:up' \
        --bind 'ctrl-u:half-page-up' \
        --bind 'ctrl-d:half-page-down'
    )
    [[ -n $TARGET ]] || exit 0
    open_window $TARGET ;;

  prompt-add)
    # Reached through `become`, so the picker is gone and this owns the popup: a
    # successful create switches to the new window and the popup closes with it.
    # Cancelling puts the picker back rather than leaving an empty popup.
    #
    # fzf is the input box rather than a bare `read`: it brings line editing, and
    # Escape or ^D cancel cleanly without the terminal and the script fighting
    # over who echoes each keystroke. The candidate list is empty on purpose —
    # only the typed query matters.
    BRANCH=$(: | fzf --print-query --prompt='branch: ' \
      --header='enter create · esc cancel' --height=100% 2>/dev/null)
    [[ -n $BRANCH ]] || exec $SELF picker   # cancelled — back to the list
    # add opens the window itself; on failure hold the popup so the error is read.
    $SELF add $BRANCH || read -k1
    exit 0 ;;

  *)
    die "usage: ${0:t} picker | spread | open <path> | add <branch> | remove <path> | list" ;;
esac
