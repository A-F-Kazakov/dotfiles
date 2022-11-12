case $- in
	*i*) ;;
	*) return;;
esac

set -o vi
shopt -s autocd
shopt -s checkwinsize
shopt -s cmdhist
shopt -s histappend

HISTCONTROL=ignoreboth:erasedups
HISTSIZE=1000
HISTFILESIZE=2000

if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
	debian_chroot=$(cat /etc/debian_chroot)
fi

if [ -x /usr/bin/dircolors ]; then
	test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
	alias ls='ls --color=auto'

	alias grep='grep --color=auto'
	alias fgrep='fgrep --color=auto'
	alias egrep='egrep --color=auto'
fi

if [ -f ~/.bash_aliases ]; then
	. ~/.bash_aliases
fi

if [ -f ~/.bash_functions ]; then
	. ~/.bash_functions
fi

if ! shopt -oq posix; then
	if [ -f /usr/share/bash-completion/bash_completion ]; then
		. /usr/share/bash-completion/bash_completion
	elif [ -f /etc/bash_completion ]; then
		. /etc/bash_completion
	fi
fi

export EDITOR="vim"

case "$TERM" in
	xterm-color|*-256color) color_prompt=yes;;
esac

SEPARATOR='$'
CURRENT_PATH='\w'
PREFIX="${debian_chroot:+($debian_chroot)}"

if [ "$color_prompt" = yes ]; then
	color_exit_status()
	{
		if [ $? -eq 0 ]; then
			echo '1;32m'
		else
			echo '1;31m'
		fi
	}

	CURRENT_PATH='\[\e[01;34m\]'$CURRENT_PATH
	SEPARATOR='\[\e[$(color_exit_status)\]'$SEPARATOR'\[\e[00m\]'
fi

PS1="${PREFIX}${CURRENT_PATH} ${SEPARATOR} "
