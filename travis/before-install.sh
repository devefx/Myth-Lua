#!/bin/bash

# exit this script if any commmand fails
set -e

# install cocos engin
if [ ! -d "./cocos2d-x-3.17.1" ]; then
    echo "install cocos engin..."
    wget https://digitalocean.cocos2d-x.org/Cocos2D-X/cocos2d-x-3.17.1.zip
    unzip cocos2d-x-3.17.1.zip
fi

echo "before-install.sh execution finished!"