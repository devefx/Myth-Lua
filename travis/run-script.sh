#!/bin/bash

# exit this script if any commmand fails
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

function build_android_ndk-build()
{
    echo "Building Android ..."
    
    pushd $DIR/frameworks/runtime-src/proj.android
    ./gradlew assembleRelease -PPROP_BUILD_TYPE=ndk-build --parallel --info
    popd
}

function build_android_cmake()
{
    echo "Building Android ..."

    pushd $DIR/frameworks/runtime-src/proj.android
    do_retry ./gradlew assembleRelease -PPROP_BUILD_TYPE=cmake --parallel --info
    popd
}

function run_pull_request()
{
    echo "Building pull request ..."

    # android
    if [ $BUILD_TARGET == 'android_ndk-build' ]; then
        build_android_ndk-build
    fi

    # android
    if [ $BUILD_TARGET == 'android_cmake' ]; then
        build_android_cmake
    fi
}

# build pull request
if [ "$TRAVIS_PULL_REQUEST" != "false" ]; then
    run_pull_request
fi

echo "run-script.sh execution finished!"
