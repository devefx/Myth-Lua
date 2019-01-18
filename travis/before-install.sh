#!/bin/bash

# exit this script if any commmand fails
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$DIR"/..

function install_cocos2dx()
{
    COCOS2DX_FILENAME="${COCOS2DX_VERSION}.zip"
    COCOS2DX_DOWNLOAD_URL="https://digitalocean.cocos2d-x.org/Cocos2D-X/${COCOS2DX_FILENAME}"
    COCOS2DX_FILES_JSON="${COCOS2DX_ROOT}/templates/cocos2dx_files.json"

    if [ ! -f $COCOS2DX_FILES_JSON ]; then
        # download cocos2d-x
        if [ ! -f $COCOS2DX_FILENAME ]; then
            echo "Download ${COCOS2DX_DOWNLOAD_URL}"
            wget $COCOS2DX_DOWNLOAD_URL
        fi
        
        rm -rf $COCOS2DX_ROOT
        unzip $COCOS2DX_FILENAME -d "${COCOS2DX_ROOT}/.." > /dev/null 2>&1
    fi

    python travis/copy_cocos_x.py $COCOS2DX_ROOT $PROJECT_ROOT $PROJECT_TYPE
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
    python set_environment.py
    source ../environment.sh

    echo "======================================================="
    echo "COCOS2DX_VERSION=${COCOS2DX_VERSION}"
    echo "COCOS2DX_ROOT=${COCOS2DX_ROOT}"
    echo "PROJECT_TYPE=${PROJECT_TYPE}"
    echo "======================================================="

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
