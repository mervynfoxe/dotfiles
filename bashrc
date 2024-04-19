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
}

# Make and cd into a directory
function mkcd() {
    mkdir -p "$1" && cd "$1";
}

# cd into a directory and list its contents
function cdls() {
    if [[ $1 == "" ]]; then
        cd
    else
        cd "$1"
    fi
    if [[ $CURRENT_OS == 'Linux' ]]; then
        ls -Aph --group-directories-first --color=auto
    elif [[ $CURRENT_OS == 'OS X' ]]; then
        ls -AGph
    else
        ls
    fi
}

# Go up X directories and then list the new directory's contents
function upls() {
    up $1;
    pwd;
    if [[ $CURRENT_OS == 'Linux' ]]; then
        ls -Aph --group-directories-first --color=auto
    elif [[ $CURRENT_OS == 'OS X' ]]; then
        ls -AGph
    else
        ls
    fi
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

# In a git repository, check out a WIP branch and make a WIP commit
function git-wip() {
    branch="${1:-$(whoami)-wip}"

    git branch "$branch"
    git checkout "$branch"
    git add -A
    git rm $(git ls-files --deleted) 2> /dev/null
    git commit --no-verify --no-gpg-sign -m "--wip--"
}

# Retrieve the current git branch
function parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (git:\1)/'
}

# Determine if we are currently in a gitpod workspace
function is::gitpod() {
    test -e /ide/bin/gitpod-code && test -v GITPOD_REPO_ROOT
}


#
# General setup
#
if is::gitpod; then
    # Use Gitpod's dotfile as a starting point
    source ~/.dotfiles.bak/.bashrc
fi

if [[ $CURRENT_OS == 'Linux' ]]; then
    # Set up SSH environment
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

    # Call .pythonrc.py when Python is started
    export PYTHONSTARTUP=~/.pythonrc.py

    export PATH="$HOME/bin:$PATH"
elif [[ $CURRENT_OS == 'OS X' ]]; then
    export PATH="$HOME/bin:$PATH"

    # Set up bash completion
    if [ -f /opt/local/etc/profile.d/bash_completion.sh ]; then
        . /opt/local/etc/profile.d/bash_completion.sh
    fi
fi

# Set prompt colors
export PS1="________________________________________________________________________________\n| \[\033[36m\]\u\[\033[m\]@\[\033[32m\]\h:\[\033[33;1m\]\w\[\033[m\]\$(parse_git_branch)\n| \[\033[32m\]=>\[\033[m\] "
export PS2="| \[\033[32m\]==>\[\033[m\] "
export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad

# Set wildcard (*) to affect dotfiles
shopt -s dotglob


