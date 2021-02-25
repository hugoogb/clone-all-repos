#!/bin/bash

RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'

BOLD='\033[1m'
ITALIC='\033[3m'
NORMAL="\033[0m"

color_print() {
  if [ -t 1 ]; then
    echo -e "$@$NORMAL"
  else
    echo "$@" | sed "s/\\\033\[[0-9;]*m//g"
  fi
}

stderr_print() {
  color_print "$@" >&2
}

warn() {
  stderr_print "$YELLOW$1"
}

error() {
  stderr_print "$RED$1"
  exit 1
}

info() {
  color_print "$CYAN$1"
}

ok() {
  color_print "$GREEN$1"
}

program_exists() {
  command -v $1 &> /dev/null
}

ACTUAL_DIR=`pwd`
PROJECTS_FOLDER=$HOME/projects
REPOS_LISTS=$PROJECTS_FOLDER/clone-all-repos/repos

projects_folder() {
    if [ ! -d $PROJECTS_FOLDER ]; then
        mkdir $PROJECTS_FOLDER
    fi
}

clone_repos_home() {
    file=$REPOS_LISTS/repos_home.txt
    lines=`wc -l < $file`
    i=1
    
    while [ $i -le $lines ]
    do
        repo=`head -$i $file | tail -1`

        ok "OK: cloning $repo repo..."

        if [ ! -d $HOME/$repo ]; then
            if program_exists "ssh"; then
                git clone git@github.com:hugoogb/$repo.git $HOME/$repo
            else
                git clone https://github.com/hugoogb/$repo.git $HOME/$repo
            fi
        else 
            warn "WARNING: $repo already cloned"
            info "INFO: updating $repo repo..."

            cd $HOME/$repo
            git pull origin master
            cd $ACTUAL_DIR
        fi

        let i=i+1
    done
}

clone_repos_projects_folder() {
    file=$REPOS_LISTS/repos_projects.txt
    lines=`wc -l < $file`
    i=1

    while [ $i -le $lines ]
    do
        repo=`head -$i $file | tail -1`

        ok "OK: cloning $repo repo..."

        if [ ! -d $PROJECTS_FOLDER/$repo ]; then
            if program_exists "ssh"; then
                git clone git@github.com:hugoogb/$repo.git $PROJECTS_FOLDER/$repo
            else
                git clone https://github.com/hugoogb/$repo.git $PROJECTS_FOLDER/$repo
            fi
        else 
            warn "WARNING: $repo already cloned"
            info "INFO: updating $repo repo..."

            cd $PROJECTS_FOLDER/$repo
            git pull origin master
            cd $ACTUAL_DIR
        fi

        let i=i+1
    done
}

main() {
    projects_folder
    clone_repos_home
    clone_repos_projects_folder
}

main