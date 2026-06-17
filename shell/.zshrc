if [[ -z $TMUX ]] && [[ ! -f $HOME/.notmux ]]; then
	exec tmux
else
	# =========================
	# Prompt
	# =========================

	eval "$(oh-my-posh init zsh --config "$HOME/.config/omp/bash.omp.json")"

	# =========================
	# Zinit
	# =========================

	ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

	if [[ ! -d "$ZINIT_HOME/.git" ]]; then
		mkdir -p "$(dirname "$ZINIT_HOME")"
		git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
	fi

	source "${ZINIT_HOME}/zinit.zsh"

	autoload -Uz _zinit
	((${+_comps})) && _comps[zinit]=_zinit

	# Zinit annexes
	zinit light zdharma-continuum/zinit-annex-as-monitor
	zinit light zdharma-continuum/zinit-annex-bin-gem-node
	zinit light zdharma-continuum/zinit-annex-patch-dl
	zinit light zdharma-continuum/zinit-annex-rust

	# OMZ snippets
	# zinit snippet OMZ::lib/history.zsh
	zinit snippet OMZ::lib/key-bindings.zsh

	# Core plugins
	zinit ice wait"1" lucid
	zinit light zsh-users/zsh-autosuggestions

	zinit ice wait"1" lucid
	zinit light zsh-users/zsh-history-substring-search

	zinit ice wait"1" lucid
	zinit light zdharma-continuum/fast-syntax-highlighting

	# Completion plugin
	zinit ice wait"1" lucid blockf atload"zicompinit; zicdreplay"
	zinit light zsh-users/zsh-completions

	# Optional plugins
	# 用得到再打開，先不要預設載入
	zinit ice wait"2" lucid
	zinit light hlissner/zsh-autopair

	zinit ice wait"2" lucid
	zinit load djui/alias-tips

	# =========================
	# Completion
	# =========================

	# Completion styles
	zstyle ':completion:*' completer _complete _ignored _correct
	zstyle ':completion:*' menu yes select
	zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

	# Custom completion search paths
	fpath=(
		"$HOME/.zsh"
		$fpath
	)

	# Init completion system
	autoload -Uz compinit
	compinit -d "$HOME/.zcompdump"

	# Key bindings
	# Use Ctrl+Up/Down for history substring search
	bindkey '^[[A' history-substring-search-up
	bindkey '^[[B' history-substring-search-down

	# =========================
	# Env / Path
	# =========================

	SAVEHIST=1000
	HISTFILE="$HOME/.zsh_history"

	export EDITOR="nvim"

	# GPG agent as SSH agent
	unset SSH_AGENT_PID
	if [[ "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]]; then
		export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
	fi

	export GPG_TTY=$(tty)
	gpg-connect-agent updatestartuptty /bye >/dev/null 2>&1

	# PATH
	typeset -U path PATH

	path=(
		"$HOME/.local/bin"
		"$HOME/.local/share/pnpm/bin"
		"/usr/local/go/bin"
		"$HOME/go/bin"
		"/opt/flutter/bin:$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools:$ANDROID_HOME/cmdline-tools/latest/bin"
		$path
	)

	export ANDROID_HOME=$HOME/Android/Sdk

	export PNPM_HOME="$HOME/.local/share/pnpm"
	export PATH

	export PASSWORD_STORE_ENABLE_EXTENSIONS=true

	# =========================
	# Local overrides
	# =========================

	# Aliases
	[[ -f "$HOME/.alias.sh" ]] && source "$HOME/.alias.sh"
fi
