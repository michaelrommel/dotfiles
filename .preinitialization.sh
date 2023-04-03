#! /bin/bash

export DEBUG=false

echo -n "Initializing"

# Go location
export GOPATH=$(readlink -f ${HOME}/Software)/go

export PATH="${HOME}/bin:${HOME}/.cargo/bin:$(go env GOPATH)/bin:\
${HOME}/.fnm:${HOME}/.local/bin:/usr/local/bin:\
/usr/local/opt/avr-gcc@8/bin:/usr/local/opt/arm-gcc-bin@8/bin:${PATH}"

# pyenv installation on macos
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi

# export LANG="C.UTF-8"
# export LC_CTYPE="C.UTF-8"
# export LC_COLLATE="C.UTF-8"
# export LC_TIME="C.UTF-8"
# export LANG="C.UTF-8"
export LC_CTYPE="C"
export LC_COLLATE="C"
export LC_TIME="C"
export LC_ALL="C"
export EDITOR=vim
export MOSH_ESCAPE_KEY='~'
export GPG_TTY=$(tty)

[[ -x "/usr/bin/uname" ]] && UNAME="/usr/bin/uname"
[[ -x "/bin/uname" ]] && UNAME="/bin/uname"

OSNAME=$( "${UNAME}" -s )
OSRELEASE=$( "${UNAME}" -r )

# load authenticattion tokens
# shellcheck source=./.gh_credentials.sh
[[ -s "${HOME}/.gh_credentials.sh" ]] && \. "${HOME}/.gh_credentials.sh"

# check for mintty to override TERM variable
TERMINAL=$( "${HOME}/bin/terminal.sh" -n )
[[ "${TERMINAL}" == "mintty" ]] && export TERM=mintty
[[ "${TERMINAL}" == "kitty" ]] && export TERM=kitty
[[ "${TERMINAL}" == "linux" ]] && "${HOME}/bin/set_gruvbox_colors.sh"
unset TERMINAL

# adjust gruvbos colors
if [[ "${OSNAME}" == "Darwin" ]]; then
  [[ -s "${HOME}/.vim/plugged/gruvbox/gruvbox_256palette_osx.sh" ]] && \
    \. "${HOME}/.vim/plugged/gruvbox/gruvbox_256palette_osx.sh"
else
  [[ -s "${HOME}/.vim/plugged/gruvbox/gruvbox_256palette.sh" ]] && \
    \. "${HOME}/.vim/plugged/gruvbox/gruvbox_256palette.sh"
fi

# color for less and man
export MANPAGER='less -r -s -M +Gg'
# shellcheck source=./.less_colors.sh
[[ -f "$HOME/.less_colors.sh" ]] && \. "$HOME/.less_colors".sh
# shellcheck source=./.dir_colors.sh
[[ -f "$HOME/.dir_colors.sh" ]] && \. "$HOME/.dir_colors.sh"

echo -n " • fnm"
# shellcheck source=./.fnm.sh
[[ -s "$HOME/.fnm.sh" ]] && \. "$HOME/.fnm.sh"  # This loads fnm

if [ "$(basename "${SHELL}")" = "bash" ]; then
  echo -n " • fzf"
  [[ ${DEBUG} == true ]] && echo -n " (bash)"
  # shellcheck source=./.fzf.bash
  [ -f ~/.fzf.bash ] && source ~/.fzf.bash
fi

echo -n " • mosh"
FATHER=$(ps -p $PPID -o comm=)
if [ "${FATHER}" = "mosh-server" ]; then
  echo -n " (true)"
  unset SSH_AUTH_SOCK
  unset SSH_CLIENT
  unset SSH_CONNECTION
  # leave TTY set, powerlevel10k uses it to determine context
  #unset SSH_TTY
  unset FATHER
fi

echo -n " • ssh-agent"
[[ ${DEBUG} == true ]] && echo -e -n "\nChecking for ssh keys"
ssh-add -l >/dev/null 2>&1
RC=$?
if [[ $RC == 1 || $RC == 2 ]]; then
  # there are no keys available or no agent running
  [[ ${DEBUG} == true ]] && echo " (none)"
  if [ "$(basename "${SHELL}")" = "zsh" ]; then
    # suppress error messages, when a glob pattern returns no matches
    setopt +o nomatch
  fi
  if [[ "${OSNAME}" == "Darwin" ]]; then
    # on macOS: keychain has support to get the passphrase from the OS Keyring
    # before you can use the keychain, you must add it once to it
    # ssh-add --apple-use-keychain ~/.ssh/id_ecdsa
    ssh-add -q --apple-load-keychain ~/.ssh/id_ecdsa
    eval "$( keychain --eval --agents ssh --inherit any-once id_ecdsa )"
  elif [[ "${OSNAME}" == "Linux" ]]; then
    if [[ "${OSRELEASE}" =~ "-microsoft-" ]]; then
      # we are on WSL2
      # There is obviously no AUTH_SOCK available. Now keychain has its own
      # way of remembering an previously started agent in its .keychain
      # directory. It will therefore only start a wsl-relay once per
      # session.
      # Unfortunately keychain does not understand that the Windows OpenSSH
      # Agent already provides the identities and always thinks, if it started
      # the agent, it should ask to add keys, so we have to branch here and 
      # not ask for identies to add.
      # Agent needs to be named "ssh-agent" because keychain refuses
      # to start anything other than ssh-agent and gpg-agent. :-(
      [[ ${DEBUG} == true ]] && echo "Launching ssh-agent relay"
      unset IDENTITIES
    else
      # per default add identities on other Linux systems
      declare -a IDENTITIES=(id_ed25519 id_ecdsa id_rsa)
    fi
    # inherit identities or start new ssh-agent
    [[ ${DEBUG} == false ]] && FLAG="--quiet"
    # shellcheck disable=SC2068
    eval "$( keychain ${FLAG} --eval --ignore-missing \
        --agents ssh --inherit any-once ${IDENTITIES[@]} )"
  else
    echo "Unknown Operating System: ${OSNAME}"
  fi
else
  [[ ${DEBUG} == true ]] && echo " (found)"
fi

umask 022
set -o vi

# reset initialization lines (formatting and clear line, cursor to 1st col
echo -n -e '\e[1G\e[2K\e[0m'

# show MOTD once per day
if [[ "${OSNAME}" == "Darwin" ]]; then
  LEAVEDATE=$(date -j -f "%Y-%m-%d %H:%M:%S" "2026-10-01 00:00:00" +%s)
  BEGINOFDAY=$(date -j -v0H -v0M -v0S +%s)
  NOW=$(date -j +%s)
else
  LEAVEDATE=$(date -d "2026-10-01" +"%s")
  BEGINOFDAYSTRING=$(date +"%Y-%m-%d 00:00:00")
  BEGINOFDAY=$(date -d ${BEGINOFDAYSTRING} +"%s")
  NOW=$(date +"%s")
fi
[[ -f ${HOME}/.motd_shown ]] && MOTDSHOWN=$(<${HOME}/.motd_shown)
MOTDSHOWN=${MOTDSHOWN:-0}
DIFF=$((NOW - MOTDSHOWN))
if [[ ${DIFF} -gt 86400 ]]; then
  # calculat
  echo ${BEGINOFDAY} >${HOME}/.motd_shown
  # Count down the days of working for others
  WEEKSLEFT=$(( (LEAVEDATE - NOW) / (7*24*3600) ))
  echo -e "Weeks to work: \e[94m${WEEKSLEFT}\e[0m"
fi

