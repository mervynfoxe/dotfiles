#!/bin/bash
############################
# makesymlinks.sh
# This script creates symlinks from the home directory to any desired dotfiles in ~/dotfiles
############################

########## Variables

dir=~/dotfiles                    # dotfiles directory
olddir=~/dotfiles.bak             # old dotfiles backup directory
##########

# create dotfiles_old in homedir
if [[ ! -d $olddir ]]; then
    echo "Creating $olddir for backup of any existing dotfiles in ~"
    mkdir -p $olddir
fi
cd $dir

# move any existing dotfiles in homedir to dotfiles_old directory, then create symlinks 
for file in *; do
    if [[ $file == "makesymlinks.sh" ]]; then
        continue
    fi
    echo ".$file"
    if [[ -f ~/.$file && ! -L ~/.$file ]]; then
        echo "Moving ~/.$file to $olddir..."
        mv ~/.$file $olddir/
    fi
    if [[ ! -L ~/.$file ]]; then
        echo "Creating symlink to $file..."
        ln -s $dir/$file ~/.$file
    else
        echo "Symlink already exists"
    fi
    echo ''
done

