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

DIALOG="$(command -v dialog 2>/dev/null)"

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

attach_session() {
	local session="$1"
	log "Attaching session: $session"
	clear
	tmux attach -t "$session"
	local rc=$?
	log "Detached/returned from session: $session, rc=$rc"
	return 0
}

create_or_attach_session() {
	local name="$1"

	if tmux has-session -t "$name" 2>/dev/null; then
		log "Session exists, attaching: $name"
		if [ -n "$DIALOG" ]; then
			dialog --msgbox "Session '$name' already exists.  Attaching..." 6 50
			clear
		else
			echo "Session '$name' already exists. Attaching..."
		fi
		tmux attach -t "$name"
		local rc=$?
		log "Detached/returned from existing session: $name, rc=$rc"
	else
		log "Creating new session: $name"
		clear
		tmux new -s "$name"
		local rc=$?
		log "Detached/returned from new session: $name, rc=$rc"
	fi

	return 0
}

# ── dialog-based session selector ──────────────────────────────────────
session_menu_items() {
	local name windows attached panes

	while IFS='|' read -r name windows attached; do
		[ -z "$name" ] && continue
		panes="$(session_panes "$name")"

		local tag
		if [ "$attached" -gt 0 ]; then
			tag="w:${windows} p:${panes} [attached:${attached}]"
		else
			tag="w:${windows} p:${panes} [detached]"
		fi

		printf '%s\n%s\n' "$name" "$tag"
	done < <(list_sessions_raw)
}

session_menu_count() {
	list_sessions_raw | wc -l
}

select_session_dialog() {
	local menu_args=()
	local tag item

	while IFS= read -r tag && IFS= read -r item; do
		[ -z "$tag" ] && continue
		menu_args+=("$tag" "$item")
	done < <(session_menu_items)

	if [ "${#menu_args[@]}" -eq 0 ]; then
		dialog --msgbox "No existing sessions found." 6 40
		return 1
	fi

	# dialog --menu outputs the chosen tag to stderr
	local choice
	choice="$(dialog \
		--clear \
		--title " Attach Session " \
		--menu "Select a tmux session:" 0 0 0 \
		"${menu_args[@]}" \
		2>&1 >/dev/tty)"

	[ -z "${choice:-}" ] && {
		log "dialog session selection cancelled"
		return 1
	}

	attach_session "$choice"
}

# ── fzf-based session selector ─────────────────────────────────────────
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

select_session() {
	if has_fzf; then
		select_session_fzf || true
	elif [ -n "$DIALOG" ]; then
		select_session_dialog || true
	else
		echo "No fzf or dialog available."
		sleep 1
	fi
}

# ── create session ─────────────────────────────────────────────────────
create_session() {
	local default_name name

	default_name="$(basename "${PWD:-$HOME}" | tr -cs '[:alnum:]_.-' '_' | sed 's/^_//; s/_$//')"
	[ -n "$default_name" ] || default_name="main"

	if [ -n "$DIALOG" ]; then
		name="$(dialog \
			--clear \
			--title " New Session " \
			--inputbox "Enter session name:" 0 0 "$default_name" \
			2>&1 >/dev/tty)"

		[ -z "${name:-}" ] && {
			log "Create session cancelled"
			return 1
		}
	else
		read -r -p "New session name [$default_name]: " name
	fi

	name="${name:-$default_name}"
	name="$(printf '%s' "$name" | xargs)"

	log "Create session requested: ${name:-<empty>}"

	if [ -z "$name" ]; then
		if [ -n "$DIALOG" ]; then
			dialog --msgbox "Session name cannot be empty." 6 40
		else
			echo "Session name cannot be empty."
		fi
		return 1
	fi

	create_or_attach_session "$name"
}

