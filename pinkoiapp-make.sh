#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title PinkoiApp make
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon 🤖
# @raycast.argument1 { "type": "text", "placeholder": "gen | clean | help", "optional": true }
# @raycast.packageName Ohlulu Utils

# Documentation:
# @raycast.author ohlulu
# @raycast.authorURL https://github.com/ohlulu

cd ~/Developer/Pinkoi || exit
if [ -z "$1" ];
then
    make
else
    make "$1"
fi