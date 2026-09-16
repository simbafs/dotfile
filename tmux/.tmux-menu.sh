#!/usr/bin/env bash
set -u

readonly EXIT_CONTINUE=0
readonly EXIT_DISCONNECT=42
readonly LOG_FILE="${HOME:-/tmp}/.tmux-menu.log"
readonly FZF_HEIGHT="${TMUX_MENU_HEIGHT:-45%}"
LOG_ENABLED="${TMUX_MENU_LOG:-0}"

log() {
	[ "$LOG_ENABLED" = 1 ] || return 0
	printf '[%s] %s\n' "$(date '+%F %T')" "$*" >>"$LOG_FILE"
}

has_command() {
	command -v "$1" >/dev/null 2>&1
}

die_if_inside_tmux() {
	[ -n "${TMUX:-}" ] || return 0
	log "Already inside tmux, exiting"
	exit "$EXIT_CONTINUE"
}

require_terminal() {
	[ -t 0 ] && [ -t 1 ] && return 0
	log "Not running in an interactive terminal"
	exit "$EXIT_CONTINUE"
}

tmux_has_sessions() {
	tmux list-sessions >/dev/null 2>&1
}

is_ssh_session() {
	[ -n "${SSH_CONNECTION:-}" ]
}

session_count() {
	tmux list-sessions 2>/dev/null | wc -l | tr -d ' '
}

session_snapshot() {
	# Tabs are used as delimiters because tmux session names cannot contain them.
	tmux list-sessions -F $'#{session_name}\t#{session_windows}\t#{session_attached}' 2>/dev/null |
		sort -t $'\t' -k1,1
}

session_panes() {
	local session="$1"
	tmux list-windows -t "$session" -F '#{window_panes}' 2>/dev/null |
		awk '{ total += $1 } END { print total + 0 }'
}

session_rows() {
	local name windows attached panes state
	while IFS=$'\t' read -r name windows attached; do
		[ -n "$name" ] || continue
		panes="$(session_panes "$name")"
		if [ "${attached:-0}" -gt 0 ] 2>/dev/null; then
			state="attached"
		else
			state="detached"
		fi
		printf '%s\t%s windows · %s panes · %s\n' "$name" "$windows" "$panes" "$state"
	done < <(session_snapshot)
}

fzf_colors() {
	printf '%s' 'bg:-1,bg+:#EEF3F4,fg:#30343B,fg+:#176B78,hl:#176B78,hl+:#0F5964,pointer:#176B78,marker:#287A45,prompt:#176B78,info:#68707C,border:#AEB7C2,header:#68707C,spinner:#176B78'
}

fzf_select() {
	local prompt="$1"
	shift
	fzf \
		--height="$FZF_HEIGHT" \
		--layout=reverse \
		--border=rounded \
		--padding=1,2 \
		--no-multi \
		--cycle \
		--color="$(fzf_colors)" \
		--prompt="$prompt" \
		"$@"
}

host_label() {
	local host
	host="$(hostname -s 2>/dev/null || hostname 2>/dev/null || printf 'remote host')"
	printf '%s' "$host"
}

