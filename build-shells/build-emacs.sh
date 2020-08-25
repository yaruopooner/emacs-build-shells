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


echo -e "\n---- ${0} : begin ----\n"


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
EMACS_CHECKOUT_TAG=""
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
declare -r BUILD_EMACS_OPTIONS_FILE="build-emacs.options"

if [ -e "./${BUILD_EMACS_OPTIONS_FILE}" ]; then
    . "./${BUILD_EMACS_OPTIONS_FILE}"
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
    declare -r EMACS_VERSION_NAME=$( [ -n "${EMACS_CHECKOUT_TAG}" ] && echo "${EMACS_CHECKOUT_TAG}" || echo "${EMACS_CHECKOUT_BRANCH}" )
    declare -r EMACS_SOURCE_DIR_NAME="emacs"
else
    echo -e "\n--- initialize : unsupported type ${BUILD_FROM}"
    exit 1
fi

declare -r EMACS_PATCH_NAME=$( basename "${EMACS_PATCH_URI}" )

declare -r PARENT_PATH=$( cd $(dirname ${0}) && pwd )
declare -r EMACS_EXPORT_PATH="${PARENT_PATH}/build/${TARGET_PLATFORM}/${EMACS_VERSION_NAME}"


# download from official archive
function download_archive()
{
    echo -e "\n--- download_archive : begin ---\n"

    # download from web
    wget --timestamping "${EMACS_ARCHIVE_URI}"
    wget --timestamping "${EMACS_ARCHIVE_SIG_URI}"
    wget --timestamping "${GNU_KEYRING_URI}"

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
        echo -e "\n--- download_archive : expand archive ---\n"
        tar -xvf "${EMACS_ARCHIVE_NAME}"
    fi

    echo -e "\n--- download_archive : end ---\n"
}

    
# download from git repository
function download_repository()
{
    echo -e "\n--- download_repository : begin ---\n"

    # curl --proxy "${http_proxy}"
    if [ ! -d "${EMACS_SOURCE_DIR_NAME}" ]; then
        local CMD_ARGS=("clone" "${EMACS_GIT_REPOSITORY}")

        echo "====clone detail===="
        echo "repository   : ${EMACS_SOURCE_DIR_NAME}"
        echo "url          : ${EMACS_GIT_REPOSITORY}"
        echo "command      : git ${CMD_ARGS[@]}"

        git ${CMD_ARGS[@]}
    else
        pushd "${EMACS_SOURCE_DIR_NAME}"

        echo "====fetch===="

        git fetch
        git fetch --tags

        popd
    fi

    pushd "${EMACS_SOURCE_DIR_NAME}"

    # update & checkout build version
    git stash
    git status --untracked-file=all --ignored
    git clean -fX

    local BRANCH_NAME=""
    local START_POINT=""

    if [ -n "${EMACS_CHECKOUT_TAG}" ]; then
        # tag
        BRANCH_NAME=${EMACS_CHECKOUT_TAG}
        START_POINT="refs/tags/${EMACS_CHECKOUT_TAG}"
    elif [ -n "${EMACS_CHECKOUT_BRANCH}" ]; then
        # branch
        BRANCH_NAME=${EMACS_CHECKOUT_BRANCH}
        START_POINT="origin/${EMACS_CHECKOUT_BRANCH}"
    fi

    # check input
    if [ -z "${BRANCH_NAME}" ]; then
        echo -e "\n--- download_repository : tag name is empty : ${EMACS_CHECKOUT_TAG} or branch name is empty : ${EMACS_CHECKOUT_BRANCH}"
        exit 1
    fi

    # branch checkout
    local CMD_ARGS=("checkout" "--force" "-B" "${BRANCH_NAME}" "${START_POINT}")

    echo "====checkout tag or branch===="
    echo "start-point  : ${START_POINT}"
    echo "command      : git ${CMD_ARGS[@]}"

    git ${CMD_ARGS[@]}

    # git cmd success or fail
    local readonly RESULT=$?

    if [ ${RESULT} -ne 0 ]; then
        echo -e "\n--- download_repository : checkout faild ---\n"
        exit 1
    fi

    popd

    echo -e "\n--- download_repository : end ---\n"
}


