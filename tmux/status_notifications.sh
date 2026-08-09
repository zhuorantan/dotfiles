#!/usr/bin/env zsh

# Render a persistent-alert pill for other sessions. The current-session pill
# stays entirely in tmux.conf so prefix-state color changes remain synchronous.
emulate -L zsh

CURRENT_SESSION=${1:-}
TAB=$'\t'
typeset -A STATE

while IFS=$TAB read -r SESSION AGENT WORKING BELL; do
  [[ -n $SESSION && $SESSION != $CURRENT_SESSION ]] || continue

  # A completed Codex turn is more specific than the BEL it also emits.
  if [[ $AGENT == 1 ]]; then
    STATE[$SESSION]=agent
  elif [[ $WORKING == 1 && ${STATE[$SESSION]:-} != agent ]]; then
    STATE[$SESSION]=working
  elif [[ $BELL == 1 && -z ${STATE[$SESSION]:-} ]]; then
    STATE[$SESSION]=bell
  fi
done < <(
  tmux list-windows -a \
    -F "#{session_name}${TAB}#{==:#{@agent_notification},1}${TAB}#{m/r:(^|[|])[⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏] ,#{P:#{pane_title}|}}${TAB}#{window_bell_flag}" \
    2>/dev/null
)

typeset -a AGENT_SESSIONS WORKING_SESSIONS BELL_SESSIONS
for SESSION in ${(f)"$(tmux list-sessions -F '#{session_name}' 2>/dev/null)"}; do
  case ${STATE[$SESSION]:-} in
    agent) AGENT_SESSIONS+=($SESSION) ;;
    working) WORKING_SESSIONS+=($SESSION) ;;
    bell) BELL_SESSIONS+=($SESSION) ;;
  esac
done

status_pill() {
  local label=$1 icon=$2 accent=$3 end_bg=$4 output
  output=${PILL_FORMAT//\%a/$accent}
  output=${output//\%i/$icon}
  output=${output//\%b/$end_bg}
  output=${output//\%s/$label}
  print -n -r -- "$output"
}

TOTAL=$(( $#AGENT_SESSIONS + $#WORKING_SESSIONS + $#BELL_SESSIONS ))
if (( TOTAL > 1 )); then
  if (( $#AGENT_SESSIONS )); then
    ALERT_TYPE=agent_notification
  elif (( $#WORKING_SESSIONS )); then
    ALERT_TYPE=agent_working
  else
    ALERT_TYPE=bell_notification
  fi
  ALERT_LABEL="$TOTAL sessions"
elif (( $#AGENT_SESSIONS )); then
  ALERT_TYPE=agent_notification
  ALERT_LABEL=${AGENT_SESSIONS[1]}
elif (( $#WORKING_SESSIONS )); then
  ALERT_TYPE=agent_working
  ALERT_LABEL=${WORKING_SESSIONS[1]}
elif (( $#BELL_SESSIONS )); then
  ALERT_TYPE=bell_notification
  ALERT_LABEL=${BELL_SESSIONS[1]}
fi

PILL_FORMAT=$(tmux show-option -gv @_status_pill_format 2>/dev/null) || exit 0
HAS_ALERT=0
[[ -n ${ALERT_TYPE:-} ]] && HAS_ALERT=1

# Cache only the presence of the following pill. Tmux uses this session option
# to choose the current pill's end-cap background synchronously; avoid writing
# an unchanged value, which would trigger an unnecessary status redraw.
CACHED_HAS_ALERT=$(tmux show-option -qv -t "$CURRENT_SESSION" @_status_has_notification)
if [[ $CACHED_HAS_ALERT != $HAS_ALERT ]]; then
  tmux set-option -q -t "$CURRENT_SESSION" @_status_has_notification $HAS_ALERT
fi

if [[ -n ${ALERT_TYPE:-} ]]; then
  ALERT_ICON=$(tmux show-option -gv "@${ALERT_TYPE}_icon" 2>/dev/null) || exit 0
  ALERT_ACCENT=$(tmux show-option -gv "@${ALERT_TYPE}_status_accent" 2>/dev/null) || exit 0
  status_pill "$ALERT_LABEL" "$ALERT_ICON" "$ALERT_ACCENT" default
fi
print
