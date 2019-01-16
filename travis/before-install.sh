#!/bin/bash

# exit this script if any commmand fails
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# install cocos engin
if [ ! -f "$HOME/cocos2d-x-3.17.1/templates/cocos2dx_files.json" ]; then
    echo "install cocos engin..."
    wget https://digitalocean.cocos2d-x.org/Cocos2D-X/cocos2d-x-3.17.1.zip
    rm -rf $HOME/cocos2d-x-3.17.1
    unzip cocos2d-x-3.17.1.zip -d $HOME > /dev/null 2>&1
fi

# copy cocos engin
python ./travis/copy_cocos_x.py "$HOME/cocos2d-x-3.17.1" DIR "lua"
echo "copy dir: $DIR"

echo "before-install.sh execution finished!"
