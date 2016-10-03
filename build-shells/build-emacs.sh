# -*- mode: shell-script ; coding: utf-8-unix -*-
#! /bin/sh


# git config --global http.proxy ${http_proxy}
# git config --global https.proxy ${https_proxy}
# git config --global url."https://".insteadOf git://
# git config --global core.ignorecase false
# git config --global core.autocrlf false
# export GIT_TRACE_PACKET=1
# export GIT_TRACE=1
# export GIT_CURL_VERBOSE=1


echo "---- ${0} : begin ----"


if [ "${MSYSTEM}" = "MINGW64" ]; then
    readonly TARGET_PLATFORM=64
elif [ "${MSYSTEM}" = "MINGW32" ]; then
    readonly TARGET_PLATFORM=32
elif [ -z "${MSYSTEM}" ]; then
    echo "not detected MSYS."
    echo "please launch from MSYS shell."
    exit
fi
echo "detected MSYS : ${MSYSTEM}"



readonly FILE_NAME="emacs-25.1"
readonly FULL_NAME="${FILE_NAME}.tar.xz"

readonly PATCH_NAME="emacs-25.1-windows-ime-simple.patch"

readonly PARENT_PATH=$(cd $(dirname ${0}) && pwd)
readonly EMACS_BINARY_EXPORT_PATH="${PARENT_PATH}/build/${TARGET_PLATFORM}/${FILE_NAME}"


function download_from_web()
{
    echo "--- download_from_web : begin ---"

    # donwload from web
    if [ ! -f "${FULL_NAME}" ]; then
        wget "http://ftp.gnu.org/gnu/emacs/${FULL_NAME}"
    fi

    if [ ! -f "${PATCH_NAME}" ]; then
        wget "http://cha.la.coocan.jp/files/${PATCH_NAME}"
    fi

    # archive expand
    if [ ! -d "${FILE_NAME}" ]; then
        if [ -f "${FULL_NAME}" ]; then
            tar -Jxvf "${FULL_NAME}"
        fi
    fi

    echo "--- download_from_web : end ---"
}

    
# donwload from git repository
function download_from_git()
{
    echo "--- download_from_git : begin ---"

    if [ ! -d "${FILE_NAME}" ]; then
        mkdir "${FILE_NAME}"
    fi
    pushd "${FILE_NAME}"

    # curl --proxy "${http_proxy}"
    # git clone git://git.sv.gnu.org/emacs.git emacs-25
    # git clone git://git.sv.gnu.org/emacs.git emacs-25.1
    # git clone git://git.sv.gnu.org/emacs.git
    popd

    echo "--- download_from_git : end ---"
}


# cleanup ( use necessary old Makefile before ./configure  )
function cleanup()
{
    echo "--- cleanup : begin ---"

    if [ -f "Makefile" ]; then
        make clean
        make bootstrap-clean
        # make uninstall
    fi

    if [ -d "${EMACS_BINARY_EXPORT_PATH}" ]; then
        rm -rf "${EMACS_BINARY_EXPORT_PATH}"
    fi

    echo "--- cleanup : end ---"
}


# patch
function apply_patch()
{
    echo "--- apply_patch : begin ---"

    if [ -f "../${PATCH_NAME}" ]; then
        patch -N -b -p0 < "../${PATCH_NAME}"
        local readonly RESULT=$?

        if [ ${RESULT} -eq 0 ]; then
            echo "--- apply_patch : applied ---"
            autoconf
        elif [ ${RESULT} -eq 1 ]; then
            echo "--- apply_patch : already applied ---"
        fi
    fi

    echo "--- apply_patch : end ---"
}



# configure generation and execution
function execute_configure()
{
    echo "--- execute_configure : begin ---"

    # 'autogen.sh' generates 'configure' and other files
    ./autogen.sh
    echo "--- execute_configure : generated configure ---"

    # if [ ! -f "configure" ]; then
    #     ./autogen.sh
    #     echo "--- configure : generated ---"
    # else
    #     echo "--- configure : already exist ---"
    # fi

    # 64/32bit
    PKG_CONFIG_PATH="/mingw${TARGET_PLATFORM}/lib/pkgconfig" CFLAGS='-Ofast -march=corei7 -mtune=corei7' ./configure --prefix="${EMACS_BINARY_EXPORT_PATH}" --without-imagemagick --without-dbus --with-modules --without-compress-install
    # PKG_CONFIG_PATH="/mingw${TARGET_PLATFORM}/lib/pkgconfig" CFLAGS='-Ofast -march=corei7 -mtune=corei7' ./configure --prefix="${EMACS_BINARY_EXPORT_PATH}" --without-imagemagick --without-dbus --with-modules
    echo "--- execute_configure : generated makefile ---"

    echo "--- execute_configure : end ---"
}


function build()
{
    echo "--- build : begin ---"
    # make -j
    # make -j bootstrap
    make bootstrap
    make install

    echo "--- build : end ---"
}


readonly SO_IMPORT_PATH="/mingw${TARGET_PLATFORM}/bin"
readonly SO_EXPORT_PATH="${EMACS_BINARY_EXPORT_PATH}/bin"


readonly SO_LIST=(
    libgcc_s_seh-1.dll  #x86_64 only
    libgcc_s_dw2-1.dll  #x86 only
    libgdk_pixbuf-2.0-0.dll
    libgif-7.dll
    libglib-2.0-0.dll
    libgnutls-30.dll
    libgmp-10.dll
    libhogweed-4-2.dll
    libidn-11.dll
    libnettle-6-2.dll
    libp11-kit-0.dll
    libtasn1-6.dll
    libffi-6.dll
    libintl-8.dll
    libgobject-2.0-0.dll
    libiconv-2.dll
    libjpeg-8.dll
    libpng16-16.dll
    librsvg-2-2.dll
    libtiff-5.dll
    liblzma-5.dll
    libwinpthread-1.dll
    libxml2-2.dll
    libXpm-noX4.dll
    zlib1.dll
)

function install_shared_objects()
{
    echo "--- install_shared_objects : begin ---"

    for so in "${SO_LIST[@]}"; do
        local readonly SO_PATH="${SO_IMPORT_PATH}/${so}"

        if [ -f "${SO_PATH}" ]; then
            cp "${SO_PATH}" "${SO_EXPORT_PATH}"
        else
            echo "--- install_shared_objects : ${SO_PATH} not found ---"
        fi
    done

    echo "--- install_shared_objects : end ---"
}


download_from_web
# download_from_git

pushd "${FILE_NAME}"

cleanup
apply_patch
execute_configure
build
install_shared_objects

popd


echo "---- ${0} : end ----"

