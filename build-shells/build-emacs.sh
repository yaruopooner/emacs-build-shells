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


# environment detection 
if [ "${MSYSTEM}" = "MINGW64" ]; then
    declare -r TARGET_PLATFORM=64
elif [ "${MSYSTEM}" = "MINGW32" ]; then
    declare -r TARGET_PLATFORM=32
elif [ -z "${MSYSTEM}" ]; then
    echo "not detected MinGW."
    echo "please launch from MinGW64/32 shell."
    exit 1
fi
echo "detected MSYS : ${MSYSTEM}"



# preset vars
# BUILD_FROM=repository
BUILD_FROM=archive
EMACS_GIT_REPOSITORY="https://github.com/emacs-mirror/emacs.git"
EMACS_CHECKOUT_BRANCH=""
EMACS_ARCHIVE_URI="http://ftp.gnu.org/gnu/emacs/emacs-25.1.tar.xz"
EMACS_PATCH_URI="http://cha.la.coocan.jp/files/emacs-25.1-windows-ime-simple.patch"
ADDITIONAL_CFLAGS='-Ofast -march=native -mtune=native -static'
ADDITIONAL_CONFIGURE_OPTIONS=( --without-imagemagick --without-dbus --with-modules --without-compress-install )
ADDITIONAL_MAKE_OPTIONS=( bootstrap )
SO_BASE_LIST=(
    libgcc_s_seh-1.dll  # GCC(x86_64)
    libgcc_s_dw2-1.dll  # GCC(x86)
    libgnutls-30.dll    # GnuTLS
    libxml2-2.dll       # LIBXML2
    libXpm-noX4.dll     # XPM
    libgif-7.dll        # GIF
    libjpeg-8.dll       # JPEG
    libpng16-16.dll     # PNG
    librsvg-2-2.dll     # SVG
    libtiff-5.dll       # TIFF
)


# overwrite vars load
if [ -e "./build-emacs.options" ]; then
    . "./build-emacs.options"
fi



declare -r EMACS_ARCHIVE_NAME=$( basename "${EMACS_ARCHIVE_URI}" )
declare -r EMACS_ARCHIVE_SIG_URI="${EMACS_ARCHIVE_URI}.sig"
declare -r EMACS_ARCHIVE_SIG_NAME=$( basename "${EMACS_ARCHIVE_SIG_URI}" )
declare -r GNU_KEYRING_URI="http://ftp.gnu.org/gnu/gnu-keyring.gpg"
declare -r GNU_KEYRING_NAME=$( basename "${GNU_KEYRING_URI}" )

if [ "${BUILD_FROM}" = archive ]; then
    declare -r EMACS_VERSION_NAME=$( echo "${EMACS_ARCHIVE_NAME}" | sed -r "s/(emacs-[0-9]+\.[0-9]+).*/\1/" )
    declare -r EMACS_SOURCE_DIR_NAME="${EMACS_VERSION_NAME}"
elif [ "${BUILD_FROM}" = repository ]; then
    declare -r EMACS_VERSION_NAME="${EMACS_CHECKOUT_BRANCH}"
    declare -r EMACS_SOURCE_DIR_NAME="emacs"
else
    echo "--- initialize : unsupported type ${BUILD_FROM}"
    exit 1
fi

declare -r EMACS_PATCH_NAME=$( basename "${EMACS_PATCH_URI}" )

declare -r PARENT_PATH=$( cd $(dirname ${0}) && pwd )
declare -r EMACS_EXPORT_PATH="${PARENT_PATH}/build/${TARGET_PLATFORM}/${EMACS_VERSION_NAME}"


# download from official archive
function download_archive()
{
    echo "--- download_archive : begin ---"

    # download from web
    wget --timestamping "${EMACS_ARCHIVE_URI}"
    wget --timestamping "${EMACS_ARCHIVE_SIG_URI}"
    wget --timestamping "${GNU_KEYRING_URI}"
    wget --timestamping "${EMACS_PATCH_URI}"

    # echo "${EMACS_ARCHIVE_NAME}"
    # echo "${EMACS_ARCHIVE_SIG_NAME}"
    # echo "${GNU_KEYRING_NAME}"
    
    if $( [ -e "${EMACS_ARCHIVE_NAME}" ] && [ -e "${EMACS_ARCHIVE_SIG_NAME}" ] && [ -e "${GNU_KEYRING_NAME}" ] ); then
        local readonly SIGNATURE_INVALID=$( gpg --verify --keyring "./${GNU_KEYRING_NAME}" "${EMACS_ARCHIVE_SIG_NAME}" )

        if [ ${SIGNATURE_INVALID} ]; then
            echo "invalid signature : ${GNU_KEYRING_NAME} : ${EMACS_ARCHIVE_SIG_NAME}"
            exit 1
        fi
    else
        echo "file not found : ${EMACS_ARCHIVE_NAME}, ${EMACS_ARCHIVE_SIG_NAME}, ${GNU_KEYRING_NAME}"
        exit 1
    fi

    # expand archive
    if $( [ -e "${EMACS_ARCHIVE_NAME}" ] && [ ! -d "${EMACS_VERSION_NAME}" ] ); then
        echo "--- download_archive : expand archive ---"
        tar -xvf "${EMACS_ARCHIVE_NAME}"
    fi

    echo "--- download_archive : end ---"
}

    
# download from git repository
function download_repository()
{
    echo "--- download_repository : begin ---"

    # curl --proxy "${http_proxy}"
    if [ ! -d "${EMACS_SOURCE_DIR_NAME}" ]; then
        git clone "${EMACS_GIT_REPOSITORY}"
    fi

    pushd "${EMACS_SOURCE_DIR_NAME}"

    # update & checkout build version
    git stash
    git status --untracked-file=all --ignored
    git clean -fX
    git pull

    if [ -n "${EMACS_CHECKOUT_BRANCH}" ]; then
        git checkout "${EMACS_CHECKOUT_BRANCH}"
    else
        echo "--- download_repository : branch name is empty ${EMACS_CHECKOUT_BRANCH}"
        exit 1
    fi

    # git cmd success or fail
    local readonly RESULT=$?

    if [ ${RESULT} -ne 0 ]; then
        echo "--- download_repository : checkout faild ---"
        exit 1
    fi

    popd

    echo "--- download_repository : end ---"
}


