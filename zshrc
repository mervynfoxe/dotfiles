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
