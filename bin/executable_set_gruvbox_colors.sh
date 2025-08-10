#! /usr/bin/env bash
# shellcheck disable=2034

#set -o xtrace

# declare explicit arrays with name and position in the colour table
a00=(234 "dark0_hard" "1D/20/21")
a01=(235 "dark0" "28/28/28")
a02=(236 "dark0_soft" "32/30/2F")
a03=(237 "dark1" "3c/38/36")
a04=(239 "dark2" "50/49/45")
a05=(241 "dark3" "66/5c/54")
a06=(243 "dark4" "7C/6F/64")

a07=(244 "gray" "92/83/74")
a08=(245 "gray" "92/83/74")

a09=(167 "light0_hard" "FB/49/34")
a10=(229 "light0" "FB/F1/C7")
a11=(228 "light0_soft" "F2/E5/BC")
a12=(223 "light1" "EB/DB/B2")
a13=(250 "light2" "D5/C4/A1")
a14=(248 "light3" "BD/AE/93")
a15=(246 "light4" "A8/99/84")

a16=(167 "bright_red" "FB/49/34")
a17=(142 "bright_green" "B8/BB/26")
a18=(214 "bright_yellow" "FA/BD/2F")
a19=(109 "bright_blue" "83/A5/98")
a20=(175 "bright_purple" "D3/86/9B")
a21=(108 "bright_aqua" "8E/C0/7C")
a22=(208 "bright_orange" "FE/80/19")

# these have no assigned cube position, as they are used
# as base colors, I think
a23=(0 "neutral_red" "CC/24/1D")
a24=(0 "neutral_green" "98/97/1A")
a25=(0 "neutral_yellow" "D7/99/21")
a26=(0 "neutral_blue" "45/85/88")
a27=(0 "neutral_purple" "B1/62/86")
a28=(0 "neutral_aqua" "68/9D/6A")
a29=(0 "neutral_orange" "D6/5D/0E")

a30=(88 "faded_red" "9D/00/06")
a31=(100 "faded_green" "79/74/0E")
a32=(136 "faded_yellow" "B5/76/14")
a33=(24 "faded_blue" "07/66/78")
a34=(96 "faded_purple" "8F/3F/71")
a35=(66 "faded_aqua" "42/7B/58")
a36=(130 "faded_orange" "AF/3A/03")

# declare global iteration array
colours256=(a00 a01 a02 a03 a04 a05 a06 a07 a08 a09
	a10 a11 a12 a13 a14 a15 a16 a17 a18 a19
	a20 a21 a22
	a30 a31 a32 a33 a34 a35 a36)

# for the linux console there are special escape codes
colours16=(a00 a23 a24 a25 a26 a27 a28 a12 a07 a16 a17 a18 a19 a20 a21 a09)
index16=(0 1 2 3 4 5 6 7 8 9 A B C D E F)

# this gets assigned the name of an array as nameref
declare -n colour

if [ "$TERM" != "linux" ]; then
	for colour in "${colours256[@]}"; do
		#echo "Position is: ${colour[0]}, name is: ${colour[1]}, colour is: ${colour[2]}"
		if [ "${TERM%%-*}" = "screen" ]; then
			if [ -n "$TMUX" ]; then
				printf "\033Ptmux;\033\033]4;%s;rgb:%s\007\033\\" "${colour[0]}" "${colour[2]}"
			else
				printf "\033P\033]4;%s;rgb:%s\007\033\\" "${colour[0]}" "${colour[2]}"
			fi
		elif [ "$TERM" != "linux" ] && [ "$TERM" != "vt100" ] && [ "$TERM" != "vt220" ]; then
			printf "\033]4;%s;rgb:%s\033\\" "${colour[0]}" "${colour[2]}"
		fi
	done
else
	i=0
	for colour in "${colours16[@]}"; do
		# echo "Position is: ${index16[$i]}, name is: ${colour[1]}, colour is: ${colour[2]}"
		# note: removal of the / separators
		echo -en "\e]P${index16[$i]}${colour[2]//\//}"
		i=$((++i))
	done
	clear # for background artifact removal
fi
