#!/bin/bash

# exit this script if any commmand fails
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$DIR"/..

function do_retry()
{
    cmd=$@
    retry_times=5
    retry_wait=3
    c=0
    while [ $c -lt $((retry_times+1)) ]; do
        c=$((c+1))
        echo "Executing \"$cmd\", try $c"
        $cmd && return $?
        if [ ! $c -eq $retry_times ]; then
            echo "Command failed, will retry in $retry_wait secs"
            sleep $retry_wait
        else
            echo "Command failed, giving up."
            return 1
        fi
    done
}

function build_android_cmake()
{
    echo "Building Android ..."

    pushd $PROJECT_ROOT/frameworks/runtime-src/proj.android
    do_retry ./gradlew assembleRelease -PPROP_BUILD_TYPE=cmake --parallel --info
    popd
}

function genernate_binding_codes()
{
    if [ $TRAVIS_OS_NAME == "linux" ]; then
        # print some log for libstdc++6
        strings /usr/lib/x86_64-linux-gnu/libstdc++.so.6 | grep GLIBC
        ls -l /usr/lib/x86_64-linux-gnu/libstdc++*
        dpkg-query -W libstdc++6
        ldd $COCOS2DX_ROOT/tools/bindings-generator/libclang/libclang.so
    fi

    if [ "$TRAVIS_OS_NAME" == "osx" ]; then
        eval "$(pyenv init -)"
    fi
    which python

    # Generate binding glue codes
    echo "Create auto-generated luabinding glue codes."
    pushd "$COCOS2DX_ROOT/tools/tolua"
    python ./genbindings.py
    popd
}

function run_building()
{
    echo "Building ..."

    source travis_caches/environment.sh

    echo "======================================================="
    echo "COCOS2DX_ROOT=${COCOS2DX_ROOT}"
    echo "ANDROID_NDK_HOME=${ANDROID_NDK_HOME}"
    echo "COCOS_CONSOLE_ROOT=${COCOS_CONSOLE_ROOT}"
    echo "======================================================="

    # need to generate binding codes for all targets
    genernate_binding_codes

    # android
    if [ $BUILD_TARGET == 'android_cmake' ]; then
        build_android_cmake
    fi
}

run_building

ls -a

echo "run-script.sh execution finished!"
