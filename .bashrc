case $- in
    *i*) ;;
      *) return;;
esac

set -o vi
shopt -s autocd
shopt -s checkwinsize
shopt -s cmdhist 
shopt -s histappend

HISTCONTROL=ignoreboth
HISTSIZE=1000
HISTFILESIZE=2000

if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
	if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
		color_prompt=yes
	else
		color_prompt=
	fi
fi

SEPARATOR='$'
PREFIX="${debian_chroot:+($debian_chroot)}"

if [ "$color_prompt" = yes ]; then
	if [[ $? == 0 ]]; then
		SEPARATOR="\[\e[1;32m$SEPARATOR"
	else
		SEPARATOR="\[\e[1;31m$SEPARATOR"
	fi

    PS1="$PREFIX\[\e[01;34m\]\w $SEPARATOR\[\e[00m\] "
else
    PS1="$PREFIX\w $SEPARATOR " 
fi

unset color_prompt force_color_prompt SEPARATOR PREFIX

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
