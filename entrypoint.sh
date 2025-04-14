#!/bin/bash

# Start emulator by terminal
"$ANDROID_HOME"/emulator/emulator -avd emu -no-audio -no-window -gpu swiftshader_indirect -no-snapshot -no-boot-anim -verbose &

# Wait for the emulator to be ready
boot_completed=""
while [ "$boot_completed" != "1" ]; do
  sleep 5
  boot_completed=$("$ANDROID_HOME"/platform-tools/adb -s emulator-5554 shell getprop sys.boot_completed || true)
  echo "Waiting for emulator to boot..."
done
echo "Emulator has booted!"

echo "Disabling Hidden API Policy Restrictions..."
adb -P 5037 -s emulator-5554 shell settings delete global hidden_api_policy_pre_p_apps
adb -P 5037 -s emulator-5554 shell settings delete global hidden_api_policy_p_apps
adb -P 5037 -s emulator-5554 shell settings delete global hidden_api_policy

echo "Disabling Animations..."
adb -P 5037 -s emulator-5554 shell settings put global window_animation_scale 0
adb -P 5037 -s emulator-5554 shell settings put global transition_animation_scale 0
adb -P 5037 -s emulator-5554 shell settings put global animator_duration_scale 0

adb devices

echo "Starting Appium..."
appium -a 0.0.0.0 -p 4723 -pa /wd/hub --allow-cors --relaxed-security > appium_log.txt 2>&1 &
sleep 5

# Keep the container session active
echo "Container is running. Opening a shell..."
tail -f /dev/null
