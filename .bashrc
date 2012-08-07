#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# PS1='[\u@\h \W]\$ '

# 
PS1='\[\e[0;32m\]\u\[\e[m\]@\[\h\] \[\e[1;34m\]\w\[\e[m\] \[\e[1;32m\]\$\[\e[m\] \[\e[1;37m\]'

# Set vi-like keybindings
set -o vi

# Modified commands
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias reboot='sudo reboot'
alias poweroff='sudo poweroff'
alias svim='sudo vim'
alias pacman='sudo pacman'
alias rxvt='export TERM=rxvt'
alias netcrawl='export TERM=rxvt && ssh -C4c arcfour,blowfish-cbc joshua@crawl.akrasiac.org'
alias csnetsun='export TERM=rxvt && ssh -C4 jrh8419@sun.cse.tamu.edu'
alias csnetproxy='ssh jrh8419@sun.cse.tamu.edu -D 8887'
alias gl++='g++ -lX11 -lXi -lXmu -lglut -lGL -lGLU -lm'
alias open='xdg-open'

# Safety features
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -I' # rm -i prompts for EVERY file
alias ln='ln -i'
alias chown='chown --preserve-root'
alias chmod='chmod --preserve-root'
alias chgrp='chgrp --preserve-root'

# Add autocomplete to commands
complete -cf sudo
complete -cf man

# Add android to path
PATH=$PATH:/opt/android-sdk/tools
PATH=$PATH:/opt/android-sdk/platform-tools
PATH=$PATH:/usr/share/java/apache-ant/bin
export PATH

export EDITOR="vim"
export BROWSER="chromium"

# Start X when I login to tty1
if [[ -z $DISPLAY && $(tty) = /dev/tty1 ]]; then
    exec startx
fi
