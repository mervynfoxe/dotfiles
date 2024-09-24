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

# OS-specific Antigen plugins
if [[ $CURRENT_OS == 'macOS' ]]; then
    antigen bundle osx

    if type brew &>/dev/null; then
        antigen bundle brew
    fi
    if type port &>/dev/null; then
        antigen bundle macports
    fi
fi
if [[ $DISTRO == 'Ubuntu' ]]; then
    antigen bundle ubuntu
    antigen bundle command-not-found
fi
if type lando &>/dev/null; then
    antigen bundle lando
fi

antigen use oh-my-zsh
antigen bundle git-flow
antigen bundle git
antigen bundle git-extras
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
elif [[ $CURRENT_OS == 'macOS' ]]; then
    # Set up tab completion for ssh hosts
    zstyle -s ':completion:*:hosts' hosts _ssh_config
    [[ -r ~/.ssh/config ]] && _ssh_config+=($(cat ~/.ssh/config | sed -ne 's/Host[=\t ]//p'))
    zstyle ':completion:*:hosts' hosts $_ssh_config
fi


#
# Aliases
#

# Pull in global alias overrides
test -e "$DOTFILES_DIR/_inc/aliases" && source "$DOTFILES_DIR/_inc/aliases"

alias freq='cut -f2 -d";" ~/.zsh_history | cut -f1 -d" " | sort | uniq -c | sort -nr | head -n 30'
alias gpaa='git remote | xargs -I % sh -c '"'"'echo "Pushing to %..."; git push --all %; echo'"'"''
alias gpaat='git remote | xargs -I % sh -c '"'"'echo "Pushing to %..."; git push --all %; git push --tags %; echo'"'"''

if is::gitpod; then
    # Remove conflict with gitpod's executable
    unalias gp
fi


#
# Everything else
#
if [[ $CURRENT_OS == 'macOS' ]]; then
    # The following lines were added by compinstall

    zstyle ':completion:*' completer _expand _complete _ignored
    zstyle ':completion:*' group-name ''
    zstyle ':completion:*' menu select=long
    zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
    zstyle :compinstall filename '$HOME/.zshrc'

    autoload -Uz compinit
    compinit
    # End of lines added by compinstall
fi

if [[ -f $HOME/.zshrc.custom ]]; then
    source $HOME/.zshrc.custom
fi