# download patch
function download_patch()
{
    echo -e "\n--- download_patch : begin ---\n"

    # download from web
    wget --timestamping "${EMACS_PATCH_URI}"

    echo -e "\n--- download_patch : end ---\n"
}


# download
function download()
{
    if [ "${BUILD_FROM}" = archive ]; then
        download_archive
    elif [ "${BUILD_FROM}" = repository ]; then
        download_repository
    else
        echo -e "\n--- download : unsupported type ${BUILD_FROM}"
        exit 1
    fi

    download_patch
}


# cleanup ( use necessary old Makefile before ./configure  )
function cleanup()
{
    echo -e "\n--- cleanup : begin ---\n"

    if [ -e "Makefile" ]; then
        make clean
        make bootstrap-clean
        # make uninstall
    fi

    if [ -d "${EMACS_EXPORT_PATH}" ]; then
        rm -rf "${EMACS_EXPORT_PATH}"
    fi

    echo -e "\n--- cleanup : end ---\n"
}


# patch
function apply_patch()
{
    echo -e "\n--- apply_patch : begin ---\n"

    if [ -e "../${EMACS_PATCH_NAME}" ]; then
        patch -N -b -p0 < "../${EMACS_PATCH_NAME}"
        local readonly RESULT=$?

        if [ ${RESULT} -eq 0 ]; then
            echo -e "\n--- apply_patch : applied ---\n"
            autoconf
        elif [ ${RESULT} -eq 1 ]; then
            echo -e "\n--- apply_patch : already applied ---\n"
        fi
    fi

    echo -e "\n--- apply_patch : end ---\n"
}


function revert_patch()
{
    echo -e "\n--- revert_patch : begin ---\n"

    if [ -e "../${EMACS_PATCH_NAME}" ]; then
        patch -R -b -p0 < "../${EMACS_PATCH_NAME}"
        local readonly RESULT=$?

        if [ ${RESULT} -eq 0 ]; then
            echo -e "\n--- revert_patch : applied ---\n"
        elif [ ${RESULT} -eq 1 ]; then
            echo -e "\n--- revert_patch : already applied ---\n"
        fi
    fi

    echo -e "\n--- revert_patch : end ---\n"
}



# configure generation and execution
function execute_configure()
{
    echo -e "\n--- execute_configure : begin ---\n"

    # 'autogen.sh' generates 'configure' and other files
    ./autogen.sh
    echo -e "\n--- execute_configure : generated configure ---\n"

    # if [ ! -e "configure" ]; then
    #     ./autogen.sh
    #     echo -e "\n--- configure : generated ---\n"
    # else
    #     echo -e "\n--- configure : already exist ---\n"
    # fi

    # 64/32bit
    PKG_CONFIG_PATH="/mingw${TARGET_PLATFORM}/lib/pkgconfig" CFLAGS="${ADDITIONAL_CFLAGS}" ./configure --prefix="${EMACS_EXPORT_PATH}" "${ADDITIONAL_CONFIGURE_OPTIONS[@]}"
    echo -e "\n--- execute_configure : generated makefile ---\n"

    echo -e "\n--- execute_configure : end ---\n"
}


function build()
{
    echo -e "\n--- build : begin ---\n"

    make "${ADDITIONAL_MAKE_OPTIONS[@]}"
    make install

    echo -e "\n--- build : end ---\n"
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
    echo -e "\n--- install_shared_objects : begin ---\n"


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
        #     echo -e "\n--- install_shared_objects : ${SO_PATH} not found ---\n"
        fi
    done
    
    echo -e "\n--- install_shared_objects : end ---\n"
}


function archive()
{
    echo -e "\n--- archive : begin ---\n"

    local readonly ARCHIVE_DATE=$( date +%Y-%m%d-%H%M )
    local readonly ARCHIVE_FILE_PATH="${EMACS_EXPORT_PATH}/../${EMACS_VERSION_NAME}-${ARCHIVE_DATE}.tar.gz"

    set -x
    tar --directory "${EMACS_EXPORT_PATH}/.." -zcf "${ARCHIVE_FILE_PATH}" "./${EMACS_VERSION_NAME}"
    set +x

    echo -e "\n--- archive : end ---\n"
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

archive

echo -e "\n---- ${0} : end ----\n"

