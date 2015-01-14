SSH_ENV=$HOME/.ssh/environment
   
# start the ssh-agent
function start_agent {
    echo "Initializing new SSH agent..."
    # spawn ssh-agent
    /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
    echo succeeded
    chmod 600 "${SSH_ENV}"
    . "${SSH_ENV}" > /dev/null
    /usr/bin/ssh-add
}
   
#if [ -f "${SSH_ENV}" ]; then
#     . "${SSH_ENV}" > /dev/null
#     ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
#        start_agent;
#    }
#else
#    start_agent;
#fi

export PATH="$PATH:/home/ale/bin"

# Set some custom stuff to make the terminal look better
export PS1="________________________________________________________________________________\n| \[\033[36m\]\u\[\033[m\]@\[\033[32m\]\h:\[\033[33;1m\]\w\[\033[m\] \n| \[\033[32m\]=>\[\033[m\] "
export PS2="| \[\033[32m\]==>\[\033[m\] "
export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad

# Call .pythonrc when Python is started
export PYTHONSTARTUP=~/.pythonrc

# Set wildcard (*) to affect dotfiles
shopt -s dotglob

# Aliases defined below
alias please='sudo $(history -p !!)'
alias ls='ls -Aph --group-directories-first --color=auto'
alias ll='ls -Alph --group-directories-first --color=auto'
alias lr='ls -R | grep ":$" | sed -e '\''s/:$//'\'' -e '\''s/[^-][^\/]*\//--/g'\'' -e '\''s/^/   /'\'' -e '\''s/-/|/'\'' | less'
alias path='echo -e ${PATH//:/\\n}'
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias freq='cut -f1 -d" " ~/.bash_history | sort | uniq -c | sort -nr | head -n 30'
alias fcount='ls -A1 | wc -l'
alias gbs='git-branch-status'
alias gpaa='git remote | xargs -I % sh -c '"'"'echo "Pushing to %..."; git push --all %; echo'"'"''
alias gpaat='git remote | xargs -I % sh -c '"'"'echo "Pushing to %..."; git push --all %; git push --tags %; echo'"'"''
alias gcamsg='git add --all; git commit -m'
alias speedtest='wget -O /dev/null http://speedtest.wdc01.softlayer.com/downloads/test10.zip'
alias servethis="python -c 'import SimpleHTTPServer; SimpleHTTPServer.test()'"
alias servethisphp='php -S localhost:8000'
alias pycclean='find . -name "*.pyc" -exec rm {} \;'
alias nethack='telnet nethack.alt.org'
# Aliases for ADB stuff
alias adb-uninstall='adb shell am start -a android.intent.action.DELETE -d'
alias adb-listapps='adb shell pm list packages'
alias adb-tcpip='adb tcpip 5555'
alias adb-ifconfig='adb shell netcfg'
# Linux-specific aliases
alias ssh-start='sudo service ssh start'
alias ssh-stop='sudo service ssh stop'
alias ssh-rs='sudo service ssh restart'
alias apache2start='sudo service apache2 start'
alias apache2stop='sudo service apache2 stop'
alias apache2rs='sudo service apache2 restart'

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
    if [[ $1 != '-n' ]]; then
        git remote update
    fi
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

