#! /bin/bash

if [[ ! "$PATH" == *${HOME}/.fnm* ]]; then
    export PATH="${PATH:+${PATH}:}${HOME}/.fnm"
fi
eval "`fnm env --multi`"
