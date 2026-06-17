#!/usr/bin/env bash
name="$1"
passfile="$PREFIX/$name.gpg"

if [[ -f $passfile ]]; then
	$GPG -d "${GPG_OPTS[@]}" "$passfile"
else
	password=$(echo -n "$name" | ~/go/bin/pw)
	echo "$password"
	echo >&2
	echo "[pw] generated from pw, not stored in pass" >&2
	echo "[pw] run 'pass insert $name' to save it permanently." >&2
fi
