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
# shellcheck source=./.less_colors
[[ -f "$HOME/.less_colors" ]] && \. "$HOME/.less_colors"

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
[[ ${DEBUG} == true ]] && echo -n "\nChecking for ssh keys"
ssh-add -l >/dev/null 2>&1
RC=$?
if [[ $RC == 1 || $RC == 2 ]]; then
  # there are no keys available or no agent running
  [[ ${DEBUG} == true ]] && echo " (none)"

  OSNAME=$( "${UNAME}" -s )
  OSRELEASE=$( "${UNAME}" -r )

  if [[ "${OSNAME}" == "Darwin" ]]; then
    # on macOS: keychain has support to get the passphrase from the OS Keyring
    ssh-add -AK ~/.ssh/id_ecdsa
    eval "$( keychain --eval --agents ssh --inherit any id_ecdsa )"
  elif [[ "${OSNAME}" == "Linux" ]]; then
    # first try to find an existing authentication socket
    # shellcheck disable=SC2207
    AGENTS=( $( /usr/bin/find /tmp/ssh-*/ -name "agent.*" \
      -user "${USER}" 2>/dev/null |tr 2>/dev/null "\n" " " ) )
    FOUND=0
    for AGENT in "${AGENTS[@]}"; do
      if [ $FOUND -eq 0 ]; then
        # shellcheck disable=SC2012
        OWNER=$(ls -l "$AGENT" |awk '{print $3}')
        if [[ "$OWNER" == "$USER" ]]; then
          [[ ${DEBUG} == true ]] && echo "Trying agent $AGENT"
          export SSH_AUTH_SOCK=$AGENT
          if ! ss -a | grep -q "$SSH_AUTH_SOCK"; then
            # stale agent socket
            [[ ${DEBUG} == true ]] && echo "Removing stale agent $AGENT"
            rm -f "${AGENT}" "${AGENT}.log"
            unset SSH_AUTH_SOCK
          else
            FOUND=1
          fi
        fi
      fi
    done
    if [ -z "$SSH_AUTH_SOCK" ]; then
      if [[ "${OSRELEASE}" =~ "-microsoft-" ]]; then
        # on WSL2
        # we need a new npiperelay
        [[ ${DEBUG} == true ]] && echo "Launching ssh-agent relay"
        export SSH_AUTH_SOCK=/tmp/ssh-$$/agent.$$
        rm -f $SSH_AUTH_SOCK
        ( setsid socat UNIX-LISTEN:$SSH_AUTH_SOCK,umask=007,fork \
                       EXEC:"/mnt/d/ProgramFiles/npiperelay/npiperelay.exe -ei -s \
                       -v //./pipe/openssh-ssh-agent",nofork &
        ) >${SSH_AUTH_SOCK}.log 2>&1
      else
        # default on other Linux systems
        # inherit identities or start new ssh-agent
        eval "$( keychain --eval --agents ssh --inherit any id_ed25519 id_ecdsa id_rsa)"
      fi
    fi
  else
    echo "Unknown Operating System: ${OSNAME}"
  fi
else
  [[ ${DEBUG} == true ]] && echo " (found)"
fi

umask 022
set -o vi

# global aliases
echo -n " •  aliases"
alias sha="shasum -a 256"
alias icat="kitty +kitten icat"

# load company / work specific aliases
# shellcheck source=./.company_aliases.sh
[[ -s "${HOME}/.company_aliases.sh" ]] && \. "${HOME}/.company_aliases.sh"

# reset initialization lines (formatting and clear line, cursor to 1st col
echo -n -e '\e[1G\e[2K\e[0m'