# download
function download()
{
    if [ "${BUILD_FROM}" = archive ]; then
        download_archive
    elif [ "${BUILD_FROM}" = repository ]; then
        download_repository
    else
        echo "--- download : unsupported type ${BUILD_FROM}"
        exit 1
    fi
}


# cleanup ( use necessary old Makefile before ./configure  )
function cleanup()
{
    echo "--- cleanup : begin ---"

    if [ -e "Makefile" ]; then
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

    if [ -e "../${EMACS_PATCH_NAME}" ]; then
        patch -N -b -p0 < "../${EMACS_PATCH_NAME}"
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


function revert_patch()
{
    echo "--- revert_patch : begin ---"

    if [ -e "../${EMACS_PATCH_NAME}" ]; then
        patch -R -b -p0 < "../${EMACS_PATCH_NAME}"
        local readonly RESULT=$?

        if [ ${RESULT} -eq 0 ]; then
            echo "--- revert_patch : applied ---"
        elif [ ${RESULT} -eq 1 ]; then
            echo "--- revert_patch : already applied ---"
        fi
    fi

    echo "--- revert_patch : end ---"
}



# configure generation and execution
function execute_configure()
{
    echo "--- execute_configure : begin ---"

    # 'autogen.sh' generates 'configure' and other files
    ./autogen.sh
    echo "--- execute_configure : generated configure ---"

    # if [ ! -e "configure" ]; then
    #     ./autogen.sh
    #     echo "--- configure : generated ---"
    # else
    #     echo "--- configure : already exist ---"
    # fi

    # 64/32bit
    PKG_CONFIG_PATH="/mingw${TARGET_PLATFORM}/lib/pkgconfig" CFLAGS="${ADDITIONAL_CFLAGS}" ./configure --prefix="${EMACS_EXPORT_PATH}" "${ADDITIONAL_CONFIGURE_OPTIONS[@]}"
    echo "--- execute_configure : generated makefile ---"

    echo "--- execute_configure : end ---"
}


function build()
{
    echo "--- build : begin ---"

    make "${ADDITIONAL_MAKE_OPTIONS[@]}"
    make install

    echo "--- build : end ---"
}


declare -r EMACS_BINARY_EXPORT_PATH="${EMACS_EXPORT_PATH}/bin"
declare -r SO_EXPORT_PATH="${EMACS_BINARY_EXPORT_PATH}"
declare -r SO_IMPORT_PATH="/mingw${TARGET_PLATFORM}/bin"



function search_executable_files()
{
    local readonly  SEARCH_PATH="${1}"
    local readonly  TMP_ARRAY=( $( find "${SEARCH_PATH}" -type f -regex ".*\.exe$" -printf "%f\n" ) )

    echo "${TMP_ARRAY[@]}"
}

function search_dependent_files()
{
    local readonly  SEARCH_PATH="${1}"
    eval local readonly  PARENT_FILES=( '${'"${2}"'[@]}' )
    local TMP_ARRAY=()
    local FILE

    for FILE in "${PARENT_FILES[@]}"; do
        local readonly FILE_PATH="${SEARCH_PATH}/${FILE}"

        if [ -e "${FILE_PATH}" ]; then
            TMP_ARRAY+=( $( ldd "${FILE_PATH}" | grep --text "${SO_IMPORT_PATH}" | sed -r "s/^\s*(\S+) => .*$/\1/") )
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
    local SO

    # printf "%s\n" "${SO_IMPORT_LIST[@]}"
    # echo "number of files : ${#SO_IMPORT_LIST[@]}"

    echo " copy : ${SO_IMPORT_PATH} ==> ${SO_EXPORT_PATH}"
    for SO in "${SO_IMPORT_LIST[@]}"; do
        local readonly SO_PATH="${SO_IMPORT_PATH}/${SO}"

        if [ -e "${SO_PATH}" ]; then
            cp -up "${SO_PATH}" "${SO_EXPORT_PATH}"
            echo "  ${SO}"
        # else
        #     echo "--- install_shared_objects : ${SO_PATH} not found ---"
        fi
    done
    
    echo "--- install_shared_objects : end ---"
}

echo "${EMACS_SOURCE_DIR_NAME}"


download

pushd "${EMACS_SOURCE_DIR_NAME}"

cleanup
apply_patch
execute_configure
build
install_shared_objects
revert_patch

popd


echo "---- ${0} : end ----"

