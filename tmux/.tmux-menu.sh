#!/usr/bin/env bash
set -u

LOG_FILE="${HOME}/.tmux-menu.log"
LOG_ENABLED=0

log() {
  [ "$LOG_ENABLED" -eq 1 ] || return 0
  printf '[%s] %s\n' "$(date '+%F %T')" "$*" >>"$LOG_FILE"
}

log "tmux-menu.sh started"
log "USER=${USER:-}"
log "SHELL=${SHELL:-}"
log "TMUX=${TMUX:-<empty>}"
log "SSH_CONNECTION=${SSH_CONNECTION:-<empty>}"
log "PWD=${PWD:-<empty>}"

# 已經在 tmux 內就不要再開
if [ -n "${TMUX:-}" ]; then
  log "Already inside tmux, exiting"
  exit 0
fi

cleanup_tmux() {
  log "cleanup_tmux"
  tmux start-server >/dev/null 2>&1 || true
  tmux list-sessions >/dev/null 2>&1 || true
}

has_fzf() {
  command -v fzf >/dev/null 2>&1
}

list_sessions_raw() {
  tmux list-sessions -F "#{session_name}|#{session_windows}|#{session_attached}" 2>/dev/null |
    awk -F'|' '
    $1 ~ /^[0-9]+$/ { print "0|" $0 }
    $1 !~ /^[0-9]+$/ { print "1|" $0 }
  ' |
    sort -t'|' -k1,1 -k2,2n -k2,2 |
    cut -d'|' -f2-
}

session_panes() {
  local name="$1"
  tmux list-windows -t "$name" -F "#{window_panes}" 2>/dev/null | awk '{s+=$1} END {print s+0}'
}

print_sessions_pretty() {
  local name windows attached panes
  local i=1
  local max_len=7
  local width
  local dash_line

  while IFS='|' read -r name windows attached; do
    [ -z "$name" ] && continue
    [ "${#name}" -gt "$max_len" ] && max_len="${#name}"
  done < <(list_sessions_raw)

  width=$((max_len > 14 ? 14 : max_len))
  width=$((width < 8 ? 8 : width))

  dash_line="$(printf '%*s' "$width" '' | tr ' ' '-')"

  printf '\n'
  printf "%-3s %-*s %-7s %-7s %-10s\n" "No" "$width" "Session" "Win" "Panes" "Attached"
  printf "%-3s %-*s %-7s %-7s %-10s\n" "---" "$width" "$dash_line" "-------" "-------" "----------"

  while IFS='|' read -r name windows attached; do
    [ -z "$name" ] && continue
    panes="$(session_panes "$name")"

    if [ "$attached" -gt 0 ]; then
      attached="yes($attached)"
    else
      attached="no"
    fi

    printf "%-3s %-*s %-7s %-7s %-10s\n" "$i" "$width" "$name" "$windows" "$panes" "$attached"
    i=$((i + 1))
  done < <(list_sessions_raw)

  printf '\n'
}

attach_session() {
  local session="$1"
  log "Attaching session: $session"
  tmux attach -t "$session"
  local rc=$?
  log "Detached/returned from session: $session, rc=$rc"
  return 0
}

create_or_attach_session() {
  local name="$1"

  if tmux has-session -t "$name" 2>/dev/null; then
    log "Session exists, attaching: $name"
    echo "Session '$name' already exists. Attaching..."
    tmux attach -t "$name"
    local rc=$?
    log "Detached/returned from existing session: $name, rc=$rc"
  else
    log "Creating new session: $name"
    tmux new -s "$name"
    local rc=$?
    log "Detached/returned from new session: $name, rc=$rc"
  fi

  return 0
}

select_session_fzf() {
  local selected session name windows attached panes attached_text

  log "select_session_fzf"

  selected="$(
    while IFS='|' read -r name windows attached; do
      [ -z "$name" ] && continue
      panes="$(session_panes "$name")"

      if [ "$attached" -gt 0 ]; then
        attached_text="attached:$attached"
      else
        attached_text="detached"
      fi

      printf '%-18s | w:%-2s | p:%-2s | %s\n' "$name" "$windows" "$panes" "$attached_text"
    done < <(list_sessions_raw) | fzf --prompt='Attach session > ' --height=40% --reverse
  )"

  [ -z "$selected" ] && {
    log "fzf selection empty"
    return 1
  }

  session="$(printf '%s\n' "$selected" | awk -F'|' '{print $1}' | xargs)"
  [ -n "$session" ] || {
    log "parsed session empty"
    return 1
  }

  attach_session "$session"
}

