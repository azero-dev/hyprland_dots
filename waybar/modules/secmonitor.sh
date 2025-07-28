#!/bin/zsh

# percent=$(ddcutil getvcp 10 | awk -F 'current value = |,' '{print $2}')
# echo "${percent}%"

output=$(ddcutil getvcp 10 2>/dev/null)

if [[ $? -ne 0 || -z "$output" ]]; then
  echo " ?"
  exit 1
fi

percent=$(echo "$output" | awk -F 'current value = |,' '{print $2}' | tr -d ' ')

if [[ -z "$percent" ]]; then
  echo " ?"
else
  echo " ${percent}%"
fi
