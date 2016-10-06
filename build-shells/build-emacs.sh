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
    echo "not detected MinGW."
    echo "please launch from MinGW64/32 shell."
    exit
fi
echo "detected MSYS : ${MSYSTEM}"


readonly EMACS_ARCHIVE_URI="http://ftp.gnu.org/gnu/emacs/emacs-25.1.tar.xz"
readonly EMACS_ARCHIVE_NAME=$( basename "${EMACS_ARCHIVE_URI}" )
readonly EMACS_VERSION_NAME=$( basename --suffix ".tar.xz" "${EMACS_ARCHIVE_NAME}" )

readonly PATCH_URI="http://cha.la.coocan.jp/files/emacs-25.1-windows-ime-simple.patch"
readonly PATCH_NAME=$( basename "${PATCH_URI}" )

readonly PARENT_PATH=$( cd $(dirname ${0}) && pwd )
readonly EMACS_EXPORT_PATH="${PARENT_PATH}/build/${TARGET_PLATFORM}/${EMACS_VERSION_NAME}"


function download_from_web()
{
    echo "--- download_from_web : begin ---"

    # donwload from web
    if [ ! -f "${EMACS_ARCHIVE_NAME}" ]; then
        wget "${EMACS_ARCHIVE_URI}"
    fi

    if [ ! -f "${PATCH_NAME}" ]; then
        wget "${PATCH_URI}"
    fi

    # archive expand
    if [ ! -d "${EMACS_VERSION_NAME}" ]; then
        if [ -f "${EMACS_ARCHIVE_NAME}" ]; then
            tar -Jxvf "${EMACS_ARCHIVE_NAME}"
        fi
    fi

    echo "--- download_from_web : end ---"
}

    
# donwload from git repository
function download_from_git()
{
    echo "--- download_from_git : begin ---"

    if [ ! -d "${EMACS_VERSION_NAME}" ]; then
        mkdir "${EMACS_VERSION_NAME}"
    fi
    pushd "${EMACS_VERSION_NAME}"

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

    if [ -d "${EMACS_EXPORT_PATH}" ]; then
        rm -rf "${EMACS_EXPORT_PATH}"
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
    PKG_CONFIG_PATH="/mingw${TARGET_PLATFORM}/lib/pkgconfig" CFLAGS='-Ofast -march=corei7 -mtune=corei7' ./configure --prefix="${EMACS_EXPORT_PATH}" --without-imagemagick --without-dbus --with-modules --without-compress-install
    # PKG_CONFIG_PATH="/mingw${TARGET_PLATFORM}/lib/pkgconfig" CFLAGS='-Ofast -march=corei7 -mtune=corei7' ./configure --prefix="${EMACS_EXPORT_PATH}" --without-imagemagick --without-dbus --with-modules
    # PKG_CONFIG_PATH="/mingw${TARGET_PLATFORM}/lib/pkgconfig" CFLAGS='-Ofast -march=corei7 -mtune=corei7' ./configure --prefix="${EMACS_EXPORT_PATH}" "${ADDITIONAL_CONFIGURE_OPTIONS[@]}"
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


readonly EMACS_BINARY_EXPORT_PATH="${EMACS_EXPORT_PATH}/bin"
readonly SO_EXPORT_PATH="${EMACS_BINARY_EXPORT_PATH}"
readonly SO_IMPORT_PATH="/mingw${TARGET_PLATFORM}/bin"


readonly SO_BASE_LIST=(
    libgcc_s_seh-1.dll  #x86_64 only
    libgcc_s_dw2-1.dll  #x86 only
    libgnutls-30.dll
    libxml2-2.dll
    libXpm-noX4.dll
    libgif-7.dll
    libjpeg-8.dll
    libpng16-16.dll
    librsvg-2-2.dll
    libtiff-5.dll
)


function search_executable_files()
{
    local readonly  SEARCH_PATH="${1}"
    local readonly  TMP_ARRAY=( $( find "${SEARCH_PATH}" -type f -regex ".*\.exe$" -printf "%f\n" ) )

    echo "${TMP_ARRAY[@]}"
}

function search_dependent_files()
{
    local readonly  SEARCH_PATH="${1}"
    eval local readonly  PARENT_FILES=('${'"${2}"'[@]}')
    local TMP_ARRAY=()

    for FILE in "${PARENT_FILES[@]}"; do
        local readonly FILE_PATH="${SEARCH_PATH}/${FILE}"

        if [ -f "${FILE_PATH}" ]; then
            TMP_ARRAY+=( $(objdump -x "${FILE_PATH}" | grep --text "DLL Name:" | sed -e "s/^.*: \(.*\)/\1/") )
        fi
    done

    echo "${TMP_ARRAY[@]}"
}


function install_shared_objects()
{
    echo "--- install_shared_objects : begin ---"


    # glob dependency shared object
    local readonly EXECUTABLE_FILES=( $( search_executable_files "${EMACS_BINARY_EXPORT_PATH}" ) )
    local SO_DEPENDENT_LIST=()

    SO_DEPENDENT_LIST+=( $( search_dependent_files "${EMACS_BINARY_EXPORT_PATH}" "EXECUTABLE_FILES" ) )
    SO_DEPENDENT_LIST+=( $( search_dependent_files "${SO_IMPORT_PATH}" "SO_BASE_LIST" ) )

    local readonly SO_IMPORT_LIST=( $( printf "%s\n" "${SO_BASE_LIST[@]}" "${SO_DEPENDENT_LIST[@]}" | sort | uniq ) )

    echo " copy : ${SO_IMPORT_PATH} ==> ${SO_EXPORT_PATH}"
    for SO in "${SO_IMPORT_LIST[@]}"; do
        local readonly SO_PATH="${SO_IMPORT_PATH}/${SO}"

        if [ -f "${SO_PATH}" ]; then
            cp "${SO_PATH}" "${SO_EXPORT_PATH}"
            echo "  ${SO}"
        # else
        #     echo "--- install_shared_objects : ${SO_PATH} not found ---"
        fi
    done
    
    echo "--- install_shared_objects : end ---"
}


download_from_web
# download_from_git

pushd "${EMACS_VERSION_NAME}"

cleanup
apply_patch
execute_configure
build
install_shared_objects

popd


echo "---- ${0} : end ----"

