#!/usr/bin/env zsh

# Git worktrees as tmux windows, one window per worktree.
#
#   worktree.sh picker            pick or create a worktree; also manages them
#   worktree.sh spread            a window for every worktree of this repo
#   worktree.sh open <path>       open (or jump to) a window for one worktree
#   worktree.sh add <branch>      create the worktree, then open its window
#   worktree.sh rename <path> <branch>
#                               reuse a base-synced worktree for a new branch
#   worktree.sh remove <path>     drop the worktree, its branch, and its window
#   worktree.sh list              label/path/branch/kind rows for the picker
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
ICON_BRANCH=$'\e[90m\e[39m'    # local branch without a worktree
ICON_NOTIFICATION=$'\e[33m󰂞\e[39m'  # bell, matching Catppuccin's tmux flag
ICON_AGENT=$'\e[32m󰚩\e[39m'     # completed agent turn
HERE=$'\e[32m●\e[39m'               # marks the worktree we were opened from
NOT_HERE=' '                          # keeps the label column aligned

die() { print -ru2 -- "$1"; exit 1 }

# zsh/stat keeps timestamp reads identical across BSD and GNU systems.
zmodload zsh/stat 2>/dev/null || die "cannot load zsh/stat"

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

# Worktree paths in creation/reuse order. Git creates a stable `gitdir` file in
# every linked worktree's admin directory, including worktrees created outside
# this script. Its mtime begins at creation, is unchanged by normal commits, and
# is bumped explicitly when this script reuses a worktree. The main checkout has
# no linked-worktree admin directory, so it goes first.
worktrees_by_age() {
  local root=$1 admin timestamp
  print -r -- $root
  # Sort by the portable epoch mtime, then map each admin directory back to its
  # worktree path. The final path also makes same-second ties deterministic.
  for admin in $root/.git/worktrees/*(/); do
    [[ -r $admin/gitdir ]] || continue
    timestamp=$(zstat +mtime $admin/gitdir 2>/dev/null) || continue
    print -r -- "$timestamp $admin"
  done |
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

# Find the immutable ID of the window that owns a worktree. Its initial manual
# name disables automatic renaming, but a user or application can still rename
# it later; the ID remains stable for the lifetime of the window.
window_id_for_worktree() {
  local worktree=${1:A} id pane_dir
  while IFS=$TAB read -r id pane_dir; do
    [[ -n $id && -n $pane_dir ]] || continue
    pane_dir=${pane_dir:A}
    if [[ $pane_dir == $worktree || $pane_dir == ${worktree}/* ]]; then
      print -r -- $id
      return 0
    fi
  done < <(tmux list-panes -a -F "#{window_id}$TAB#{pane_current_path}" 2>/dev/null)
  return 1
}

window_id_exists() {
  local wanted=$1 existing
  while IFS= read -r existing; do
    [[ $existing == $wanted ]] && return 0
  done < <(tmux list-windows -a -F '#{window_id}' 2>/dev/null)
  return 1
}

# Refuse a rename that would make the window-name lookup ambiguous inside the
# session that owns this worktree. Duplicate names are legal in tmux, but later
# `open` calls could then select the wrong window.
window_name_available() {
  local window_id=$1 wanted=$2 session_id existing_id existing_name
  [[ -n $window_id ]] || return 0
  session_id=$(tmux display-message -p -t "$window_id" '#{session_id}' 2>/dev/null) ||
    return 1
  while IFS=$TAB read -r existing_id existing_name; do
    [[ $existing_id == $window_id || $existing_name != $wanted ]] || return 1
  done < <(tmux list-windows -t "$session_id" -F "#{window_id}$TAB#{window_name}" 2>/dev/null)
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

  rename)
    [[ -n ${1:-} && -n ${2:-} ]] ||
      die "usage: ${0:t} rename <worktree-path> <new-branch>"
    WT_PATH=${1%/}
    NEW_BRANCH=$2
    ROOT=$(repo_root) || die "not in a git repository"
    [[ ${WT_PATH:A} == ${ROOT:A} ]] && die "refusing to rename the main worktree"
    [[ -d $WT_PATH ]] || die "not a directory: $WT_PATH"

    BRANCH=$(branch_of $WT_PATH)
    [[ -n $BRANCH && $BRANCH != HEAD ]] || die "refusing to rename a detached worktree"
    [[ $NEW_BRANCH != $BRANCH ]] || die "worktree is already named $NEW_BRANCH"
    git check-ref-format --branch "$NEW_BRANCH" >/dev/null 2>&1 ||
      die "invalid branch name: $NEW_BRANCH"
    git -C $ROOT show-ref --quiet --verify "refs/heads/$NEW_BRANCH" &&
      die "branch already exists: $NEW_BRANCH"

    # Reuse is intentionally stricter than deletion's merged-ancestry check.
    # The old branch must point at exactly the configured base commit, so a
    # rename cannot hide either unmerged work or an older, not-yet-updated base.
    HEAD_OID=$(git -C $WT_PATH rev-parse --verify 'HEAD^{commit}' 2>/dev/null) ||
      die "cannot resolve HEAD for $BRANCH"
    BASE_OID=$(git -C $ROOT rev-parse --verify "${BASE_BRANCH}^{commit}" 2>/dev/null) ||
      die "cannot resolve base branch: $BASE_BRANCH"
    [[ $HEAD_OID == $BASE_OID ]] ||
      die "refusing to rename $BRANCH: HEAD is not the same as $BASE_BRANCH"

    CHANGES=$(git -C $WT_PATH status --porcelain --untracked-files=all) ||
      die "cannot inspect worktree: $WT_PATH"
    [[ -z $CHANGES ]] || die "refusing to rename $BRANCH: worktree has changes"

    NEW_WT_PATH=$ROOT/$WORKTREE_DIR/${NEW_BRANCH//\//+}
    if [[ ${NEW_WT_PATH:A} != ${WT_PATH:A} ]]; then
      [[ ! -e $NEW_WT_PATH ]] || die "worktree path already exists: $NEW_WT_PATH"
    fi

    WINDOW_ID=$(window_id_for_worktree $WT_PATH)
    NEW_WINDOW_NAME=$(window_name $NEW_BRANCH)
    window_name_available "$WINDOW_ID" "$NEW_WINDOW_NAME" ||
      die "tmux window already exists: $NEW_WINDOW_NAME"

    # Let Git move the worktree so its administrative metadata follows the
    # directory. The owning tmux window is restarted below because the kernel
    # cwd follows a directory rename, but an interactive shell's logical $PWD
    # would otherwise keep the old path.
    if [[ ${NEW_WT_PATH:A} != ${WT_PATH:A} ]]; then
      mkdir -p $ROOT/$WORKTREE_DIR || exit 1
      git -C $ROOT worktree move $WT_PATH $NEW_WT_PATH || exit 1
    fi
    if ! git -C $NEW_WT_PATH branch -m $NEW_BRANCH; then
      # A successful preflight makes this unlikely, but restore the directory
      # when possible so a partial failure does not separate its old branch and
      # path names.
      if [[ ${NEW_WT_PATH:A} != ${WT_PATH:A} ]]; then
        git -C $ROOT worktree move $NEW_WT_PATH $WT_PATH 2>/dev/null
      fi
      die "failed to rename branch $BRANCH to $NEW_BRANCH"
    fi

    # Mark the successfully reused worktree as newest. This is Git's own
    # metadata file, present regardless of how the worktree was first created;
    # touching it changes no repository or worktree content.
    ADMIN_DIR=$(git -C $NEW_WT_PATH rev-parse --path-format=absolute --git-dir 2>/dev/null) ||
      die "renamed worktree, but cannot find its Git metadata"
    touch $ADMIN_DIR/gitdir ||
      die "renamed worktree, but failed to update its ordering timestamp"

    if [[ -n $WINDOW_ID ]] && window_id_exists $WINDOW_ID; then
      tmux rename-window -t "$WINDOW_ID" "$NEW_WINDOW_NAME" ||
        die "renamed worktree, but failed to rename tmux window $WINDOW_ID"
      # Restart panes separately rather than using respawn-window, which would
      # collapse a multi-pane layout. tmux now resolves each cwd through the
      # moved directory, including any pane that was in a subdirectory.
      PANE_RESTART_FAILED=0
      while IFS=$TAB read -r PANE_ID PANE_DIR; do
        [[ -n $PANE_ID && -n $PANE_DIR ]] || continue
        tmux respawn-pane -k -t "$PANE_ID" -c "$PANE_DIR" || PANE_RESTART_FAILED=1
      done < <(tmux list-panes -t "$WINDOW_ID" \
        -F "#{pane_id}$TAB#{pane_current_path}" 2>/dev/null)
      (( ! PANE_RESTART_FAILED )) ||
        die "renamed worktree, but failed to restart every pane in $WINDOW_ID"
    fi
    reorder_windows $ROOT
    print -r -- "renamed $BRANCH to $NEW_BRANCH" ;;

  remove)
    [[ -n ${1:-} ]] || die "usage: ${0:t} remove <worktree-path>"
    WT_PATH=${1%/}
    ROOT=$(repo_root) || die "not in a git repository"
    WINDOW_ID=${2:-}
    [[ -n $WINDOW_ID ]] || WINDOW_ID=$(window_id_for_worktree $WT_PATH)
    # Compare resolved paths: tmux hands over /tmp where git reports /private/tmp.
    [[ ${WT_PATH:A} == ${ROOT:A} ]] && die "refusing to remove the main worktree"

    BRANCH=$(branch_of $WT_PATH)

    # Check integration before removing the directory: `branch -d` also refuses
    # an unmerged branch, but by then the worktree would already be gone.
    [[ -n $BRANCH && $BRANCH != HEAD ]] || die "refusing to remove a detached worktree"
    git -C $ROOT merge-base --is-ancestor $BRANCH $BASE_BRANCH 2>/dev/null ||
      die "refusing to remove $BRANCH: not merged into $BASE_BRANCH"

    # Check the remaining conditions that `git worktree remove` protects before
    # closing the window. The removal below stays non-forced as a final guard.
    CHANGES=$(git -C $WT_PATH status --porcelain --untracked-files=all) ||
      die "cannot inspect worktree: $WT_PATH"
    [[ -z $CHANGES ]] || die "refusing to remove $BRANCH: worktree has changes"

    ADMIN_DIR=$(git -C $WT_PATH rev-parse --path-format=absolute --git-dir 2>/dev/null) ||
      die "cannot find worktree metadata: $WT_PATH"
    [[ ! -e $ADMIN_DIR/locked ]] || die "refusing to remove $BRANCH: worktree is locked"

    SUBMODULE_STATUS=$(git -C $WT_PATH submodule status --recursive 2>/dev/null) ||
      die "cannot inspect submodules: $WT_PATH"
    for SUBMODULE in ${(f)SUBMODULE_STATUS}; do
      [[ $SUBMODULE == -* ]] ||
        die "refusing to remove $BRANCH: worktree has an initialized submodule"
    done

    # Stop applications in the worktree before removing its files. Otherwise a
    # build tool can recreate ignored paths after Git removes the worktree but
    # before the old, name-based window cleanup runs.
    if [[ -n $WINDOW_ID ]] && window_id_exists $WINDOW_ID; then
      PANE_PROCESSES=(${(f)"$(tmux list-panes -t "$WINDOW_ID" -F '#{pane_pid}' 2>/dev/null)"})
      tmux kill-window -t "$WINDOW_ID" || die "failed to close tmux window $WINDOW_ID"
      for ATTEMPT in {1..20}; do
        PROCESS_ALIVE=0
        for PANE_PROCESS in $PANE_PROCESSES; do
          kill -0 $PANE_PROCESS 2>/dev/null && PROCESS_ALIVE=1
        done
        (( PROCESS_ALIVE )) || break
        sleep 0.05
      done
    fi

    # Neither Git operation is forced. After removal, briefly give external
    # watchers a chance to reveal themselves before deleting the branch.
    git -C $ROOT worktree remove $WT_PATH || exit 1
    sleep 0.1
    [[ ! -e $WT_PATH ]] ||
      die "worktree directory was recreated by a running app: $WT_PATH"
    git -C $ROOT branch -d $BRANCH || exit 1
    print -r -- "removed $WT_PATH" ;;

  remove-notify)
    [[ -n ${1:-} ]] || exit 1
    BRANCH=$(branch_of $1)
    [[ -n $BRANCH ]] || BRANCH=${1:t}
    REMOVE_ARGS=("$1")
    [[ -n ${2:-} ]] && REMOVE_ARGS+=("$2")
    OUTPUT=$($SELF remove "${REMOVE_ARGS[@]}" 2>&1)
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
    ROOT=$(repo_root) || exit 1
    WINDOW_ID=$(window_id_for_worktree $1)
    COMMAND="${(q)SELF} remove-notify ${(q)1}"
    [[ -n $WINDOW_ID ]] && COMMAND+=" ${(q)WINDOW_ID}"
    # Run from the main checkout so successful removal never deletes the
    # background worker's own current directory.
    tmux run-shell -b -c "$ROOT" "$COMMAND"
    exit 0 ;;

  confirm-remove)
    [[ -n ${1:-} ]] || exit 1
    [[ ${2:-worktree} == worktree ]] || exec $SELF picker
    BRANCH=$(branch_of $1)
    [[ -n $BRANCH ]] || BRANCH=${1:t}
    if confirm "delete $BRANCH? "; then
      $SELF remove-background $1
      exit 0
    fi
    exec $SELF picker ;;

  prompt-rename)
    [[ -n ${1:-} ]] || exit 1
    [[ ${2:-worktree} == worktree ]] || exec $SELF picker
    WT_PATH=$1
    BRANCH=$(branch_of $WT_PATH)
    [[ -n $BRANCH ]] || BRANCH=${WT_PATH:t}
    NEW_BRANCH=$(: | fzf --print-query --prompt='new branch: ' \
      --header="reuse $BRANCH + restart window · enter rename · esc cancel" \
      --height=100% 2>/dev/null)
    [[ -n $NEW_BRANCH ]] || exec $SELF picker
    $SELF rename $WT_PATH $NEW_BRANCH || read -k1
    exit 0 ;;

  create-selected)
    [[ -n ${1:-} ]] || exit 1
    [[ ${2:-} == branch ]] || exec $SELF picker
    $SELF add $1 || read -k1
    exit 0 ;;

  list)
    ROOT=$(repo_root) || exit 0
    # $PWD needs :A because tmux hands us /tmp where git reports /private/tmp.
    CWD=${PWD:A}
    # Branch is the label because the path is just a sanitised copy of it; a
    # dimmed suffix marks the main checkout. Local branches without a worktree
    # follow the worktrees and use the repository root for their log preview.
    #
    # Rows carrying an alert float to the top, in the order the icons imply:
    # finished agent turn, then working, then bell. One bucket per tier keeps
    # each tier oldest-first — matching `spread` — without a sort pass.
    TIERS=('' '' '' '')
    typeset -A ATTACHED_BRANCHES
    for WT in $(worktrees_by_age $ROOT); do
      BR=$(branch_of $WT)
      [[ -n $BR && $BR != HEAD ]] && ATTACHED_BRANCHES[$BR]=1
      [[ ${WT:A} == $CWD ]] && MARK=$HERE || MARK=$NOT_HERE
      if [[ $WT == $ROOT ]]; then
        notification_suffix ':{start}'
        ROW="$MARK $ICON_MAIN $BR$NOTICE$DIM ${ROOT:t}$RESET$TAB$WT$TAB$BR${TAB}worktree"
      else
        NAME=$(window_name $BR)
        notification_suffix ":=$NAME" "$NAME"
        ROW="$MARK $ICON_WORKTREE $BR$NOTICE$TAB$WT$TAB$BR${TAB}worktree"
      fi
      TIERS[$NOTICE_TIER]+="$ROW"$'\n'
    done
    print -rn -- ${(j::)TIERS}
    while IFS= read -r BR; do
      [[ -n $BR && -z ${ATTACHED_BRANCHES[$BR]:-} ]] || continue
      print -r -- "$NOT_HERE $ICON_BRANCH $BR$TAB$ROOT$TAB$BR${TAB}branch"
    done < <(git -C $ROOT for-each-ref --sort=refname \
      --format='%(refname:short)' refs/heads)
    exit 0 ;;

  picker)
    repo_root >/dev/null || die "not in a git repository"
    SELECTION=$(
      $SELF list | fzf \
        --style minimal \
        --ansi \
        --delimiter=$TAB \
        --with-nth 1 \
        --accept-nth 2,3,4 \
        --prompt='  ' \
        --header='^o new · ^w worktree · ^r rename · ^s spread · ^x delete' \
        --preview 'git -C {2} log --oneline --graph --decorate -20 {3} --' \
        --preview-window 'right,60%' \
        --bind "ctrl-o:become($SELF prompt-add)" \
        --bind "ctrl-w:become($SELF create-selected {3} {4})" \
        --bind "ctrl-r:become($SELF prompt-rename {2} {4})" \
        --bind "ctrl-s:execute-silent($SELF spread)+reload($SELF list)" \
        --bind "ctrl-x:become($SELF confirm-remove {2} {4})" \
        --bind 'tab:down,btab:up' \
        --bind 'ctrl-u:half-page-up' \
        --bind 'ctrl-d:half-page-down'
    )
    [[ -n $SELECTION ]] || exit 0
    IFS=$TAB read -r TARGET BRANCH KIND <<< $SELECTION
    if [[ $KIND == branch ]]; then
      $SELF add $BRANCH || read -k1
    else
      open_window $TARGET
    fi ;;

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
    die "usage: ${0:t} picker | spread | open <path> | add <branch> | rename <path> <branch> | remove <path> | list" ;;
esac
