#!/bin/bash

# Hardcoded location for Hawassa, Ethiopia
LATITUDE=7.0621
LONGITUDE=38.4765

if pgrep wlsunset >/dev/null 2>&1; then
    pkill wlsunset
    pkill -35 waybar
else
    # Start wlsunset in the background
    wlsunset -l "$LATITUDE" -L "$LONGITUDE" >/dev/null 2>&1 &
    pkill -35 waybar
fi
