#!/bin/bash
set -e

echo "[1/7] Starting Android Emulator..."
nohup "$ANDROID_HOME/emulator/emulator" -avd emu \
  -no-boot-anim -no-window -no-audio -gpu off -no-accel -verbose > emulator.log 2>&1 &

echo "[2/7] Starting Appium server..."
nohup appium -a 0.0.0.0 -p 4723 -pa /wd/hub --allow-cors --relaxed-security > /dev/null 2>&1 &

echo "[3/7] Waiting for emulator to be fully ready (booted + visible in adb)..."
timeout=0
max_wait=300

while [ $timeout -lt $max_wait ]; do
  devices_output=$("$ANDROID_HOME"/platform-tools/adb devices)

  echo "[${timeout}s] adb devices Output:"
  echo "$devices_output"

  if echo "$devices_output" | grep -q "emulator-5554[[:space:]]*device"; then
    echo "Emulator is fully booted and ready!"
    break
  fi

  echo "Waiting for emulator to boot..."
  sleep 10
  timeout=$((timeout + 10))
done

if [ $timeout -ge $max_wait ]; then
  echo "Timeout waiting for emulator to be ready!"
  exit 1
fi

sleep 10

echo "[4/7] Disabling Hidden API Policy Restrictions..."
"$ANDROID_HOME"/platform-tools/adb -s emulator-5554 shell settings delete global hidden_api_policy_pre_p_apps
"$ANDROID_HOME"/platform-tools/adb -s emulator-5554 shell settings delete global hidden_api_policy_p_apps
"$ANDROID_HOME"/platform-tools/adb -s emulator-5554 shell settings delete global hidden_api_policy

echo "[5/7] Disabling Animations..."
"$ANDROID_HOME"/platform-tools/adb -s emulator-5554 shell settings put global window_animation_scale 0.0
"$ANDROID_HOME"/platform-tools/adb -s emulator-5554 shell settings put global transition_animation_scale 0.0
"$ANDROID_HOME"/platform-tools/adb -s emulator-5554 shell settings put global animator_duration_scale 0.0

echo "[6/7] Emulator & Appium are fully ready!"

echo "[7/7] Keeping container alive..."
tail -f /dev/null
