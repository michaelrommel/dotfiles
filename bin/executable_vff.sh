#! /bin/bash

FZF=$(command -v fzf 2>/dev/null)
if [[ $? -gt 0 || ! -x "${FZF}" ]]; then
  echo "fzf missing or no executable";
  exit 2;
fi

BAT=$(command -v bat 2>/dev/null)
if [[ $? -gt 0 || ! -x "${BAT}" ]]; then
  echo "bat missing or no executable";
  exit 2;
fi

FILE=$(${FZF} --preview 'bat --style=numbers --color=always --line-range :500 {}')
if [[ $? -gt 0 ]]; then
  echo "no file selected";
  exit 1;
fi

vim "${FILE}"
