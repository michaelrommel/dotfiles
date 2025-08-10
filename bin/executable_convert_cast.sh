#! /bin/bash

INPUT="$1"

if [[ -z "${INPUT}" ]]; then
	echo "Usage: $0 <filename.cast>"
	exit 1
fi

BASE=$(basename "${INPUT}" ".cast")
DIR=$(dirname "${INPUT}")

agg \
	--font-size 28 \
	--font-family "VictorMono NF" \
	--speed 1 \
	--idle-time-limit 0.5 \
	--theme 1d2021,fbf1c7,282828,cc241d,98971a,d79921,458588,b16286,689d6a,a89984,928374,fb4934,b8bb26,fabd2f,83a598,d3869b,8ec07c,ebdbb2 \
	--renderer resvg \
	"${INPUT}" \
	"${DIR}/${BASE}.gif"
