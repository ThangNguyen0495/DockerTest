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

echo "[4/6] Waiting for settings service to be available..."
timeout=0
max_wait=300

while [ $timeout -lt $max_wait ]; do
  service_status=$("$ANDROID_HOME"/platform-tools/adb -s emulator-5554 shell settings list system)

  if [[ -n "$service_status" ]]; then
    echo "Settings service is available!"
    break
  fi

  echo "Waiting for settings service to become available..."
  sleep 10
  timeout=$((timeout + 10))
done

echo "[5/6] Disabling Hidden API Policy Restrictions..."
"$ANDROID_HOME"/platform-tools/adb -s emulator-5554 shell settings delete global hidden_api_policy_pre_p_apps
"$ANDROID_HOME"/platform-tools/adb  -s emulator-5554 shell settings delete global hidden_api_policy_p_apps
"$ANDROID_HOME"/platform-tools/adb  -s emulator-5554 shell settings delete global hidden_api_policy

echo "[6/6] Disabling Animations..."
"$ANDROID_HOME"/platform-tools/adb  -s emulator-5554 shell settings put global window_animation_scale 0.0
"$ANDROID_HOME"/platform-tools/adb  -s emulator-5554 shell settings put global transition_animation_scale 0.0
"$ANDROID_HOME"/platform-tools/adb  -s emulator-5554 shell settings put global animator_duration_scale 0.0

echo "Emulator & Appium are ready. Keeping container alive..."