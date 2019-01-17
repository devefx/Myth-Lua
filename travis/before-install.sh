#!/bin/bash

# exit this script if any commmand fails
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$DIR"/..

# install cocos engin
if [ ! -f "$HOME/cocos2d-x-3.17.1/templates/cocos2dx_files.json" ]; then
    echo "install cocos engin..."
    wget https://digitalocean.cocos2d-x.org/Cocos2D-X/cocos2d-x-3.17.1.zip
    rm -rf $HOME/cocos2d-x-3.17.1
    unzip cocos2d-x-3.17.1.zip -d $HOME > /dev/null 2>&1
fi

# Add environment variable COCOS_CONSOLE_ROOT for cocos2d-x
export COCOS_CONSOLE_ROOT=$HOME/cocos2d-x-3.17.1/tools/cocos2d-console/bin
export PATH=$COCOS_CONSOLE_ROOT:$PATH

# Add environment variable COCOS_X_ROOT for cocos2d-x
export COCOS_X_ROOT=$HOME/cocos2d-x-3.17.1
export PATH=$COCOS_X_ROOT:$PATH

# Add environment variable COCOS_TEMPLATES_ROOT for cocos2d-x
export COCOS_TEMPLATES_ROOT=$HOME/cocos2d-x-3.17.1/templates
export PATH=$COCOS_TEMPLATES_ROOT:$PATH

# copy cocos engin
python ./travis/copy_cocos_x.py "$HOME/cocos2d-x-3.17.1" $PROJECT_ROOT "lua"


echo "before-install.sh execution finished!"
