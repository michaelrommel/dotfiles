#! /bin/bash

export DEBUG=true

# save the original ssh authentication socket
SAVE_SOCK="${SSH_AUTH_SOCK}"

# first try to find an existing authentication socket
# shellcheck disable=SC2207
AGENTS=( $( /usr/bin/find /tmp/ssh-*/ -name "agent.*" \
  -user "${USER}" 2>/dev/null |tr 2>/dev/null "\n" " " ) )

for AGENT in "${AGENTS[@]}"; do
  [[ ${DEBUG} == true ]] && echo "Checking agent $AGENT"
  export SSH_AUTH_SOCK=$AGENT
  if ! ss -a | grep -q "$SSH_AUTH_SOCK"; then
    # stale agent socket
    [[ ${DEBUG} == true ]] && echo "Removing stale agent $AGENT"
    rm 2>/dev/null -f "${AGENT}" "${AGENT}.log"
    unset SSH_AUTH_SOCK
  fi
done

export SSH_AUTH_SOCK="${SAVE_SOCK}"
