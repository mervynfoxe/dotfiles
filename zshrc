#
# OS detection
#
UNAME=`uname`
CURRENT_OS='Linux'
DISTRO=''
OS_VERSION=''

if [[ $UNAME == 'Darwin' ]]; then
    CURRENT_OS='OS X'
    OS_VERSION=$(sw_vers -productVersion)
elif [[ $UNAME == 'Linux' ]]; then
    CURRENT_OS='Linux'
    if [[ -f /etc/lsb-release ]]; then
        source /etc/lsb-release
        DISTRO=$DISTRIB_ID
        OS_VERSION=$DISTRIB_RELEASE
    fi
elif [[ $UNAME == CYGWIN_NT* ]]; then
    CURRENT_OS='Cygwin'
fi


#
# Functions
#
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
    return 0
}

# Make and cd into a directory
function mkcd() {
    mkdir -p "$1" && cd "$1";
    return 0
}

# cd into a directory and list its contents
function cdls() {
    if [[ $1 == "" ]]; then
        cd
    else
        cd "$1"
    fi
    if [[ $CURRENT_OS == 'Linux' ]]; then
        ls -Ap --group-directories-first --color=auto
    elif [[ $CURRENT_OS == 'OS X' ]]; then
        ls -AGp
    else
        ls
    fi
    return 0
}

# Go up X directories and then list the new directory's contents
function upls() {
    up $1;
    pwd;
    if [[ $CURRENT_OS == 'Linux' ]]; then
        ls -Ap --group-directories-first --color=auto
    elif [[ $CURRENT_OS == 'OS X' ]]; then
        ls -AGp
    else
        ls
    fi
    return 0
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
    return 0
}

# In a git repository, update all local branches
function git-pull-all() {
    cur_branch=$(git rev-parse --abbrev-ref HEAD)
    for branch in $(git branch | tr -d " *"); do
        git checkout $branch
        git pull
        echo ''
    done
    git checkout $cur_branch
}


#
# Configuration for oh-my-zsh
#
# Uncomment the following line to use case-sensitive completion.
CASE_SENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder


#
# Activate and configure Antigen
#
source $HOME/.antigen/antigen.zsh

antigen use oh-my-zsh
antigen bundle git
antigen bundle git-extras
antigen bundle git-flow
antigen bundle python
antigen bundle sudo
antigen bundle web-search
if [[ $CURRENT_OS == 'OS X' ]]; then
    antigen bundle osx
    if [[ $(which brew) != "brew not found" ]]; then
        antigen bundle brew
        alias bubov='brew update -v && brew outdated'
        alias bubcv='brew upgrade -v && brew cleanup -v'
        alias bubuv='bubov && bubcv'
    fi
    if [[ $(which port) != "port not found" ]]; then
        antigen bundle macports
    fi
fi
if [[ $DISTRO == 'Ubuntu' ]]; then
    antigen bundle command-not-found
fi
antigen bundle zsh-users/zsh-syntax-highlighting
antigen theme agnoster
antigen apply


#
# User configuration
#
if [[ $CURRENT_OS == 'Linux' ]]; then
    export PATH="$HOME/bin:$PATH"
elif [[ $CURRENT_OS == 'OS X' ]]; then
    export PATH="$HOME/bin:$PATH"
    # Set up tab completion for Python 2
    export PYTHONSTARTUP=$HOME/.pythonrc.py
fi
# export MANPATH="/usr/local/man:$MANPATH"

# Fix for prompts
PROMPT="$(echo -e "$PROMPT")
$ "
PROMPT2="%_> "

# Set wildcard (*) to affect dotfiles
setopt dotglob

if [[ $CURRENT_OS == 'Linux' ]]; then
    # Set completion for ssh hosts
    zstyle -e ':completion::*:*:*:hosts' hosts 'reply=(${=${${(f)"$(cat {/etc/ssh_,~/.ssh/known_}hosts(|2)(N) /dev/null)"}%%[# ]*}//,/ })'
