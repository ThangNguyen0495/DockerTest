#!/bin/bash

echo "🚀 Starting emulator..."
"$ANDROID_HOME"/emulator/emulator -avd emu -no-audio -no-window -gpu swiftshader_indirect -no-snapshot -no-boot-anim -verbose &

boot_completed=""
while [ "$boot_completed" != "1" ]; do
  sleep 5
  boot_completed=$(adb -s emulator-5554 shell getprop sys.boot_completed | tr -d '\r\n' || true)
  echo "⏳ Waiting for emulator to boot..."
done

echo "✅ Emulator has booted!"
adb devices

# Disable animation
echo "🎛️ Disabling Android animations..."
adb -s emulator-5554 shell settings put global window_animation_scale 0.0
adb -s emulator-5554 shell settings put global transition_animation_scale 0.0
adb -s emulator-5554 shell settings put global animator_duration_scale 0.0

# Start Appium
echo "🚀 Starting Appium server..."
appium -a 0.0.0.0 -p 4723 -pa /wd/hub --allow-cors --relaxed-security &
