##
# General setup
##

# Add MacPorts and apache/mysql to the PATH
export PATH="/opt/local/bin:/opt/local/sbin:/opt/local/lib/mysql55/bin:/opt/local/apache2/bin:$PATH"

# Set up bash completion
if [ -f /opt/local/etc/profile.d/bash_completion.sh ]; then
    . /opt/local/etc/profile.d/bash_completion.sh
fi

# Set prompt colors
export PS1="________________________________________________________________________________\n| \[\033[36m\]\u\[\033[m\]@\[\033[32m\]\h:\[\033[33;1m\]\w\[\033[m\] \n| \[\033[32m\]=>\[\033[m\] "
export PS2="| \[\033[32m\]==>\[\033[m\] "
export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad

# Aliases defined below
alias please='sudo $(history -p !!)'
alias ls='ls -AGph'
alias ll='ls -AGlph'
alias lr='ls -R | grep ":$" | sed -e '\''s/:$//'\'' -e '\''s/[^-][^\/]*\//--/g'\'' -e '\''s/^/   /'\'' -e '\''s/-/|/'\'' | less'
alias path='echo -e ${PATH//:/\\n}'
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias freq='cut -f1 -d" " ~/.bash_history | sort | uniq -c | sort -nr | head -n 30'
alias showhidden='defaults write com.apple.finder AppleShowAllFiles YES; killall Finder /System/Library/CoreServices/Finder.app'
alias hidehidden='defaults write com.apple.finder AppleShowAllFiles NO; killall Finder /System/Library/CoreServices/Finder.app'

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

# In a git repository, print out branch status for all local branches, how many commits ahead/behind they are
function git-branch-status() {
    git remote update
    echo ''
    git for-each-ref --format="%(refname:short) %(upstream:short)" refs/heads | \
    while read local remote
    do
        [ -z "$remote" ] && continue
        git rev-list --left-right ${local}...${remote} -- 2>/dev/null >/tmp/git_upstream_status_delta || continue
        LEFT_AHEAD=$(grep -c '^<' /tmp/git_upstream_status_delta)
        RIGHT_AHEAD=$(grep -c '^>' /tmp/git_upstream_status_delta)
        echo "$local (ahead $LEFT_AHEAD) | (behind $RIGHT_AHEAD) $remote"
    done
}

