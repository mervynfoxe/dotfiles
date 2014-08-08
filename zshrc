# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt beep
bindkey -e
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/Users/alex/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

# Set colors and prompt style
autoload -U colors && colors
PS1="________________________________________________________________________________
| %{$fg[cyan]%}%n%{$reset_color%}@%{$fg[green]%}%m:%{$fg[yellow]%}%~ %{$reset_color%}
| => "

# Define aliases
alias please='sudo $(history -p !!)'
alias ls='ls -AGph'
alias ll='ls -AGlph'
alias lr='ls -R | grep ":$" | sed -e '\''s/:$//'\'' -e '\''s/[^-][^\/]*\//--/g'\'' -e '\''s/^/   /'\'' -e '\''s/-/|/'\'' | less'
alias path='echo -e ${PATH//:/\\n}'
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias freq='cut -f1 -d" " ~/.bash_history | sort | uniq -c | sort -nr | head -n 30'

##
# Custom functions for doing cool things
##
# Go up directory tree X times
function up() {
	counter="$@"
	if [[ -z $counter ]]; then
		counter=1
	fi
	if [ $counter -eq $counter 2> /dev/null ]; then
		until [[ $counter -lt 1 ]]; do
			cd ..
			let counter-=1
		done
	else
		echo "usage: up [NUMBER]"
		return 1
	fi
}

# Make and cd into a directory
function mkcd() {
	mkdir -p "$1" && cd "$1";
}

# cd into a directory and list its contents
function cdls() {
	cd "$1" && ls;
}

# Go up X directories and then list the new directory's contents
function upls() {
	up $1;
	pwd;
	ls;
}