#! /bin/bash

export DEBUG=false

echo -n "Initializing"

export PATH="${HOME}/bin:${HOME}/go/bin:$HOME/.cargo/bin:$PATH:\
  $HOME/.local/bin:$PATH:/usr/local/bin:\
  /usr/local/opt/avr-gcc@8/bin:/usr/local/opt/arm-gcc-bin@8/bin:${PATH}"

# pyenv installation on macos
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi

export LANG="C.UTF-8"
export LC_CTYPE="C.UTF-8"
export LC_COLLATE="C.UTF-8"
export LC_TIME="C.UTF-8"
export EDITOR=vim
export MOSH_ESCAPE_KEY='~'
export GPG_TTY=$(tty)

[[ -x "/usr/bin/uname" ]] && UNAME="/usr/bin/uname"
[[ -x "/bin/uname" ]] && UNAME="/bin/uname"

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
  OSNAME=$( "${UNAME}" -s )
  OSRELEASE=$( "${UNAME}" -r )
  if [[ "${OSNAME}" == "Darwin" ]]; then
    # on macOS: keychain has support to get the passphrase from the OS Keyring
    ssh-add -q --apple-use-keychain --apple-load-keychain ~/.ssh/id_ecdsa
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

# global aliases and functions
echo -n " • aliases"
alias sha="shasum -a 256"
alias icat="kitty +kitten icat"
alias ff="fzf --preview 'bat --style=numbers --color=always --line-range :500 {}'"
alias lr='ls -lahtr'
# shellcheck disable=SC2139
alias vff="${HOME}/bin/vff.sh"
# shellcheck disable=SC2139
alias bgr="${HOME}/.bat/src/batgrep.sh"
alias gll='git log --graph --pretty=oneline --abbrev-commit'

logtail () {
  tail -f "$@" | bat --paging=never -l log
}

dnotify () {
  local title=$1
  shift 1
  local body=$@
  if [[ -z "${TMUX}" ]]; then
    printf "\x1b]99;i=1:d=0;${title}\x1b\\";printf "\x1b]99;i=1:d=1:p=body;${body}\x1b\\"
  else
    printf "\x1bPtmux;\x1b\x1b]99;i=1:d=0;${title}\x1b\x1b\\";printf "\x1b\x1b]99;i=1:d=1:p=body;${body}\x1b\x1b\\"
  fi
}

# load company / work specific aliases
# shellcheck source=./.company_aliases.sh
[[ -s "${HOME}/.company_aliases.sh" ]] && \. "${HOME}/.company_aliases.sh"

# reset initialization lines (formatting and clear line, cursor to 1st col
echo -n -e '\e[1G\e[2K\e[0m'
