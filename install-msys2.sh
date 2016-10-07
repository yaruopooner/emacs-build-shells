# -*- mode: shell-script ; coding: utf-8-unix -*-
#! /bin/sh

# preset vars
MSYS2_URI="http://jaist.dl.sourceforge.net/project/msys2/Base/x86_64/msys2-base-x86_64-20160921.tar.xz"
MSYS2_LAUNCH_SHELL="mingw64.exe"

# overwrite vars load
if [ -e "./install-msys2.options" ]; then
    . "./install-msys2.options"
fi


readonly MSYS2_ARCHIVE=$( basename "${MSYS2_URI}" )


# donwload from web
wget --timestamping "${MSYS2_URI}"


# archive expand
if [ -e "${MSYS2_ARCHIVE}" -a ! -d msys64 ]; then
    tar -Jxvf "${MSYS2_ARCHIVE}"
fi

if [ -d msys64 ]; then
    readonly TMP_DIR="msys64/tmp"
    cp -R build-shells "${TMP_DIR}"

    unset HOME

    pushd msys64

    readonly MSYS_ROOT_PATH=$( pwd )

    "./${MSYS2_LAUNCH_SHELL}"

    popd

    echo $HOME

    # pushd "${TMP_DIR}/build-shells"

    # ${MSYS_ROOT_PATH}/mingw64.exe ./sample.h
fi

