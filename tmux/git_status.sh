#!/usr/bin/env zsh

# Render the Git state for the repository containing the active pane. Ahead and
# behind are relative to the locally cached upstream ref; status-bar refreshes
# must never perform network I/O.
emulate -L zsh

PANE_PATH=${1:-}
TEXT_BG=${2:-default}
CRUST=${3:-black}
FOREGROUND=${4:-white}
GREEN=${5:-green}
BLUE=${6:-blue}
YELLOW=${7:-yellow}

[[ -n $PANE_PATH ]] || exit 0

STATUS=$(git -C "$PANE_PATH" status --porcelain=v2 --branch --untracked-files=normal 2>/dev/null) || exit 0

BRANCH=
OID=
AHEAD=0
BEHIND=0
CHANGED=0

while IFS= read -r LINE; do
  case $LINE in
    '# branch.head '*) BRANCH=${LINE#\# branch.head } ;;
    '# branch.oid '*) OID=${LINE#\# branch.oid } ;;
    '# branch.ab '*)
      AHEAD=${LINE#*+}
      AHEAD=${AHEAD%% *}
      BEHIND=${LINE##* -}
      ;;
    '1 '*|'2 '*|'u '*|'? '*) (( CHANGED++ )) ;;
  esac
done <<< "$STATUS"

if [[ $BRANCH == '(detached)' ]]; then
  BRANCH="@${OID[1,7]}"
fi

[[ -n $BRANCH ]] || exit 0

# Shell output from #() is parsed as a tmux format. A doubled hash renders a
# literal one, keeping unusual but valid branch names from becoming formats.
BRANCH=${BRANCH//\#/\#\#}

print -n -r -- "#[fg=$GREEN,bg=default]#[fg=$CRUST,bg=$GREEN] #[fg=$FOREGROUND,bg=$TEXT_BG] $BRANCH"
(( AHEAD > 0 )) && print -n -r -- " #[fg=$GREEN,bg=$TEXT_BG]↑$AHEAD"
(( BEHIND > 0 )) && print -n -r -- " #[fg=$BLUE,bg=$TEXT_BG]↓$BEHIND"
(( CHANGED > 0 )) && print -n -r -- " #[fg=$YELLOW,bg=$TEXT_BG]±$CHANGED"
print -n -r -- "#[fg=$TEXT_BG,bg=$TEXT_BG] "
