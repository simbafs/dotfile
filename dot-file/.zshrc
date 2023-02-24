if [[ -z $TMUX ]] && [[ ! -f $HOME/.notmux ]];then
	exec tmux
else
	# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
	# Initialization code that may require console input (password prompts, [y/n]
	# confirmations, etc.) must go above this block; everything else may go below.
	if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
	  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
	fi

	### Added by Zinit's installer
	if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
		print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
		command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
		command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
			print -P "%F{33} %F{34}Installation successful.%f%b" || \
			print -P "%F{160} The clone has failed.%f%b"
	fi

	source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
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
	zinit light romkatv/powerlevel10k

	zinit snippet OMZ::lib/completion.zsh
	zinit snippet OMZ::lib/history.zsh
	zinit snippet OMZ::lib/key-bindings.zsh
	zinit snippet OMZ::lib/theme-and-appearance.zsh

	# for zsh-history-substring-search
	bindkey '^[[A' history-substring-search-up
	bindkey '^[[B' history-substring-search-down
	bindkey ',' autosuggest-accept

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
	
	SAVEHIST=1000
	export HISTFILE=~/.zsh_history

	# others
	[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

	export EDITOR=nvim

	for i in $(\ls $HOME/.bash);do
		source $HOME/.bash/$i
	done

	export NVM_DIR="$HOME/.nvm"
	[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
	[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
	nvm use 16 > /dev/null

	# pnpm
	export PNPM_HOME="/home/simba/.local/share/pnpm"
	export PATH="$PNPM_HOME:$PATH"
	# pnpm end

	export PATH=$HOME/.local/bin:$PATH

	# deno
	export DENO_INSTALL="/home/simba/.deno"
	export PATH="$DENO_INSTALL/bin:$PATH"

	# go
	export PATH=/usr/local/go/bin:$HOME/go/bin:$PATH

	export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

	# ipfs
	eval "$(ipfs commands completion bash)"
fi
