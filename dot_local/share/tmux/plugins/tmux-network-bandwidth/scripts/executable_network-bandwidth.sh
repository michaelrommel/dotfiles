#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_DIR/helpers.sh"

if gawk -V 1>/dev/null; then
	AWK='gawk'
else
	AWK='awk'
fi

get_bandwidth_for_osx() {
	# shellcheck disable=2016
    netstat -ibn | ${AWK} 'FNR > 1 {
    interfaces[$1 ":bytesReceived"] = $(NF-4);
    interfaces[$1 ":bytesSent"]     = $(NF-1);
  } END {
    for (itemKey in interfaces) {
      split(itemKey, keys, ":");
      interface = keys[1]
      dataKind = keys[2]
      sum[dataKind] += interfaces[itemKey]
    }

    print sum["bytesReceived"], sum["bytesSent"]
  }'
}

get_bandwidth_for_linux() {
	# shellcheck disable=2016
    netstat -ie | ${AWK} '
    match($0, /RX([[:space:]]packets[[:space:]][[:digit:]]+)?[[:space:]]+bytes[:[:space:]]([[:digit:]]+)/, rx) { rx_sum+=rx[2]; }
    match($0, /TX([[:space:]]packets[[:space:]][[:digit:]]+)?[[:space:]]+bytes[:[:space:]]([[:digit:]]+)/, tx) { tx_sum+=tx[2]; }
    END { print rx_sum, tx_sum }
  '
}

get_bandwidth() {
  local os="$1"

  case $os in
    osx)
      echo -n "$(get_bandwidth_for_osx)"
      return 0
      ;;
    linux)
      echo -n "$(get_bandwidth_for_linux)"
      return 0
      ;;
    *)
      echo -n "0 0"
      return 1
      ;;
  esac
}

format_speed() {
  local padding
  padding=$(get_tmux_option "@tmux-network-bandwidth-padding" 5)
  numfmt --to=iec --suffix "b/s" --format "%f" --padding "$padding" "$1"
}

main() {
  local sleep_time
  sleep_time=$(get_tmux_option "status-interval")
  local old_value
  old_value=$(get_tmux_option "@tmux-network-bandwidth-value")
 
  if [ -z "$old_value" ] || [ "$old_value" == "-" ]; then
	eval "$(set_tmux_option "@tmux-network-bandwidth-value" "+")"
    echo -n "Please wait..."
    return 0
  else
    local os
    os=$(os_type)
    IFS=" " read -r -a first_measure < <(get_bandwidth "$os")
    sleep "$sleep_time"
    read -r -a second_measure < <(get_bandwidth "$os")
    local download_speed=$(( (second_measure[0] - first_measure[0]) * 8/ sleep_time))
    local upload_speed=$(( (second_measure[1] - first_measure[1]) * 8 / sleep_time))
	local form_dwn
	form_dwn=$(format_speed $download_speed)
	local form_up
	form_up=$(format_speed $upload_speed)
	# eval "$(set_tmux_option "@tmux-network-bandwidth-value" "+")"
  fi

  # echo -n "$(get_tmux_option "@network-bandwidth-previous-value")"
  echo -n  "↓$form_dwn • ↑$form_up"
}

main
