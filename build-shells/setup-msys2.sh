# -*- mode: shell-script ; coding: utf-8-unix -*-
#! /bin/sh


echo -e "\n---- ${0} : begin ----\n"


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
declare -r SETUP_MSYS2_OPTIONS_FILE="setup-msys2.options"

if [ -e "./${SETUP_MSYS2_OPTIONS_FILE}" ]; then
    . "./${SETUP_MSYS2_OPTIONS_FILE}"
fi


readonly PACKAGE_LIST=( "${BASE_PACKAGE_LIST[@]}" "${ADDITIONAL_PACKAGE_LIST[@]}" )


echo -e "\n---- ${0} : requested package list ----\n"


printf "%s\n" "${PACKAGE_LIST[@]}"


echo -e "\n---- ${0} : refresh and upgrade ----\n"


# pacman <operation> [options] [targets]
# Operation
# -S --sync
# Options
# -y, --refresh        サーバーから最新のパッケージデータベースをダウンロード(-yy で最新の場合も強制的に更新を行う)
# -u, --sysupgrade     インストールしたパッケージのアップグレード (-uu でダウングレードを有効)
# --needed             最新のパッケージを再インストールさせない

pacman -Syuu --noconfirm


echo -e "\n---- ${0} : install package ----\n"


pacman -S --needed --noconfirm "${PACKAGE_LIST[@]}"


echo -e "\n---- ${0} : end ----\n"

