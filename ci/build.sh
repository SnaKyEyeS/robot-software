#!/usr/bin/env bash

# Make the script fail if any command in it fail
set -e

if [ "$BUILD_TYPE" == "" ]
then
    echo "Please define \$BUILD_TYPE!"
    exit 1
fi

source env/bin/activate
PROJPATH=$(pwd)

export PATH=$PROJPATH/gcc-arm-none-eabi-8-2018-q4-major/bin/:$PATH
export PATH=$PROJPATH/protoc/bin/:$PATH

export CFLAGS="$CFLAGS -I $HOME/cpputest/include/"
export CXXFLAGS="$CXXFLAGS -I $HOME/cpputest/include/"
export LDFLAGS="$CXXFLAGS -L $HOME/cpputest/lib/"

case $BUILD_TYPE in
    tests)
        pushd master-firmware
        packager
        make protoc
        mkdir -p build
        cd build
        cmake ..
        make check
        popd

        pushd motor-control-firmware
        packager
        mkdir -p build
        cd build
        cmake ..
        make check
        popd

        pushd uwb-beacon-firmware
        packager
        mkdir -p build
        cd build
        cmake ..
        make check
        popd

        ;;

    build)
        echo "build $PLATFORM"
        pushd $PLATFORM
        packager
        make dsdlc

        if [ "$PLATFORM" == "master-firmware" ]
        then
            make protoc
        fi

        make
        popd
        ;;

    computer-vision)
        mkdir -p computer-vision/build
        pushd computer-vision/build
        cmake ..
        make all
        popd
        ;;

    *)
        echo "Unknown build type $BUILD_TYPE"
        exit 1
        ;;
esac
