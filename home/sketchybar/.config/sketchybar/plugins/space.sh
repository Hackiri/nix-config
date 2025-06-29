#!/bin/bash

# Get the current space ID
SPACE_ID=$(echo "$INFO" | jq -r '."space"')

# Set the icon color based on whether the space is active or not
if [ "$SELECTED" = "true" ]; then
  sketchybar --set $NAME background.color=$ACCENT_COLOR \
                         icon.color=$BAR_COLOR
else
  sketchybar --set $NAME background.color=$ITEM_BG_COLOR \
                         icon.color=$WHITE
fi