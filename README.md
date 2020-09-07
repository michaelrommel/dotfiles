# dotfiles
My personal dot files with a script to be used on fresh installs to get 
a sane starting point.

Since there are most probably some specific configurations per company
I am working with, that cannot be shared here, there are two additional
files, that get sourced, if they exist:
- `~/.company_aliases`
- `~/.ssh/company_config`

Easiest installation:
- `cd "${HOME}"; git clone https://github.com/michaelrommel/dotfiles .dotfiles`
- `bash "${HOME}/.dotfiles/bin/install_dotfiles.sh"`

Example that shows how my typical environment looks like:
- `tmux -c "cd ${HOME}/.dotfiles/software/node-example/;
   [[ ! -d "./node_modules" ]] && npm install; nvim HappyBirthday.js"`

