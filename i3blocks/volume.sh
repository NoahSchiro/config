#!/bin/bash
VOLUME=$(amixer get Master | grep -o "[0-9]*%" | head -1)
MUTE=$(amixer get Master | grep '\[off\]')
if [ "$MUTE" ]; then
    echo "$VOLUME (muted)"
else
    echo "$VOLUME"
fi
