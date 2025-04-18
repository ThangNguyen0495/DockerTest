#!/bin/bash
set -e

echo "Set environment ..."
echo "[1/6] Starting Android Emulator..."
nohup "$ANDROID_HOME/emulator/emulator" -avd emu \
  -no-boot-anim -no-window -no-audio -gpu off -no-accel -verbose > /dev/null 2>&1 &

echo "[2/6] Starting Appium server..."
nohup appium -a 0.0.0.0 -p 4723 -pa /wd/hub --allow-cors --relaxed-security > /dev/null 2>&1 &

echo "[3/6] Waiting for emulator to appear in adb..."
devices_output=""

# Waiting for emulator to appear in adb without timeout
while ! echo "$devices_output" | grep -q "emulator-5554[[:space:]]*device"; do
  devices_output=$("$ANDROID_HOME"/platform-tools/adb devices)

  echo "adb devices Output:"
  echo "$devices_output"

  echo "Waiting for emulator to appear..."
  sleep 10
done

echo "[4/6] Waiting for emulator to complete boot..."
adb -s emulator-5554 root # Add root permission
#boot_completed=""
#
## Waiting for emulator to complete boot without timeout
#while [ "$boot_completed" != "1" ]; do
#  boot_completed=$("$ANDROID_HOME"/platform-tools/adb  -s emulator-5554 shell getprop sys.boot_completed | tr -d '\r')
#  echo "Boot status: '$boot_completed'"
#  sleep 10
#done

echo "[5/6] Disabling Hidden API Policy Restrictions..."
"$ANDROID_HOME"/platform-tools/adb -s emulator-5554 shell settings delete global hidden_api_policy_pre_p_apps
"$ANDROID_HOME"/platform-tools/adb  -s emulator-5554 shell settings delete global hidden_api_policy_p_apps
"$ANDROID_HOME"/platform-tools/adb  -s emulator-5554 shell settings delete global hidden_api_policy

echo "[6/6] Disabling Animations..."
"$ANDROID_HOME"/platform-tools/adb  -s emulator-5554 shell settings put global window_animation_scale 0.0
"$ANDROID_HOME"/platform-tools/adb  -s emulator-5554 shell settings put global transition_animation_scale 0.0
"$ANDROID_HOME"/platform-tools/adb  -s emulator-5554 shell settings put global animator_duration_scale 0.0

echo "Emulator & Appium are ready. Keeping container alive..."