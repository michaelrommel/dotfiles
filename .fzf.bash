#! /bin/bash

# Setup fzf
# ---------
if [[ ! "$PATH" == *${HOME}/.fzf/bin* ]]; then
  export PATH="${PATH:+${PATH}:}${HOME}/.fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && [[ -d "${HOME}/.fzf/" ]] && source "${HOME}/.fzf/shell/completion.bash" 2> /dev/null

# Key bindings
# ------------
[[ -d "${HOME}/.fzf/" ]] && source "${HOME}/.fzf/shell/key-bindings.bash"

if [[ -x "/usr/bin/fd" ]]; then
  export FZF_DEFAULT_COMMAND='fd --type file'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi
