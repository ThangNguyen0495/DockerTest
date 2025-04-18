#!/bin/bash
echo "[1/3] Starting emulator..."
"$ANDROID_HOME"/emulator/emulator -avd emu -no-audio -no-window -gpu off -no-boot-anim &

echo "[2/3] Starting Appium..."
appium -a 0.0.0.0 -p 4723 --allow-cors --relaxed-security &

echo "[3/3] Waiting..."
tail -f /dev/null

