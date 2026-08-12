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
ICON_AGENT_WORKING=$'\e[36m▶\e[39m'  # agent turn in progress

TAB=$'\t'
DIM=$'\e[2;90m'
RESET=$'\e[0m'
ICON_MAIN=$'\e[35m\e[39m'      # git-branch, for the main checkout
ICON_WORKTREE=$'\e[33m\e[39m'  # git-branch, for the rest
ICON_NOTIFICATION=$'\e[33m󰂞\e[39m'  # bell, matching Catppuccin's tmux flag
ICON_AGENT=$'\e[32m󰚩\e[39m'     # completed agent turn
HERE=$'\e[32m●\e[39m'               # marks the worktree we were opened from
NOT_HERE=' '                          # keeps the label column aligned

die() { print -ru2 -- "$1"; exit 1 }

confirm() {
  local answer
  answer=$(print -r -- confirm | fzf \
    --style minimal \
    --disabled \
    --no-info \
    --prompt="$1" \
    --header='enter/y confirm · esc/n cancel' \
    --bind 'y:accept,n:abort')
  [[ $answer == confirm ]]
}

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

# Agent or bell marker for the tmux window represented by a picker row. Missing
# windows are normal: a worktree does not get one until opened or spread.
#
# Sets two globals rather than printing, so the caller gets the alert tier as well
# as the icon: a command substitution would run this in a subshell and strip the
# tier off. NOTICE is the icon (empty when quiet); NOTICE_TIER groups the row —
# 1 agent, 2 working, 3 bell, 4 none.
notification_suffix() {
  local target=$1 expected=${2:-} actual state
  NOTICE= NOTICE_TIER=4
  if [[ -n $expected ]]; then
    actual=$(tmux display-message -p -t "$target" '#{window_name}' 2>/dev/null) ||
      return
    # tmux falls back to the current window when an exact named target is
    # missing, so reject that fallback before reading its alert state.
    [[ $actual == $expected ]] || return
  fi
  state=$(tmux display-message -p -t "$target" '#{E:@agent_alert_state}' 2>/dev/null) ||
    return
  # A completed agent turn is more specific than the BEL it also emits.
  case $state in
    1\|*) NOTICE=" $ICON_AGENT" NOTICE_TIER=1 ;;
    *\|1\|*) NOTICE=" $ICON_AGENT_WORKING" NOTICE_TIER=2 ;;
    *\|1) NOTICE=" $ICON_NOTIFICATION" NOTICE_TIER=3 ;;
  esac
}

# Put existing worktree windows in creation order while preserving focus. This
# is separate from creating them: `open` should order the windows already in the
# session, while `spread` first makes sure every worktree has one.
reorder_windows() {
  local root=$1 active wt name
  active=$(tmux display-message -p '#{window_id}' 2>/dev/null)
  for wt in $(worktrees_by_age $root); do
    [[ $wt == $root ]] && continue
    name=$(window_name "$(branch_of $wt)")
    # -a appends after the target; a bare {end} is an index already in use.
    [[ -n $name ]] && tmux move-window -d -a -s "=$name" -t '{end}' 2>/dev/null
  done
  tmux move-window -r 2>/dev/null   # close the gaps the moves leave behind
  [[ -n $active ]] && tmux select-window -t $active 2>/dev/null
}

