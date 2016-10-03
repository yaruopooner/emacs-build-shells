# -*- mode: shell-script ; coding: utf-8-unix -*-
#! /bin/sh


# export http_proxy=""
# export https_proxy=""
# export http_proxy=""
# export https_proxy=""
# export no_proxy="localhost,127.0.0.1"

# readonly BUILD_PLATFORM="--x32"

./setup-msys2.sh "${BUILD_PLATFORM}" > setup-msys2.log 2>&1
cat ./setup-msys2.log

./build-emacs.sh "${BUILD_PLATFORM}" > build-emacs.log 2>&1
cat ./build-emacs.log
