# -*- mode: shell-script ; coding: utf-8-unix -*-
#! /bin/sh


# overwrite vars load
declare -r START_OPTIONS_FILE="start.options"

if [ -e "./${START_OPTIONS_FILE}" ]; then
    . "./${START_OPTIONS_FILE}"
fi

declare -r START_DATE=$( date +%Y-%m%d-%H%M )

./setup-msys2.sh 2>&1 | tee setup-msys2_${START_DATE}.log

./build-emacs.sh 2>&1 | tee build-emacs_${START_DATE}.log
