#!/bin/bash

# exit this script if any commmand fails
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

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

function build_android_ndk-build()
{
    echo "Building Android ..."
    
    pushd $DIR/frameworks/runtime-src/proj.android
    do_retry ./gradlew assembleRelease -PPROP_BUILD_TYPE=ndk-build --parallel --info
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
run_pull_request

echo "run-script.sh execution finished!"
