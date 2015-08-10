#!/bin/bash
############################
# makesymlinks.sh
# This script creates symlinks from the home directory to any desired dotfiles in ~/dotfiles
############################

########## Variables

dir=~/dotfiles                    # dotfiles directory
olddir=~/dotfiles.bak             # old dotfiles backup directory
ignore=( "icon.png"
         "makesymlinks.sh"
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

# create dotfiles_old in homedir
if [[ ! -d $olddir ]]; then
    echo "Creating $olddir for backup of any existing dotfiles in ~"
    mkdir -p $olddir
fi
cd $dir

# move any existing dotfiles in homedir to dotfiles_old directory, then create symlinks 
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

