#! /bin/bash

[[ -x "/usr/bin/uname" ]] && UNAME="/usr/bin/uname"
[[ -x "/bin/uname" ]] && UNAME="/bin/uname"

OSNAME=$( "${UNAME}" -s )

# on macos, brew installed it already in /usr/local/bin
if [[ "${OSNAME}" != "Darwin" ]]; then
  if [[ ! "$PATH" == *${HOME}/.local/share/fnm* ]]; then
    export PATH="${PATH:+${PATH}:}${HOME}/.local/share/fnm"
  fi
fi

eval "$(fnm env)"
