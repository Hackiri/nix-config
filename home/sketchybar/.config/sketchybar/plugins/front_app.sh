#!/bin/bash

# Some events send additional information specific to the event in the $INFO
# variable. The front_app_switched event sends the name of the newly
# focused application in the $INFO variable

if [ "$SENDER" = "front_app_switched" ]; then
  sketchybar --set "$NAME" label="$INFO"
fi