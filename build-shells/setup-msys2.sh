# -*- mode: shell-script ; coding: utf-8-unix -*-
#! /bin/sh


echo "---- ${0} : begin ----"


# environment detection 
if [ "${MSYSTEM}" = "MINGW64" ]; then
    readonly TARGET_PLATFORM=x86_64
elif [ "${MSYSTEM}" = "MINGW32" ]; then
    readonly TARGET_PLATFORM=i686
elif [ -z "${MSYSTEM}" ]; then
    echo "not detected MinGW."
    echo "please launch from MinGW64/32 shell."
    exit 1
fi
echo "detected MSYS : ${MSYSTEM}"



# preset vars
readonly BASE_PACKAGE_LIST=(
    svn
    git
    base-devel
    mingw-w64-${TARGET_PLATFORM}-toolchain
    mingw-w64-${TARGET_PLATFORM}-gnutls
    mingw-w64-${TARGET_PLATFORM}-xpm-nox
    mingw-w64-${TARGET_PLATFORM}-giflib
    mingw-w64-${TARGET_PLATFORM}-libtiff
    mingw-w64-${TARGET_PLATFORM}-libpng
    mingw-w64-${TARGET_PLATFORM}-libjpeg-turbo
    mingw-w64-${TARGET_PLATFORM}-librsvg
    mingw-w64-${TARGET_PLATFORM}-libxml2
)

ADDITIONAL_PACKAGE_LIST=()


# overwrite vars load
if [ -e "./setup-msys2.options" ]; then
    . "./setup-msys2.options"
fi


readonly PACKAGE_LIST=( "${BASE_PACKAGE_LIST[@]}" "${ADDITIONAL_PACKAGE_LIST[@]}" )


echo "---- ${0} : requested package list ----"
printf "%s\n" "${PACKAGE_LIST[@]}"



echo "---- ${0} : install package ----"

pacman -Sy
pacman --needed -S --noconfirm "${PACKAGE_LIST[@]}"


echo "---- ${0} : end ----"

