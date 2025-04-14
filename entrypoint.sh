#!/bin/bash

# Your original script here
"$ANDROID_HOME"/emulator/emulator -avd emu -no-audio -no-window -gpu swiftshader_indirect -no-snapshot -no-boot-anim -verbose &

echo "Waiting for emulator to boot..."
boot_completed=""
until [[ "$boot_completed" == "1" ]]; do
  sleep 5
  boot_completed=$(adb shell getprop sys.boot_completed 2>/dev/null | tr -d "\r")
  echo "Still waiting..."
done

echo "Emulator booted!"

adb shell settings put global window_animation_scale 0.0
adb shell settings put global transition_animation_scale 0.0
adb shell settings put global animator_duration_scale 0.0

adb devices

echo "Starting Appium..."
appium -a 0.0.0.0 -p 4723 -pa /wd/hub --allow-cors --relaxed-security > appium_log.txt 2>&1 &
sleep 5

# Keep the container session active
echo "Container is running. Opening a shell..."
exec bash
