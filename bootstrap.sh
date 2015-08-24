#!/bin/bash
############################
# bootstrap.sh
# This script creates symlinks from the home directory to any desired dotfiles in ~/dotfiles
############################

########## Variables

dir=~/dotfiles                    # dotfiles directory
olddir=~/dotfiles.bak             # old dotfiles backup directory
ignore=( "icon.png"
         ".gitmodules"
         "bootstrap.sh"
         "powerline-fonts" )      # items to ignore when making symlinks
##########

array_contains() {
    local haystack="$1[@]"
    local needle=$2
    local found=1
    for item in "${!haystack}"; do
        if [[ $item == $needle ]]; then
            found=0
            break
        fi
    done
    return $found
}

echo "Backing up existing dotfiles..."
# Create dotfiles_old in homedir
if [[ ! -d $olddir ]]; then
    echo "Creating '${olddir}'..."
    mkdir -p $olddir
fi
cd $dir

# Move any existing dotfiles in homedir to dotfiles_old directory
# then create symlinks
for file in *; do
    array_contains ignore $file && continue
    echo ".$file"
    if [[ ! -L ~/.$file ]]; then
        if [[ -f ~/.$file ]]; then
            echo "Moving ~/.$file to ${olddir}..."
            mv ~/.$file $olddir/
        fi
        echo "Creating symlink to ${file}..."
        ln -s $dir/$file ~/.$file
    else
        echo "Symlink already exists"
    fi
    echo ''
done

echo "Initializing submodules..."
git submodule init
git submodule update --remote --recursive

echo "Installing Powerline fonts..."
./powerline-fonts/install.sh

echo "Done."
# Determine shell that called this script
parent=$(ps $PPID | tail -n 1 | awk "{print \$5}")
if [[ $parent == "zsh" ]]; then
    echo "Please run 'source ~/.zshrc' to reload configuration."
elif [[ $parent == "bash" ]]; then
    echo "Please run 'source ~/.bashrc' to reload configuration."
fi

