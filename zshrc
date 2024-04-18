DOTFILES_DIR=$( cd -- "$( dirname -- "$(readlink -f "${(%):-%N}" || ${(%):-%N})" )" &> /dev/null && pwd )

if [[ -e $HOME/.globalrc ]]; then
    source $HOME/.globalrc
else
    echo "$HOME/.globalrc not found, unable to continue."
    echo "Please ensure $DOTFILES_DIR/globalrc is properly linked to load required functions and config."
    return 1
fi


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

if [[ $CURRENT_OS == 'OS X' ]]; then
    # Set PATH, MANPATH, etc., for Homebrew.
    if [ -d /opt/homebrew ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -d $HOME/homebrew ]; then
        export PATH="$HOME/homebrew/bin:/usr/local/homebrew:$PATH"
    fi
    if type brew &>/dev/null; then
        export PATH="/usr/local/bin:/usr/local/sbin:$PATH"
        export FPATH="$(brew --prefix)/share/zsh-completions:$(brew --prefix)/share/zsh/site-functions:$FPATH"
        antigen bundle brew
        alias bubov='brew update -v && brew outdated'
        alias bubcv='brew upgrade -v && brew cleanup -v'
        alias bubuv='bubov && bubcv'
        alias brew-fix-compinit='chmod -R go-w "$(brew --prefix)/share"'
    fi
    if [[ $(which port) != "port not found" ]]; then
        export PATH="/opt/local/bin:/opt/local/sbin:/opt/local/lib/mysql55/bin:/opt/local/apache2/bin:$PATH"
        antigen bundle macports
    fi
    antigen bundle osx
fi
if [[ $DISTRO == 'Ubuntu' ]]; then
    antigen bundle ubuntu
    antigen bundle command-not-found
fi
if type lando &>/dev/null; then
    antigen bundle lando
fi
antigen use oh-my-zsh
antigen bundle git
antigen bundle git-extras
antigen bundle git-flow
antigen bundle python
antigen bundle pyenv
antigen bundle sudo
antigen bundle web-search
antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle zsh-users/zsh-completions
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
    # Test for/enable iTerm2 integrations
    test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
fi
# export MANPATH="/usr/local/man:$MANPATH"

# Fix for prompts
PROMPT="$(echo -e "$PROMPT")
$ "

# Set wildcard (*) to affect dotfiles
setopt dotglob

# Disable '.' and '..' in tab completion
zstyle ':completion:*' special-dirs false

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
alias freq='cut -f2 -d";" ~/.zsh_history | cut -f1 -d" " | sort | uniq -c | sort -nr | head -n 30'
alias po='popd'
alias pu='pushd'
alias gbi='git bisect'
alias gbs='git-branch-status'
alias gcamsg='git add --all; git commit -m'
alias gla='git-pull-all'
alias glga='git log --graph --full-history --color --pretty=format:"%x1b[31m%h%x09%x1b[33m%d%x1b[0m%x20%s %x1b[32m(%ar) %x1b[34m%x1b[1m<%an>%x1b[0m" --abbrev-commit --date=relative'
alias glgnew="git log HEAD^..origin --graph --pretty='%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias gmev='git merge --no-ff --no-commit'
alias gmfo='git merge --ff-only'
alias gmnf='git merge --no-ff'
alias gpaa='git remote | xargs -I % sh -c '"'"'echo "Pushing to %..."; git push --all %; echo'"'"''
alias gpaat='git remote | xargs -I % sh -c '"'"'echo "Pushing to %..."; git push --all %; git push --tags %; echo'"'"''
alias gprt='git rev-parse --show-toplevel'
alias grfa='git show-ref --abbrev=7'
alias grft='git show-ref --abbrev=7 --tags'
alias grupp='git remote update -p'
alias gstau='git stash push -u'
alias gt='git tag'


#
# Everything else
#
if [[ $CURRENT_OS == 'OS X' ]]; then
    # The following lines were added by compinstall

    zstyle ':completion:*' completer _expand _complete _ignored
    zstyle ':completion:*' group-name ''
    zstyle ':completion:*' menu select=long
    zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
    zstyle :compinstall filename '$HOME/.zshrc'

    autoload -Uz compinit
    compinit
    # End of lines added by compinstall

    export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting
    [[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

    # iTerm2 only: set touch bar status label to current git branch
    test -d $HOME/.iterm2 && $HOME/.iterm2/it2check && {
        precmd() {
            BR=`git rev-parse --abbrev-ref HEAD 2>/dev/null`
            $HOME/.iterm2/it2setkeylabel set status ${BR:-_}
        }
    }
fi

if [[ -f $HOME/.zshrc.custom ]]; then
    source $HOME/.zshrc.custom
fi
