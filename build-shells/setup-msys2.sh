# -*- mode: shell-script ; coding: utf-8-unix -*-
#! /bin/sh


TARGET_PLATFORM=x86_64

if [ "${1}" = "--x32" ]; then 
    TARGET_PLATFORM=i686
fi


pacman -Sy

# pacman -S --noconfirm mingw-w64-${TARGET_PLATFORM}


readonly PACKAGE_LIST=(
    svn
    git
    base-devel
    mingw-w64-${TARGET_PLATFORM}-toolchain
    mingw-w64-${TARGET_PLATFORM}-xpm-nox
    mingw-w64-${TARGET_PLATFORM}-libtiff
    mingw-w64-${TARGET_PLATFORM}-giflib
    mingw-w64-${TARGET_PLATFORM}-libpng
    mingw-w64-${TARGET_PLATFORM}-libjpeg-turbo
    mingw-w64-${TARGET_PLATFORM}-librsvg
    mingw-w64-${TARGET_PLATFORM}-libxml2
    mingw-w64-${TARGET_PLATFORM}-gnutls
)


pacman --needed -S --noconfirm "${PACKAGE_LIST[@]}"