#
# Aliases
#
alias please='sudo $(history -p !!)'
alias lr='ls -R | grep ":$" | sed -e '\''s/:$//'\'' -e '\''s/[^-][^\/]*\//--/g'\'' -e '\''s/^/   /'\'' -e '\''s/-/|/'\'' | less'
alias path='echo -e ${PATH//:/\\n}'
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias freq='cut -f1 -d" " ~/.bash_history | sort | uniq -c | sort -nr | head -n 30'
alias fcount='ls -A1 | wc -l'
alias speedtest='wget -O /dev/null http://speedtest.wdc01.softlayer.com/downloads/test10.zip'
alias servethis="python -c 'import SimpleHTTPServer; SimpleHTTPServer.test()'"
alias servethisphp='php -S localhost:8000'
alias pycclean='find . -name "*.pyc" -exec rm {} \;'
alias nethack='telnet nethack.alt.org'
alias rot13="tr '[A-Za-z]' '[N-ZA-Mn-za-m]'"
# Git aliases
alias g='git'
alias ga='git add'
alias gaa='git add --all'
alias gapa='git add --patch'
alias gau='git add --update'
alias gb='git branch'
alias gba='git branch -a'
alias gbd='git branch -d'
alias gbda='git branch --no-color --merged | command grep -vE "^(\*|\s*(master|develop|dev)\s*$)" | command xargs -n 1 git branch -d'
alias gbi='git bisect'
alias gbl='git blame -b -w'
alias gbnm='git branch --no-merged'
alias gbr='git branch --remote'
alias gbs='git-branch-status'
alias gbsb='git bisect bad'
alias gbsg='git bisect good'
alias gbsr='git bisect reset'
alias gbss='git bisect start'
alias gc!='git commit -v --amend'
alias gc='git commit -v'
alias gca!='git commit -v -a --amend'
alias gca='git commit -v -a'
alias gcam='git commit -a -m'
alias gcamsg='git add --all; git commit -m'
alias gcan!='git commit -v -a --no-edit --amend'
alias gcans!='git commit -v -a -s --no-edit --amend'
alias gcb='git checkout -b'
alias gcd='git checkout develop'
alias gcf='git config --list'
alias gch='git checkout hotfix'
alias gcl='git clone --recursive'
alias gclean='git clean -fd'
alias gcm='git checkout master'
alias gcmsg='git commit -m'
alias gcn!='git commit -v --no-edit --amend'
alias gco='git checkout'
alias gcount='git shortlog -sn'
alias gcp='git cherry-pick'
alias gcpa='git cherry-pick --abort'
alias gcpc='git cherry-pick --continue'
alias gcr='git checkout release'
alias gcs='git commit -S'
alias gcsm='git commit -s -m'
alias gd='git diff'
alias gdca='git diff --cached'
alias gdct='git describe --tags `git rev-list --tags --max-count=1`'
alias gdt='git diff-tree --no-commit-id --name-only -r'
alias gdw='git diff --word-diff'
alias gf='git fetch'
alias gfa='git fetch --all --prune'
alias gfl='git flow'
alias gflf='git flow feature'
alias gflff='git flow feature finish'
alias gflfs='git flow feature start'
alias gflh='git flow hotfix'
alias gflhf='git flow hotfix finish'
alias gflhs='git flow hotfix start'
alias gfli='git flow init'
alias gflr='git flow release'
alias gflrf='git flow release finish'
alias gflrs='git flow release start'
alias gfo='git fetch origin'
alias gg='git gui citool'
alias gga='git gui citool --amend'
alias ghh='git help'
alias gignore='git update-index --assume-unchanged'
alias gignored='git ls-files -v | grep "^[[:lower:]]"'
alias git-svn-dcommit-push='git svn dcommit && git push github master:svntrunk'
alias gk='\gitk --all --branches'
alias gke='\gitk --all $(git log -g --pretty=%h)'
alias gl='git pull'
alias gla='git-pull-all'
alias glg='git log --stat'
alias glga='git log --graph --full-history --color --pretty=format:"%x1b[31m%h%x09%x1b[33m%d%x1b[0m%x20%s %x1b[32m(%ar) %x1b[34m%x1b[1m<%an>%x1b[0m" --abbrev-commit --date=relative'
alias glgg='git log --graph'
alias glgga='git log --graph --decorate --all'
alias glgm='git log --graph --max-count=10'
alias glgnew="git log HEAD^..origin --graph --pretty='%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias glgp='git log --stat -p'
alias glo='git log --oneline --decorate'
alias glog='git log --oneline --decorate --graph'
alias gloga='git log --oneline --decorate --graph --all'
alias glol="git log --graph --pretty='%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias glola="git log --graph --pretty='%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --all"
alias glum='git pull upstream master'
alias gm='git merge'
alias gmev='git merge --no-ff --no-commit'
alias gmfo='git merge --ff-only'
alias gmnf='git merge --no-ff'
alias gmom='git merge origin/master'
alias gmt='git mergetool --no-prompt'
alias gmtvim='git mergetool --no-prompt --tool=vimdiff'
alias gmum='git merge upstream/master'
alias gp='git push'
alias gpaa='git remote | xargs -I % sh -c '\''echo "Pushing to %..."; git push --all %; echo'\'
alias gpaat='git remote | xargs -I % sh -c '\''echo "Pushing to %..."; git push --all %; git push --tags %; echo'\'
alias gpd='git push --dry-run'
alias gpoat='git push origin --all && git push origin --tags'
alias gpristine='git reset --hard && git clean -dfx'
alias gprt='git rev-parse --show-toplevel'
alias gpu='git push upstream'
alias gpv='git push -v'
alias gr='git remote'
alias gra='git remote add'
alias grb='git rebase'
alias grba='git rebase --abort'
alias grbc='git rebase --continue'
alias grbi='git rebase -i'
alias grbm='git rebase master'
alias grbs='git rebase --skip'
alias grfa='git show-ref --abbrev=7'
alias grft='git show-ref --abbrev=7 --tags'
alias grh='git reset HEAD'
alias grhh='git reset HEAD --hard'
alias grmv='git remote rename'
alias grrm='git remote remove'
alias grset='git remote set-url'
alias grt='cd $(git rev-parse --show-toplevel || echo ".")'
alias gru='git reset --'
alias grup='git remote update'
alias grupp='git remote update -p'
alias grv='git remote -v'
alias gsb='git status -sb'
alias gsd='git svn dcommit'
alias gsi='git submodule init'
alias gsps='git show --pretty=short --show-signature'
alias gsr='git svn rebase'
alias gss='git status -s'
alias gst='git status'
alias gsta='git stash push'
alias gstaa='git stash apply'
alias gstau='git stash push -u'
alias gstc='git stash clear'
alias gstd='git stash drop'
alias gstl='git stash list'
alias gstp='git stash pop'
alias gsts='git stash show --text'
alias gsu='git submodule update'
alias gt='git tag'
alias gts='git tag -s'
alias gtv='git tag | sort -V'
alias gunignore='git update-index --no-assume-unchanged'
alias gunwip='git log -n 1 | grep -q -c "\-\-wip\-\-" && git reset HEAD~1'
alias gup='git pull --rebase'
alias gupv='git pull --rebase -v'
alias gwch='git whatchanged -p --abbrev-commit --pretty=medium'
alias gwip='git-wip'
if [[ $CURRENT_OS == 'Linux' ]]; then
    # Linux-specific aliases
    alias ls='/bin/ls -AHp --group-directories-first --color=auto'
    alias ll='/bin/ls -Alph --group-directories-first --color=auto'
    alias ssh-start='sudo service ssh start'
    alias ssh-stop='sudo service ssh stop'
    alias ssh-rs='sudo service ssh restart'
    alias apache2start='sudo service apache2 start'
    alias apache2stop='sudo service apache2 stop'
    alias apache2restart='sudo service apache2 restart'
    alias pbcopy='xclip -sel clip'
    alias pbpaste='xclip -sel clip -o'
    # Aliases for ADB stuff
    alias adb-uninstall='adb shell am start -a android.intent.action.DELETE -d'
    alias adb-listapps='adb shell pm list packages'
    alias adb-tcpip='adb tcpip 5555'
    alias adb-ifconfig='adb shell netcfg'
