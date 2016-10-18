# -*- mode: shell-script ; coding: utf-8-unix -*-
#! /bin/sh


# overwrite vars load
if [ -e "./start.options" ]; then
    . "./start.options"
fi


./setup-msys2.sh > setup-msys2.log 2>&1
cat ./setup-msys2.log

./build-emacs.sh > build-emacs.log 2>&1
cat ./build-emacs.log
