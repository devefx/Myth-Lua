#!/bin/bash

# exit this script if any commmand fails
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$DIR"/..
PROJECT_LANG="lua"
#export COCOS2DX_VERSION="cocos2d-x-3.17.1"
#export COCOS2DX_ROOT=$HOME/$COCOS2DX_VERSION
COCOS2DX_FILES_JSON=$COCOS2DX_ROOT/templates/cocos2dx_files.json
COCOS2DX_FILENAME=$COCOS2DX_VERSION".zip"
COCOS2DX_DOWNLOAD_URL="https://digitalocean.cocos2d-x.org/Cocos2D-X/${COCOS2DX_FILENAME}"

function install_cocos2dx()
{
    if [ ! -f $COCOS2DX_FILES_JSON ]; then
        echo "Download ${COCOS2DX_DOWNLOAD_URL}"
        wget $COCOS2DX_DOWNLOAD_URL
        rm -rf $COCOS2DX_ROOT
        unzip $COCOS2DX_FILENAME -d $HOME > /dev/null 2>&1
    fi

    python travis/copy_cocos_x.py $COCOS2DX_ROOT $PROJECT_ROOT $PROJECT_LANG
}

function install_android_ndk()
{
    sudo python -m pip install retry
    if [ "$BUILD_TARGET" == "android_ndk-build" ]\
        || [ "$BUILD_TARGET" == "android_lua_ndk-build" ]\
        || [ "$BUILD_TARGET" == "android_cmake" ]\
        || [ "$BUILD_TARGET" == "android_js_cmake" ]\
        || [ "$BUILD_TARGET" == "android_lua_cmake" ] ; then
        python $COCOS2DX_ROOT/tools/appveyor-scripts/setup_android.py
    else
        python $COCOS2DX_ROOT/tools/appveyor-scripts/setup_android.py --ndk_only
    fi
}

function install_linux_environment()
{
    echo "Installing linux dependence packages ..."
    echo -e "y" | bash $COCOS2DX_ROOT/build/install-deps-linux.sh
    echo "Installing linux dependence packages finished!"
}

function install_python_module_for_osx()
{
    pip install PyYAML
    sudo pip install Cheetah
}

function install_latest_python()
{
    python -V
    eval "$(pyenv init -)"
    pyenv install 2.7.14
    pyenv global 2.7.14
    python -V
}

function install_environement()
{
    if [ "$TRAVIS_OS_NAME" == "linux" ]; then
        sudo apt-get update
        sudo apt-get install ninja-build
        ninja --version
        if [ "$BUILD_TARGET" == "linux" ]; then
            install_linux_environment
        fi
    fi

    if [ "$TRAVIS_OS_NAME" == "osx" ]; then
        install_latest_python
        install_python_module_for_osx
    fi

    install_cocos2dx
    install_android_ndk
}

install_environement

echo "before-install.sh execution finished!"
