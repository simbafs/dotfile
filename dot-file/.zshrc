if [[ -z $TMUX ]] && [[ ! -f $HOME/.notmux ]];then
	exec tmux
else
	eval "$(oh-my-posh init zsh --config "$HOME"/.config/omp/bash.omp.json)"

	ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
	[ ! -d "$ZINIT_HOME" ] && mkdir -p "$(dirname "$ZINIT_HOME")"
	[ ! -d "$ZINIT_HOME"/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
	source "${ZINIT_HOME}/zinit.zsh"

	autoload -Uz _zinit
	(( ${+_comps} )) && _comps[zinit]=_zinit

	# Load a few important annexes, without Turbo
	# (this is currently required for annexes)
	zinit light zdharma-continuum/zinit-annex-as-monitor
	zinit light zdharma-continuum/zinit-annex-bin-gem-node
	zinit light zdharma-continuum/zinit-annex-patch-dl
	zinit light zdharma-continuum/zinit-annex-rust

	### End of Zinit's installer chunk

	zinit light zsh-users/zsh-completions
	zinit light zsh-users/zsh-autosuggestions
	zinit light zsh-users/zsh-history-substring-search
	zinit light zdharma-continuum/fast-syntax-highlighting
	zinit light hlissner/zsh-autopair
	zinit ice depth=1;
	# zinit light romkatv/powerlevel10k

	zinit snippet OMZ::lib/completion.zsh
	zinit snippet OMZ::lib/history.zsh
	zinit snippet OMZ::lib/key-bindings.zsh
	zinit snippet OMZ::lib/theme-and-appearance.zsh

	# for zsh-history-substring-search
	bindkey '^[[A' history-substring-search-up
	bindkey '^[[B' history-substring-search-down
	# bindkey ',' autosuggest-accept

	zinit load djui/alias-tips

	# The following lines were added by compinstall
	zstyle ':completion:*' completer _complete _ignored _correct
	zstyle ':completion:*' menu yes select
	zstyle :compinstall filename '/home/simba/.zshrc'
	# case sensitive
	zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
	autoload -Uz compinit
	compinit
	# End of lines added by compinstall

	# completions
	fpath=(~/.zsh $fpath)
	autoload -Uz compinit
	compinit -u

	SAVEHIST=1000
	export HISTFILE=~/.zsh_history

	# others
	# [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

	export EDITOR=nvim

	# gpg-agent ssh
	unset SSH_AGENT_PID
	if [ "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]; then
		export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
	fi

	# Set GPG TTY for pinentry
	# export GPG_TTY=$(tty)
	# gpg-connect-agent updatestartuptty /bye &>/dev/null

	source $HOME/.alias.sh

	PATH=$HOME/.local/bin:$PATH

	export PNPM_HOME="/home/simba/.local/share/pnpm"
	case ":$PATH:" in
  	*":$PNPM_HOME:"*) ;;
  	*) export PATH="$PNPM_HOME:$PATH" ;;
	esac

	# deno
	# export DENO_INSTALL="/home/simba/.deno"
	# export PATH="$DENO_INSTALL/bin:$PATH"

	# go
	export PATH=/usr/local/go/bin:$HOME/go/bin:$PATH

	# source "$HOME/.cargo/env"


	# export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

	# eval "$(devpod completion zsh)"

	# eval "$(hugo completion zsh)"

	if which tailscale &>/dev/null; then
		eval "$(tailscale completion zsh)"
	fi

	# source $HOME/.cargo/env

	# ipfs
	# eval "$(ipfs commands completion bash)"

	# export RISCV=/opt/riscv
	# export PATH=$PATH:$RISCV/bin

	# bun
	# export BUN_INSTALL="$HOME/.bun"
	# export PATH="$BUN_INSTALL/bin:$PATH"

	# flutter
	# export PATH=/usr/local/flutter/bin:$PATH

	# export ANDROID_HOME=$HOME/Android/Sdk
	# export NDK_HOME=$HOME/Android/Sdk/ndk/28.0.12433566

	# bun completions
	# [ -s "/home/simba/.bun/_bun" ] && source "/home/simba/.bun/_bun"
	# # bun
	# export BUN_INSTALL="$HOME/.bun"
	# export PATH="$BUN_INSTALL/bin:$PATH"

	# eval $(cs completion zsh)

	# export LANG=zh_TW.UTF-8
	# export LC_ALL=zh_TW.UTF-8

	PATH=$HOME/.local/share/STMicroelectronics/STM32Cube/STM32CubeProgrammer/bin:$PATH
fi
