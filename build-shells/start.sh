# -*- mode: shell-script ; coding: utf-8-unix -*-
#! /bin/sh


# export http_proxy=""
# export https_proxy=""
# export http_proxy=""
# export https_proxy=""
# export no_proxy="localhost,127.0.0.1"

./setup-msys2.sh > setup-msys2.log 2>&1
cat ./setup-msys2.log

./build-emacs.sh > build-emacs.log 2>&1
cat ./build-emacs.log
