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

function build_android_ndk-build()
{
    echo "Building Android ..."
    
    pushd $PROJECT_ROOT/frameworks/runtime-src/proj.android
    do_retry ./gradlew assembleRelease -PPROP_BUILD_TYPE=ndk-build --parallel --info
    popd
}

function build_android_cmake()
{
    echo "Building Android ..."

    pushd $PROJECT_ROOT/frameworks/runtime-src/proj.android
    do_retry ./gradlew assembleRelease -PPROP_BUILD_TYPE=cmake --parallel --info
    popd
}

function build_mac_cmake()
{
    NUM_OF_CORES=`getconf _NPROCESSORS_ONLN`

    cd $PROJECT_ROOT
    mkdir -p mac_cmake_build
    cd mac_cmake_build
    cmake .. -GXcode
    # cmake --build .
    xcodebuild -project myth-lua.xcodeproj -alltargets -jobs $NUM_OF_CORES build  | xcpretty
    #the following commands must not be removed
    xcodebuild -project myth-lua.xcodeproj -alltargets -jobs $NUM_OF_CORES build
    exit 0
}

function build_ios_cmake()
{
    NUM_OF_CORES=`getconf _NPROCESSORS_ONLN`

    cd $PROJECT_ROOT
    mkdir -p ios_cmake_build
    cd ios_cmake_build
    cmake .. -DCMAKE_TOOLCHAIN_FILE=$PROJECT_ROOT/frameworks/cocos2d-x/cmake/ios.toolchain.cmake -GXcode -DIOS_PLATFORM=SIMULATOR64
    # too much logs on console when "cmake --build ."
    # cmake --build .
    xcodebuild -project myth-lua.xcodeproj -alltargets -jobs $NUM_OF_CORES  -destination "platform=iOS Simulator,name=iPhone Retina (4-inch)" build  | xcpretty
    #the following commands must not be removed
    xcodebuild -project myth-lua.xcodeproj -alltargets -jobs $NUM_OF_CORES  -destination "platform=iOS Simulator,name=iPhone Retina (4-inch)" build
    exit 0
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

    if [ $BUILD_TARGET == 'mac_cmake' ]; then
        build_mac_cmake
    fi

    if [ $BUILD_TARGET == 'ios_cmake' ]; then
        build_ios_cmake
    fi
}

# build pull request
run_pull_request

echo "run-script.sh execution finished!"
