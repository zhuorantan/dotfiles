#!/usr/bin/env zsh

set -e

PROJECTS=()

while [[ $# -gt 0 ]]; do
  case $1 in
    -p|--project)
      if [[ -d "$2" ]]; then
        PROJECTS+=("$(readlink -f "$2")")
      fi
      shift
      shift
      ;;
    -d|--directory)
      if [[ -d "$2" ]]; then
        PROJECTS+=("$2"/*)
      fi
      shift
      shift
      ;;
    --replace)
      REPLACE=true
      shift
      ;;
    *)
      echo "Unknown option $1" >&2
      exit 1
      ;;
  esac
done

if [[ -f ~/.z ]]; then
  NOW="$(date +%s)"
  typeset -A FRECENTS
  while read LINE; do
    IFS="|" read DIR RANK TIME <<< "$LINE"
    FRECENT=$((10000 * $RANK * (3.75 / (0.0001 * ($NOW - $TIME) + 1.25))))
    FRECENTS["$DIR"]=$FRECENT
  done < ~/.z
fi

RANKED_PROJECTS=$(for i in "${PROJECTS[@]}"; do FRECENT=${FRECENTS["$i"]-0}; echo "$FRECENT\t$i"; done)
IFS=$'\n' SORTED_PROJECTS=($(sort -t $'\t' -k 1 -g -r <<< "${RANKED_PROJECTS[*]}"))

PROJECT_WITH_NAMES=$(for i in "${SORTED_PROJECTS[@]}"; do DIR=$(echo "$i" | cut -f2); echo "$(basename "$DIR")\t$DIR"; done)

NAME_AND_DIR=$(printf "%s\n" "${PROJECT_WITH_NAMES[@]}" | fzf --with-nth 1 --delimiter='\t' --preview 'ls {2}')
IFS=$'\t' read PROJECT_NAME PROJECT_DIR <<< "$NAME_AND_DIR"

OPEN_NVIM="nvim; zsh" 
if [[ -z "$REPLACE" ]]; then
  tmux new-window -c "$PROJECT_DIR" "$OPEN_NVIM"
else
  tmux respawn-pane -k -c "$PROJECT_DIR" "$OPEN_NVIM"
fi
