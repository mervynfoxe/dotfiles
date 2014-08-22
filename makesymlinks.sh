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
    if [[ $file = "makesymlinks.sh" ]]; then
        continue
    fi
    echo ".$file"
    if [[ ! -L ~/.$file ]]; then
        echo "Moving any existing file to ${olddir}..."
        mv ~/.$file $olddir/
        echo "Creating symlink at ~/.${file}..."
        ln -s $dir/$file ~/.$file
    else
        echo "Symlink already exists"
    fi
    echo ''
done

