# shellcheck shell=bash
# Read-only verbs: roster, peek, tail.

# Emit TSV: addr, pid, state(idle|busy), sessionId, title
# Self-row gets a trailing '*' on ADDR (display-only marker; strip before
# passing to other verbs). Self is detected only when $CLAUDE_DM_SOCKET
# matches the socket from $TMUX; cross-socket runs show no marker.
dm_roster() {
  local self_addr=""
  if [[ -n "${TMUX:-}" && -n "${TMUX_PANE:-}" && "${TMUX%%,*}" == "$SOCKET" ]]; then
    self_addr=$(tm display-message -p -t "$TMUX_PANE" \
      '#{session_name}:#{window_index}.#{pane_index}' 2>/dev/null || true)
  fi

  # No pre-filter on pane_current_command: when execve received the resolved
  # version path (basename "2.1.X") rather than the "claude" symlink, comm and
  # therefore #{pane_current_command} hold the version string, not "claude".
  # pane_to_claude_pid is the authoritative gate.
  tm list-panes -a \
      -F '#{pane_pid}	#{session_name}:#{window_index}.#{pane_index}	#{pane_title}' \
    | while IFS=$'\t' read -r pane_pid addr title; do
        local state cpid sid marker=""
        cpid=$(pane_to_claude_pid "$pane_pid") || continue
        case "$title" in
          '✳'*) state='idle'  ;;
          *)    state='busy'  ;;
        esac
        sid=$(pid_to_sid "$cpid" || true)
        [[ -n "$self_addr" && "$addr" == "$self_addr" ]] && marker="*"
        printf '%s%s\t%s\t%s\t%s\t%s\n' "$addr" "$marker" "$cpid" "$state" "$sid" "$title"
      done
}

dm_peek() {
  local target="$1" n="${2:-30}"
  local tr
  tr=$(target_transcript "$target") || die "no transcript for $target"
  jq -r '
    select(.type=="assistant")
    | .message.content[]?
    | select(.type=="text")
    | .text
  ' "$tr" | tail -n "$n"
}

dm_tail() {
  local target="$1"
  local tr
  tr=$(target_transcript "$target") || die "no transcript for $target"
  tail -n 0 -F "$tr" | jq -rc --unbuffered '
    if .type=="assistant" then
      (.message.content[]? | select(.type=="text") | "A> " + .text),
      (.message.content[]? | select(.type=="tool_use") | "A> [tool] " + .name + " " + (.input|tostring|.[0:200]))
    elif .type=="user" then
      if (.message.content|type)=="string" then "U> " + .message.content
      else (.message.content[]? | select(.type=="text") | "U> " + .text)
      end
    else empty
    end
  '
}
