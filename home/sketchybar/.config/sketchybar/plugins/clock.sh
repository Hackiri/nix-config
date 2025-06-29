#!/bin/bash

# Get the current date and time
DATE=$(date '+%a %b %d')
TIME=$(date '+%I:%M %p')

# Update the clock item with the current date and time
sketchybar --set "$NAME" label="$DATE $TIME"