elif [[ $CURRENT_OS == 'OS X' ]]; then
    # OSX-specific aliases
    alias ls='/bin/ls -AGHp'
    alias ll='/bin/ls -AGlph'
    alias showhidden='defaults write com.apple.finder AppleShowAllFiles YES; killall Finder /System/Library/CoreServices/Finder.app'
    alias hidehidden='defaults write com.apple.finder AppleShowAllFiles NO; killall Finder /System/Library/CoreServices/Finder.app'
    alias unmount='diskutil unmountDisk'
    alias rmdsstore='find . -name "*.DS_Store" -type f -delete'
    alias apache2start='sudo apachectl start'
    alias apache2stop='sudo apachectl stop'
    alias apache2restart='sudo apachectl restart'
    if [[ $(which brew) != "" ]]; then
        export PATH="/usr/local/bin:/usr/local/sbin:$PATH"
        alias brews='brew list -1'
        alias bubo='brew update && brew outdated'
        alias bubov='brew update -v && brew outdated'
        alias bubc='brew upgrade && brew cleanup'
        alias bubcv='brew upgrade -v && brew cleanup -v'
        alias bubu='bubo && bubc'
        alias bubuv='bubov && bubcv'
    fi
    if [[ $(which port) != "" ]]; then
        export PATH="/opt/local/bin:/opt/local/sbin:/opt/local/lib/mysql55/bin:/opt/local/apache2/bin:$PATH"
        alias pc='sudo port clean --all installed'
        alias pi='sudo port install $1'
        alias pio='port installed outdated'
        alias psu='sudo port selfupdate'
        alias puo='sudo port upgrade outdated'
        alias pup='psu && puo'
        alias puni='sudo port uninstall inactive'
    fi
fi

if [[ $CURRENT_OS == 'OS X' ]]; then
    export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting
    [[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
fi

if is::gitpod; then
    # Remove conflict with gitpod's executable
    unalias gp
fi

if [[ -f $HOME/.bashrc.custom ]]; then
    source $HOME/.bashrc.custom
fi