# ── session overview ───────────────────────────────────────────────────
session_overview_text() {
	local name windows attached panes
	local body=""
	local max_name=7
	local names=()

	while IFS='|' read -r name windows attached; do
		[ -z "$name" ] && continue
		names+=("$name")
		[ "${#name}" -gt "$max_name" ] && max_name="${#name}"
	done < <(list_sessions_raw)

	local width="$((max_name > 14 ? 14 : max_name))"
	width="$((width < 8 ? 8 : width))"

	local header sep
	header="$(printf "%-${width}s | Win | Panes | Attached" "Session")"
	sep="$(printf "%-${width}s-+-----+-------+----------" "$(printf '%*s' "$width" '' | tr ' ' '-')")"
	body="${header}\n${sep}\n"

	while IFS='|' read -r name windows attached; do
		[ -z "$name" ] && continue
		panes="$(session_panes "$name")"

		local tag
		if [ "$attached" -gt 0 ]; then
			tag="yes($attached)"
		else
			tag="no"
		fi

		body+="$(printf "%-${width}s | %3s | %4s | %s" "$name" "$windows" "$panes" "$tag")"
		body+=$'\n'
	done < <(list_sessions_raw)

	printf '%s' "$body"
}

view_sessions() {
	if tmux list-sessions >/dev/null 2>&1; then
		if [ -n "$DIALOG" ]; then
			local overview
			overview="$(session_overview_text)"
			dialog --clear --title " Existing Sessions " --msgbox "$overview" 0 0
		else
			echo
			session_overview_text
			echo
			read -r -p "Press Enter to continue..."
		fi
	else
		if [ -n "$DIALOG" ]; then
			dialog --msgbox "No existing tmux sessions." 6 40
		else
			echo "No existing tmux sessions."
			read -r -p "Press Enter to continue..."
		fi
	fi
}

# ── main menu ──────────────────────────────────────────────────────────
main_menu_dialog() {
	local has_sessions=0
	tmux list-sessions >/dev/null 2>&1 && has_sessions=1

	while true; do
		cleanup_tmux

		local attach_label
		if [ "$has_sessions" -eq 1 ]; then
			attach_label="Attach existing session"
		else
			attach_label="Attach existing session (none)"
		fi

		local choice
		choice="$(dialog \
			--clear \
			--title " tmux launcher " \
			--menu "Choose an action" 0 0 0 \
			"a" "$attach_label" \
			"c" "Create new session" \
			"v" "View sessions" \
			"s" "Continue to shell without tmux" \
			"d" "Disconnect SSH session" \
			2>&1 >/dev/tty)"

		log "Main menu choice: ${choice:-<empty>}"

		case "${choice:-}" in
		a)
			if [ "$has_sessions" -eq 1 ]; then
				if has_fzf; then
					select_session_fzf || true
				else
					select_session_dialog || true
				fi
			else
				dialog --msgbox "No existing sessions." 6 40
			fi
			;;
		c)
			create_session || true
			;;
		v)
			view_sessions
			;;
		s)
			log "Continue to shell without tmux selected"
			clear
			exit 0
			;;
		d)
			log "Disconnect SSH session selected"
			clear
			exit 42
			;;
		*)
			log "Main menu cancelled — exiting"
			clear
			exit 0
			;;
		esac

		# Refresh session status for next iteration
		tmux list-sessions >/dev/null 2>&1 && has_sessions=1 || has_sessions=0
	done
}

# ── entry point ────────────────────────────────────────────────────────
if [ -n "$DIALOG" ]; then
	main_menu_dialog
else
	# fallback: plain-text menu (original behavior)
	while true; do
		cleanup_tmux
		clear
		echo "==== tmux launcher ===="
		echo

		if tmux list-sessions >/dev/null 2>&1; then
			log "Existing sessions found"
			session_overview_text
		else
			log "No existing tmux sessions"
			echo "No existing tmux sessions."
		fi
		echo

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
					# bare-bones numbered menu (no fzf, no dialog)
					local sessions=() name
					while IFS='|' read -r name _ _; do
						[ -n "$name" ] && sessions+=("$name")
					done < <(list_sessions_raw)

					if [ "${#sessions[@]}" -eq 0 ]; then
						echo "No sessions."
						read -r -p "Press Enter to continue..."
						continue
					fi

					local i=1 pick
					for name in "${sessions[@]}"; do
						printf "%3d) %s\n" "$i" "$name"
						i=$((i + 1))
					done

					read -r -p "Number: " pick
					if [ -n "${pick:-}" ] && [ "$pick" -ge 1 ] 2>/dev/null && [ "$pick" -le "${#sessions[@]}" ]; then
						attach_session "${sessions[$((pick - 1))]}"
					fi
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
		esac
	done
fi