select_session_menu() {
  local sessions=()
  local name windows attached panes attached_text
  local i pick

  log "select_session_menu"

  while IFS='|' read -r name windows attached; do
    [ -n "$name" ] && sessions+=("$name")
  done < <(list_sessions_raw)

  [ "${#sessions[@]}" -gt 0 ] || {
    log "No sessions available for manual menu"
    return 1
  }

  max_len=4 # 最小寬度
  for name in "${sessions[@]}"; do
    [ "${#name}" -gt "$max_len" ] && max_len="${#name}"
  done

  while true; do
    echo "Select a session to attach:"
    i=1
    for name in "${sessions[@]}"; do
      windows="$(tmux list-windows -t "$name" 2>/dev/null | wc -l | awk '{print $1}')"
      panes="$(session_panes "$name")"
      attached="$(tmux list-sessions -F "#{session_name}|#{session_attached}" 2>/dev/null | awk -F'|' -v n="$name" '$1==n{print $2; exit}')"

      if [ -n "${attached:-}" ] && [ "$attached" -gt 0 ]; then
        attached_text="attached:$attached"
      else
        attached_text="detached"
      fi

      printf "%3d) %-*s (w:%s, p:%s, %s)\n" "$i" "$max_len" "$name" "$windows" "$panes" "$attached_text"
      i=$((i + 1))
    done
    printf "%3d) %-*s\n" 0 "$max_len" "Back"
    echo

    read -r -p "Number: " pick
    log "Manual menu pick: ${pick:-<empty>}"

    case "$pick" in
    0)
      return 1
      ;;
    '' | *[!0-9]*)
      echo "Invalid input. Please enter a number."
      echo
      continue
      ;;
    esac

    if [ "$pick" -lt 1 ] || [ "$pick" -gt "${#sessions[@]}" ]; then
      echo "Invalid choice. Please choose 0-${#sessions[@]}."
      echo
      continue
    fi

    attach_session "${sessions[$((pick - 1))]}"
    return 0
  done
}

create_session() {
  local default_name name

  default_name="$(basename "${PWD:-$HOME}" | tr -cs '[:alnum:]_.-' '_' | sed 's/^_//; s/_$//')"
  [ -n "$default_name" ] || default_name="main"

  read -r -p "New session name [$default_name]: " name
  name="${name:-$default_name}"
  name="$(printf '%s' "$name" | xargs)"

  log "Create session requested: ${name:-<empty>}"

  if [ -z "$name" ]; then
    echo "Session name cannot be empty."
    return 1
  fi

  create_or_attach_session "$name"
}

main_menu() {
  while true; do
    cleanup_tmux
    clear

    echo "==== tmux launcher ===="
    echo

    if tmux list-sessions >/dev/null 2>&1; then
      log "Existing sessions found"
      print_sessions_pretty
    else
      log "No existing tmux sessions"
      echo "No existing tmux sessions."
      echo
    fi

    echo "1) Attach existing session"
    echo "2) Create new session"
    echo "3) Continue to shell without tmux"
    echo "4) Disconnect SSH session"
    echo

    read -r -p "Choose: " choice
    log "Main menu choice: ${choice:-<empty>}"

    case "$choice" in
    1)
      if tmux list-sessions >/dev/null 2>&1; then
        if has_fzf; then
          select_session_fzf || true
        else
          select_session_menu || true
        fi
      else
        echo "No existing sessions."
        read -r -p "Press Enter to continue..."
      fi
      ;;
    2)
      create_session || true
      ;;
    3)
      log "Continue to shell without tmux selected"
      exit 0
      ;;
    4)
      log "Disconnect SSH session selected"
      exit 42
      ;;
    *) ;;
    esac
  done
}

main_menu
