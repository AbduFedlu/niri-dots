#!/bin/bash

# LOGIC: Toggle Service if "toggle" argument is passed
if [ "$1" == "toggle" ]; then
    if pgrep -x kdeconnectd > /dev/null; then
        pkill kdeconnectd
    else
        /usr/lib/kdeconnectd &
    fi
    exit 0
fi

# STATE 1: Daemon is NOT running
if ! pgrep -x kdeconnectd > /dev/null; then
    echo '{"text": " Off", "tooltip": "Service Stopped\nRight-click to start", "class": "stopped"}'
    exit 0
fi

# STATE 2: Daemon IS running (Check for devices)
ID=$(kdeconnect-cli -a --id-only | head -n 1)

if [ -n "$ID" ]; then
    # STATE 3: Device Connected
    NAME=$(kdeconnect-cli -a --name-only | head -n 1)
    BATT=$(qdbus org.kde.kdeconnect /modules/kdeconnect/devices/$ID/battery org.kde.kdeconnect.device.battery.charge)
    echo "{\"text\": \" $NAME\", \"tooltip\": \"Battery: $BATT%\", \"class\": \"connected\"}"
else
    # STATE 4: Service running, but no device found
    echo '{"text": " ...", "tooltip": "Service Running\nNo device connected", "class": "disconnected"}'
fi
