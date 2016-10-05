# -*- mode: shell-script ; coding: utf-8-unix -*-
#! /bin/sh



echo "---- ${0} : begin ----"


if [ "${MSYSTEM}" = "MINGW64" ]; then
    readonly TARGET_PLATFORM=x86_64
elif [ "${MSYSTEM}" = "MINGW32" ]; then
    readonly TARGET_PLATFORM=i686
elif [ -z "${MSYSTEM}" ]; then
    echo "not detected MinGW."
    echo "please launch from MinGW64/32 shell."
    exit
fi
echo "detected MSYS : ${MSYSTEM}"



pacman -Sy

# pacman -S --noconfirm mingw-w64-${TARGET_PLATFORM}


readonly PACKAGE_LIST=(
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


pacman --needed -S --noconfirm "${PACKAGE_LIST[@]}"


echo "---- ${0} : end ----"

