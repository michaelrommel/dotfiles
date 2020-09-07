#! /bin/bash

export DEBUG=false

echo -n "Initializing:"

export PATH="${HOME}/bin":/usr/local/bin:$PATH
export LANG="C.UTF-8"
export LC_CTYPE="C.UTF-8"
export LC_COLLATE="C.UTF-8"
export LC_TIME="C.UTF-8"
export EDITOR=vim
export MOSH_ESCAPE_KEY='~'

[[ -x "/usr/bin/uname" ]] && UNAME="/usr/bin/uname"
[[ -x "/bin/uname" ]] && UNAME="/bin/uname"

# load authenticattion tokens
# shellcheck source=./.gh_credentials.sh
[[ -s "${HOME}/.gh_credentials.sh" ]] && \. "${HOME}/.gh_credentials.sh"

# check for mintty to override TERM variable
TERMINAL=$( "${HOME}/bin/terminal.sh" -n )
[[ "${TERMINAL}" == "mintty" ]] && export TERM=mintty
unset TERMINAL

# color for less and man
export MANPAGER='less -r -s -M +Gg'
# shellcheck source=./.less_colors.sh
[[ -f "$HOME/.less_colors.sh" ]] && \. "$HOME/.less_colors".sh
# shellcheck source=./.dir_colors.sh
[[ -f "$HOME/.dir_colors.sh" ]] && \. "$HOME/.dir_colors.sh"

echo -n " • nvm"
export NVM_DIR="$HOME/.nvm"
# shellcheck source=./.nvm/nvm.sh
[[ -s "$NVM_DIR/nvm.sh" ]] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
# shellcheck source=./.nvm/bash_completion
[[ -s "$NVM_DIR/bash_completion" ]] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

echo -n " • fzf"
if [ "$(basename "${SHELL}")" = "zsh" ]; then
  [[ ${DEBUG} == true ]] && echo -n " (zsh)"
  # suppress error messages, when a glob pattern returns no matches
  setopt +o nomatch
  # shellcheck source=/dev/null
  [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
else
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
  unset SSH_TTY
  unset FATHER
fi

echo -n " • ssh-agent"
[[ ${DEBUG} == true ]] && echo -e -n "\nChecking for ssh keys"
ssh-add -l >/dev/null 2>&1
RC=$?
if [[ $RC == 1 || $RC == 2 ]]; then
  # there are no keys available or no agent running
  [[ ${DEBUG} == true ]] && echo " (none)"
  OSNAME=$( "${UNAME}" -s )
  if [[ "${OSNAME}" == "Darwin" ]]; then
    # on macOS: keychain has support to get the passphrase from the OS Keyring
    ssh-add -AK ~/.ssh/id_ecdsa
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

# global aliases
echo -n " • aliases"
alias sha="shasum -a 256"
alias icat="kitty +kitten icat"

# load company / work specific aliases
# shellcheck source=./.company_aliases.sh
[[ -s "${HOME}/.company_aliases.sh" ]] && \. "${HOME}/.company_aliases.sh"

# reset initialization lines (formatting and clear line, cursor to 1st col
echo -n -e '\e[1G\e[2K\e[0m'

