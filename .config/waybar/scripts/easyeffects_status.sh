#!/bin/bash

if pgrep -x "easyeffects" > /dev/null; then
    PRESETS=$(easyeffects -l | tr '\n' ',' | sed 's/,$//')
    echo "{\"text\":\" ON\",\"tooltip\":\"Active presets: ${PRESETS}\"}"
else
    echo "{\"text\":\" OFF\",\"tooltip\":\"EasyEffects not running\"}"
fi