elif [[ $CURRENT_OS == 'OS X' ]]; then
    # Set up tab completion for ssh hosts
    zstyle -s ':completion:*:hosts' hosts _ssh_config
    [[ -r ~/.ssh/config ]] && _ssh_config+=($(cat ~/.ssh/config | sed -ne 's/Host[=\t ]//p'))
    zstyle ':completion:*:hosts' hosts $_ssh_config
fi


#
# Aliases
#
alias lr='ls -R | grep ":$" | sed -e '\''s/:$//'\'' -e '\''s/[^-][^\/]*\//--/g'\'' -e '\''s/^/   /'\'' -e '\''s/-/|/'\'' | less'
alias path='echo -e ${PATH//:/\\n}'
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fcount='ls -A1 | wc -l'
alias gbi='git bisect'
alias gbs='git-branch-status'
alias gla='git-pull-all'
alias gpaa='git remote | xargs -I % sh -c '"'"'echo "Pushing to %..."; git push --all %; echo'"'"''
alias gpaat='git remote | xargs -I % sh -c '"'"'echo "Pushing to %..."; git push --all %; git push --tags %; echo'"'"''
alias gcamsg='git add --all; git commit -m'
alias gt='git tag'
alias gprt='git rev-parse --show-toplevel'
alias grupp='git remote update -p'
alias speedtest='wget -O /dev/null http://speedtest.wdc01.softlayer.com/downloads/test10.zip'
alias servethis="python -c 'import SimpleHTTPServer; SimpleHTTPServer.test()'"
alias servethisphp='php -S localhost:8000'
alias pycclean='find . -name "*.pyc" -exec rm {} \;'
alias nethack='telnet nethack.alt.org'
alias rot13="tr '[A-Za-z]' '[N-ZA-Mn-za-m]'"
if [[ $CURRENT_OS == 'Linux' ]]; then
    # Linux-specific aliases
    alias ls='ls -Ap --group-directories-first --color=auto'
    alias ll='ls -Alph --group-directories-first --color=auto'
    alias ssh-start='sudo service ssh start'
    alias ssh-stop='sudo service ssh stop'
    alias ssh-rs='sudo service ssh restart'
    alias apache2start='sudo service apache2 start'
    alias apache2stop='sudo service apache2 stop'
    alias apache2restart='sudo service apache2 restart'
    # Aliases for ADB stuff
    alias adb-uninstall='adb shell am start -a android.intent.action.DELETE -d'
    alias adb-listapps='adb shell pm list packages'
    alias adb-tcpip='adb tcpip 5555'
    alias adb-ifconfig='adb shell netcfg'
elif [[ $CURRENT_OS == 'OS X' ]]; then
    # OSX-specific aliases
    alias ls='ls -AGp'
    alias ll='ls -AGlph'
    alias showhidden='defaults write com.apple.finder AppleShowAllFiles YES; killall Finder /System/Library/CoreServices/Finder.app'
    alias hidehidden='defaults write com.apple.finder AppleShowAllFiles NO; killall Finder /System/Library/CoreServices/Finder.app'
    alias unmount='diskutil unmountDisk'
    alias rmdsstore='find . -name "*.DS_Store" -type f -delete'
    alias apache2start='sudo apachectl start'
    alias apache2stop='sudo apachectl stop'
    alias apache2restart='sudo apachectl restart'
fi


#
# Everything else
#
if [[ $CURRENT_OS == 'OS X' ]]; then
    # The following lines were added by compinstall

    zstyle ':completion:*' completer _expand _complete _ignored
    zstyle ':completion:*' format '%d'
    zstyle ':completion:*' group-name ''
    zstyle ':completion:*' menu select=long
    zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
    zstyle :compinstall filename '$HOME/.zshrc'

    autoload -Uz compinit
    compinit
    # End of lines added by compinstall

    export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting
    [[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
fi

if [[ -f $HOME/.zshrc.custom ]]; then
    source $HOME/.zshrc.custom
fi
