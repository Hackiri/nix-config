#!/bin/bash

# Get battery information
PERCENTAGE=$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)
CHARGING=$(pmset -g batt | grep 'AC Power')

# Set the appropriate icon based on battery level and charging status
if [ "$CHARGING" != "" ]; then
  ICON="󰂄"
else
  case ${PERCENTAGE} in
    100) ICON="󰁹";;
    9[0-9]) ICON="󰂂";;
    8[0-9]) ICON="󰂁";;
    7[0-9]) ICON="󰂀";;
    6[0-9]) ICON="󰁿";;
    5[0-9]) ICON="󰁾";;
    4[0-9]) ICON="󰁽";;
    3[0-9]) ICON="󰁼";;
    2[0-9]) ICON="󰁻";;
    1[0-9]) ICON="󰁺";;
    [0-9]) ICON="󰂎";;
    *) ICON="󰂑";;
  esac
fi

# Update the battery item with the current percentage and icon
sketchybar --set "$NAME" icon="$ICON" label="${PERCENTAGE}%"