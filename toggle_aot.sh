#!/bin/bash

# Initialize debug mode to off
DEBUG=0
if [[ "$1" == "--debug" ]]; then
    DEBUG=1
fi

# Function to print debug messages
debug_print() {
    if [[ "$DEBUG" == "1" ]]; then
        echo "$1"
    fi
}

# Get the title of the active window
WINDOW_TITLE=$(xdotool getactivewindow getwindowname)
debug_print "Active window title: $WINDOW_TITLE"

# Guard against no active window found
if [[ -z "$WINDOW_TITLE" ]]; then
    echo "No active window found."
    exit 1
fi

# Escape special characters in title to make it safe for grep
ESCAPED_WINDOW_TITLE=$(printf '%q' "$WINDOW_TITLE")
debug_print "Escaped window title: $ESCAPED_WINDOW_TITLE"

# Check if the window has the "above" state
WINDOW_INFO=$(wmctrl -l | grep "$ESCAPED_WINDOW_TITLE")
debug_print "Window info from wmctrl: $WINDOW_INFO"

# Guard against no window info found
if [[ -z "$WINDOW_INFO" ]]; then
    echo "No information found for the active window."
    exit 1
fi

# Extract the window ID from the wmctrl output
WINDOW_ID=$(echo "$WINDOW_INFO" | awk '{print $1}')
debug_print "Extracted window ID: $WINDOW_ID"

# Check the state of the specific window using xprop
STATE=$(xprop -id $WINDOW_ID | grep "_NET_WM_STATE(ATOM)" | grep "_NET_WM_STATE_ABOVE")
debug_print "Window state from xprop: $STATE"

if [[ -n "$STATE" ]]; then
    debug_print "Window is set to always on top. Removing..."
    wmctrl -i -r $WINDOW_ID -b remove,above
else
    debug_print "Window is not set to always on top. Adding..."
    wmctrl -i -r $WINDOW_ID -b add,above
fi