display_path() {
	local path="${PWD:-$HOME}"
	if [ -n "${HOME:-}" ] && [[ "$path" == "$HOME"/* ]]; then
		printf '%s/%s' '~' "${path#"$HOME"/}"
	elif [ "$path" = "${HOME:-}" ]; then
		printf '~'
	else
		printf '%s' "$path"
	fi
}

sanitize_name() {
	local value="$1"
	value="$(printf '%s' "$value" | tr -cs '[:alnum:]_.-' '-' | sed 's/^-*//; s/-*$//')"
	printf '%s' "${value:-main}"
}

default_session_name() {
	local current_dir host
	current_dir="${PWD:-${HOME:-/}}"
	host="$(host_label)"
	if [ -n "${HOME:-}" ] && [ "$current_dir" = "$HOME" ]; then
		sanitize_name "$host"
	else
		sanitize_name "$(basename "$current_dir")"
	fi
}

attach_session() {
	local session="$1"
	log "Attaching session: $session"
	clear
	tmux attach-session -t "$session"
	local rc=$?
	log "Returned from session: $session, rc=$rc"
	return "$rc"
}

create_or_attach_session() {
	local name="$1"
	if tmux has-session -t "$name" 2>/dev/null; then
		log "Session exists, attaching: $name"
		attach_session "$name"
		return $?
	fi
	log "Creating session: $name"
	clear
	tmux new-session -s "$name"
	local rc=$?
	log "Returned from new session: $name, rc=$rc"
	return "$rc"
}

prompt_session_name() {
	local default_name="$1" value
	printf '\n  Session name [%s]: ' "$default_name" >&2
	IFS= read -r value || return 1
	value="${value:-$default_name}"
	value="$(printf '%s' "$value" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')"
	[ -n "$value" ] || return 1
	printf '%s' "$value"
}

select_session() {
	local selected session header
	header="$(printf '  %s  ·  %s\n  %s\n' "$(host_label)" "$(display_path)" 'type to filter · enter attach · esc back')"
	selected="$(session_rows | fzf_select '  Attach  ' --header="$header" --delimiter=$'\t' --nth=1,2)" || return 1
	[ -n "$selected" ] || return 1
	session="${selected%%$'\t'*}"
	[ -n "$session" ] || return 1
	attach_session "$session"
}

show_sessions() {
	local selected header
	header="$(printf '  %s  ·  %s\n  %s\n' "$(host_label)" "$(display_path)" 'enter attach · esc back')"
	selected="$(session_rows | fzf_select '  Sessions  ' --header="$header" --delimiter=$'\t' --nth=1,2 --no-sort)" || return 1
	[ -n "$selected" ] || return 1
	attach_session "${selected%%$'\t'*}"
}
fallback_menu() {
	local choice name
	while true; do
		clear
		printf ' tmux / remote session\n'
		printf '%s\n' '────────────────────────────────────────'
		printf ' host: %s\n' "$(host_label)"
		printf '  cwd:  %s\n' "$(display_path)"
		printf ' sessions: %s\n\n' "$(session_count)"
		printf '  [a] Attach a session\n'
		printf '  [n] New session\n'
		printf '  [l] List sessions\n'
		printf '  [q] Continue without tmux\n'
		if is_ssh_session; then
			printf '  [x] Disconnect SSH\n'
		fi
		printf '\n'
		IFS= read -r -p '  Choose: ' choice || exit "$EXIT_CONTINUE"
		case "$choice" in
		a) tmux_has_sessions && select_session || true ;;
		n) name="$(prompt_session_name "$(default_session_name)")" && create_or_attach_session "$name" || true ;;
		l) tmux_has_sessions && show_sessions || true ;;
		q|'') clear; exit "$EXIT_CONTINUE" ;;
		x)
			if is_ssh_session; then
				clear
				exit "$EXIT_DISCONNECT"
			fi
			;;
		esac
	done
}

main_menu() {
	local choice name header menu
	while true; do
		header="$(printf '  %s  ·  %s\n  sessions: %s\n' "$(host_label)" "$(display_path)" "$(session_count)")"
		menu=$'a\tAttach a session\texisting sessions\n'
		menu+=$'n\tNew session\tstart from current directory\n'
		menu+=$'q\tContinue without tmux\treturn to the shell\n'
		if is_ssh_session; then
			menu+=$'x\tDisconnect SSH\tclose this connection\n'
		fi
		choice="$(printf '%s' "$menu" | fzf_select '  tmux  ' --header="$header" --delimiter=$'\t' --nth=2,3 --accept-nth=1)" || exit "$EXIT_CONTINUE"
		case "$choice" in
		a) tmux_has_sessions && select_session || true ;;
		n) name="$(prompt_session_name "$(default_session_name)")" && create_or_attach_session "$name" || true ;;
		q) clear; exit "$EXIT_CONTINUE" ;;
		x)
			if is_ssh_session; then
				clear
				exit "$EXIT_DISCONNECT"
			fi
			;;
		esac
	done
}

die_if_inside_tmux
require_terminal

if has_command tmux && has_command fzf; then
	main_menu
else
	fallback_menu
fi
