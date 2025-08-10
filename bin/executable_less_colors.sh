export LESS_TERMCAP_mb=$(
	tput bold
	tput setaf 5
) # blinking = pink
export LESS_TERMCAP_md=$(
	tput bold
	tput setaf 10
) # green
export LESS_TERMCAP_me=$(
	tput sgr0
) # end mode
export LESS_TERMCAP_so=$(
	tput bold
	tput setaf 0
	tput setab 15
) # standout mode = black on white
export LESS_TERMCAP_se=$(
	tput rmso
	tput sgr0
) # end standout mode
export LESS_TERMCAP_us=$(
	tput smul
	tput setaf 12
) # underline mode = blue
export LESS_TERMCAP_ue=$(
	tput rmul
	tput sgr0
) # end underline mode
export LESS_TERMCAP_mr=$(tput rev)
export LESS_TERMCAP_mh=$(tput dim)
export LESS_TERMCAP_ZN=$(tput ssubm)
export LESS_TERMCAP_ZV=$(tput rsubm)
export LESS_TERMCAP_ZO=$(tput ssupm)
export LESS_TERMCAP_ZW=$(tput rsupm)
export GROFF_NO_SGR=1
