# -*- mode: shell-script ; coding: utf-8-unix -*-
#! /bin/sh

# preset vars
MSYS2_ARCHIVE_URI="http://jaist.dl.sourceforge.net/project/msys2/Base/x86_64/msys2-base-x86_64-20160921.tar.xz"
MSYS2_LAUNCH_SHELL="mingw64.exe"

# overwrite vars load
if [ -e "./install-msys2.sh.options" ]; then
    . "./install-msys2.sh.options"
fi


readonly MSYS2_ARCHIVE_NAME=$( basename "${MSYS2_ARCHIVE_URI}" )


# donwload from web
wget --timestamping "${MSYS2_ARCHIVE_URI}"


# archive expand
if $( [ -e "${MSYS2_ARCHIVE_NAME}" ] && [ ! -d msys64 ] ); then
    tar -xvf "${MSYS2_ARCHIVE_NAME}"
fi

if [ -d msys64 ]; then
    readonly TMP_DIR="msys64/tmp"
    \cp -Rup build-shells "${TMP_DIR}"

    unset HOME

    pushd msys64

    readonly MSYS_ROOT_PATH=$( pwd )

    "./${MSYS2_LAUNCH_SHELL}"

    popd

    echo $HOME

    # pushd "${TMP_DIR}/build-shells"

    # ${MSYS_ROOT_PATH}/mingw64.exe ./start.h
fi