# Select the window for a worktree if it exists, otherwise create it.
# NB: never name a local "path" in zsh — it is tied to $PATH and would blank it.
open_window() {
  local dir=$1 name root
  [[ -d $dir ]] || die "not a directory: $dir"
  root=$(repo_root) || die "not in a git repository"

  # The main checkout is where the session already lives, so it has a window
  # already — the first one — rather than one named after its branch.
  if [[ $dir == $root ]]; then
    tmux select-window -t '{start}'
    reorder_windows $root
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

  if ! tmux select-window -t "=$name" 2>/dev/null; then
    tmux new-window -n $name -c $dir
  fi
  reorder_windows $root
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

    reorder_windows $ROOT
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

    # Check integration before removing the directory: `branch -d` also refuses
    # an unmerged branch, but by then the worktree would already be gone.
    [[ -n $BRANCH && $BRANCH != HEAD ]] || die "refusing to remove a detached worktree"
    git -C $ROOT merge-base --is-ancestor $BRANCH $BASE_BRANCH 2>/dev/null ||
      die "refusing to remove $BRANCH: not merged into $BASE_BRANCH"

    # Neither operation is forced: removal still protects dirty worktrees, and
    # branch deletion remains a second check against discarding commits.
    git -C $ROOT worktree remove $WT_PATH || exit 1
    git -C $ROOT branch -d $BRANCH || exit 1
    [[ -n $NAME ]] && tmux kill-window -t "=$NAME" 2>/dev/null
    print -r -- "removed $WT_PATH" ;;

  remove-notify)
    [[ -n ${1:-} ]] || exit 1
    BRANCH=$(branch_of $1)
    [[ -n $BRANCH ]] || BRANCH=${1:t}
    OUTPUT=$($SELF remove $1 2>&1)
    STATUS=$?
    if (( STATUS != 0 )); then
      OUTPUT=${OUTPUT//$'\n'/ }
      tmux display-message -d 10000 "worktree deletion failed: $OUTPUT" 2>/dev/null
    else
      tmux display-message -d 5000 "worktree deleted: $BRANCH" 2>/dev/null
    fi
    exit $STATUS ;;

  remove-background)
    [[ -n ${1:-} ]] || exit 1
    # Let the tmux server own the worker. A nohup child launched from the
    # confirmation picker can receive SIGHUP before it finishes starting when
    # the popup closes immediately afterwards.
    COMMAND="${(q)SELF} remove-notify ${(q)1}"
    tmux run-shell -b -c "$PWD" "$COMMAND"
    exit 0 ;;

  confirm-remove)
    [[ -n ${1:-} ]] || exit 1
    BRANCH=$(branch_of $1)
    [[ -n $BRANCH ]] || BRANCH=${1:t}
    if confirm "delete $BRANCH? "; then
      $SELF remove-background $1
      exit 0
    fi
    exec $SELF picker ;;

  list)
    ROOT=$(repo_root) || exit 0
    # $PWD needs :A because tmux hands us /tmp where git reports /private/tmp.
    CWD=${PWD:A}
    # Branch is the label because the path is just a sanitised copy of it; a
    # dimmed suffix marks the main checkout.
    #
    # Rows carrying an alert float to the top, in the order the icons imply:
    # finished agent turn, then working, then bell. One bucket per tier keeps
    # each tier oldest-first — matching `spread` — without a sort pass.
    TIERS=('' '' '' '')
    for WT in $(worktrees_by_age $ROOT); do
      BR=$(branch_of $WT)
      [[ ${WT:A} == $CWD ]] && MARK=$HERE || MARK=$NOT_HERE
      if [[ $WT == $ROOT ]]; then
        notification_suffix ':{start}'
        ROW="$MARK $ICON_MAIN $BR$NOTICE$DIM ${ROOT:t}$RESET$TAB$WT"
      else
        NAME=$(window_name $BR)
        notification_suffix ":=$NAME" "$NAME"
        ROW="$MARK $ICON_WORKTREE $BR$NOTICE$TAB$WT"
      fi
      TIERS[$NOTICE_TIER]+="$ROW"$'\n'
    done
    print -rn -- ${(j::)TIERS}
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
        --prompt='  ' \
        --header='enter window · ^o new · ^s spread · ^x delete' \
        --preview 'git -C {2} log --oneline --graph --decorate -20' \
        --preview-window 'right,60%' \
        --bind "ctrl-o:become($SELF prompt-add)" \
        --bind "ctrl-s:execute-silent($SELF spread)+reload($SELF list)" \
        --bind "ctrl-x:become($SELF confirm-remove {2})" \
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
