#!/bin/bash
set -e

echo "Set environment ..."
ANDROID_HOME="/root/android-sdk"
ADB="$ANDROID_HOME/platform-tools/adb"
EMULATOR="$ANDROID_HOME/emulator/emulator"
APPIUM="/usr/local/bin/appium"

echo "[1/6] Starting Android Emulator..."
nohup "$EMULATOR" -avd emu \
  -no-audio -no-window -gpu swiftshader_indirect \
  -no-snapshot -no-boot-anim -verbose > /dev/null 2>&1 &

echo "[2/6] Starting Appium server..."
nohup "$APPIUM" -a 0.0.0.0 -p 4723 -pa /wd/hub --allow-cors --relaxed-security > /dev/null 2>&1 &

echo "[3/6] Waiting for emulator to appear in adb..."
timeout=0
max_wait=120

while [ $timeout -lt $max_wait ]; do
  devices_output=$("$ADB" devices)

  echo "[${timeout}s] ADB Devices Output:"
  echo "$devices_output"

  if [[ "$devices_output" == *"emulator-5554"* ]]; then
    echo "Emulator detected in adb!"
    break
  fi

  echo "Waiting for emulator to appear..."
  sleep 5
  timeout=$((timeout + 5))
done

echo "[4/6] Waiting for emulator to complete boot..."
boot_completed=""
timeout=0
max_wait=120
while [ "$boot_completed" != "1" ] && [ $timeout -lt $max_wait ]; do
  boot_completed=$("$ADB" -s emulator-5554 shell getprop sys.boot_completed | tr -d '\r')
  echo "Boot status: '$boot_completed' after ${timeout}s"
  sleep 5
  timeout=$((timeout + 5))
done

echo "[5/6] Disabling Hidden API Policy Restrictions..."
"$ADB" -s emulator-5554 shell settings delete global hidden_api_policy_pre_p_apps || true
"$ADB" -s emulator-5554 shell settings delete global hidden_api_policy_p_apps || true
"$ADB" -s emulator-5554 shell settings delete global hidden_api_policy || true

echo "[6/6] Disabling Animations..."
"$ADB" -s emulator-5554 shell settings put global window_animation_scale 0.0
"$ADB" -s emulator-5554 shell settings put global transition_animation_scale 0.0
"$ADB" -s emulator-5554 shell settings put global animator_duration_scale 0.0

echo "All set. Emulator & Appium are ready. Keeping container alive..."
tail -f /dev/null
