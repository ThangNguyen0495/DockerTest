#!/bin/bash

# Start Appium server
echo "Starting Appium..."
appium -a 0.0.0.0 -p 4723 -pa /wd/hub --allow-cors --relaxed-security > appium_log.txt 2>&1 &
sleep 5

# Start emulator
echo "Starting Emulator..."
"$ANDROID_HOME"/emulator/emulator -avd emu -no-audio -no-window -gpu swiftshader_indirect -no-snapshot -no-boot-anim -verbose &

# Wait for the emulator to be ready
echo "Waiting for Emulator to boot..."
boot_completed=false
while [ "$boot_completed" == false ]; do
  sleep 10
  boot_completed=$(adb -s emulator-5554 shell getprop sys.boot_completed 2>/dev/null)
done
echo "Emulator has booted!"

# Disable Hidden API Policy Restrictions
echo "Disabling Hidden API Policy Restrictions..."
adb -s emulator-5554 shell settings delete global hidden_api_policy_pre_p_apps
adb -s emulator-5554 shell settings delete global hidden_api_policy_p_apps
adb -s emulator-5554 shell settings delete global hidden_api_policy

# Disable Animations
echo "Disabling Animations..."
adb -s emulator-5554 shell settings put global window_animation_scale 0
adb -s emulator-5554 shell settings put global transition_animation_scale 0
adb -s emulator-5554 shell settings put global animator_duration_scale 0

# Download the latest APK file from GitHub
echo "Downloading APK..."
wget https://github.com/username/repository/releases/latest/download/app-debug.apk

# Install the APK on the emulator
echo "Installing APK..."
adb -s emulator-5554 install app-debug.apk

# List connected devices
adb devices

# Keep the container session active
echo "Container is running. Opening a shell..."
tail -f /dev/null
