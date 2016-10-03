# -*- mode: shell-script ; coding: utf-8-unix -*-
#! /bin/sh


readonly MSYS2_ARCHIVE="msys2-base-x86_64-20160921.tar.xz"
readonly MSYS2_URI="http://jaist.dl.sourceforge.net/project/msys2/Base/x86_64/${MSYS2_ARCHIVE}"


if [ ! -f "${MSYS2_ARCHIVE}" ]; then
    wget "${MSYS2_URI}"
fi

if [ -f "${MSYS2_ARCHIVE}" -a ! -d msys64 ]; then
    tar -Jxvf "${MSYS2_ARCHIVE}"
fi


unset HOME

pushd msys64

readonly MSYS_ROOT_PATH=$(pwd)

./mingw64.exe
popd

echo $HOME

readonly TMP_DIR="msys64/tmp"

cp -R build-shells "${TMP_DIR}"

# pushd "${TMP_DIR}/build-shells"

# ${MSYS_ROOT_PATH}/mingw64.exe ./sample.h
