if [[ -z $TMUX ]] && [[ ! -f $HOME/.notmux ]];then
	exec tmux
else
	source ~/.zplug/init.zsh

	zplug "romkatv/powerlevel10k", as:theme, depth:1
	zplug "zsh-users/zsh-autosuggestions"
	bindkey "$terminfo[kcuu1]" history-substring-search-up
	bindkey "$terminfo[kcud1]" history-substring-search-down

	zplug 'zsh-users/zsh-history-substring-search'
	zplug 'zsh-users/zsh-syntax-highlighting', defer:2
	zplug 'catppuccin/zsh-syntax-highlighting'
	# zplug 'MichaelAquilina/zsh-auto-notify'
	# export AUTO_NOTIFY_IGNORE=("docker" "man" "vim", "vi", "sleep", "apt", "su")

	# zplug 'marlonrichert/zsh-autocomplete'
	zplug 'hlissner/zsh-autopair'
	# zplug 'b4b4r07/emoji-cli'
	# EMOJI_CLI_KEYBIND=^e

	# zplug 'reegnz/jq-zsh-plugin'
	# alt + j

	# zplug "MichaelAquilina/zsh-autoswitch-virtualenv"
	# zplug "plugins/virtualenv", from:oh-my-zsh

	zplug 'zchee/zsh-completions'
	# zplug 'zsh-users/zsh-completions'

	# zplug "g-plane/zsh-yarn-autocompletions", hook-build:"./zplug.zsh", defer:2
	
	# zplug 'bobthecow/git-flow-completion'

	# Install plugins if there are plugins that have not been installed
	if ! zplug check --verbose; then
		printf "Install? [y/N]: "
		if read -q; then
			echo; zplug install
		fi
	fi

	# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
	# Initialization code that may require console input (password prompts, [y/n]
	# confirmations, etc.) must go above this block; everything else may go below.
	if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
		source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
	fi

	# Then, source plugins and add commands to $PATH
	zplug load

	deleteWord(){
		local WORDCHARS=${WORDCHARS/\//}
		zle backward-delete-word
	}
	zle -N deleteWord
	bindkey '^W' deleteWord


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
	# setopt share_history

	# zsh-autocomplete configure
	# Up arrow:
	# bindkey '\e[A' up-line-or-search
	# bindkey '\eOA' up-line-or-search
	# up-line-or-search:  Open history menu.
	# up-line-or-history: Cycle to previous history line.

	# Down arrow:
	# bindkey '\e[B' down-line-or-select
	# bindkey '\eOB' down-line-or-select
	# down-line-or-select:  Open completion menu.
	# down-line-or-history: Cycle to next history line.


	# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
	[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

	export EDITOR=vim

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
