# -*- mode: shell-script ; coding: utf-8-unix -*-
#! /bin/sh


# overwrite vars load
if [ -e "./start.options" ]; then
    . "./start.options"
fi

declare -r START_DATE=$( date +%Y-%m%d-%H%M )

./setup-msys2.sh > setup-msys2_${START_DATE}.log 2>&1
cat ./setup-msys2_${START_DATE}.log

./build-emacs.sh > build-emacs_${START_DATE}.log 2>&1
cat ./build-emacs_${START_DATE}.log
