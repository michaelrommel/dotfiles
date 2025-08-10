#! /bin/bash

nvim_paste.sh |tmux load-buffer - && tmux paste-buffer
