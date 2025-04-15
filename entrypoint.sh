#!/bin/bash
set -x

echo "[1/6] Starting Appium server..."
appium -a 0.0.0.0 -p 4723 -pa /wd/hub --allow-cors --relaxed-security > appium_log.txt 2>&1 &

echo "[2/6] Starting Android Emulator..."
"$ANDROID_HOME"/emulator/emulator -avd emu \
  -no-audio -no-window -gpu swiftshader_indirect \
  -no-snapshot -no-boot-anim -verbose > /app/emulator_log.txt 2>&1 &

echo "[3/6] Waiting for emulator to appear in adb..."
timeout=0
max_wait=120
while [[ $timeout -lt $max_wait ]]; do
  devices_output=$("$ANDROID_HOME"/platform-tools/adb devices | grep emulator-5554)
  if [[ -n "$devices_output" ]]; then
    echo "Emulator appeared: $devices_output"
    break
  fi
  echo "[$timeout s] Emulator not ready yet..."
  sleep 5
  timeout=$((timeout + 5))
done

echo "[4/6] Waiting for emulator to complete boot..."
boot_completed=""
timeout=0
max_wait=120
while [ "$boot_completed" != "1" ] && [ $timeout -lt $max_wait ]; do
  boot_completed=$("$ANDROID_HOME"/platform-tools/adb -s emulator-5554 shell getprop sys.boot_completed | tr -d '\r')
  echo "Boot status: '$boot_completed' after ${timeout}s"
  sleep 5
  timeout=$((timeout + 5))
done

echo "[5/6] Disabling Hidden API Policy Restrictions..."
adb -s emulator-5554 shell settings delete global hidden_api_policy_pre_p_apps || true
adb -s emulator-5554 shell settings delete global hidden_api_policy_p_apps || true
adb -s emulator-5554 shell settings delete global hidden_api_policy || true

echo "[6/6] Disabling Animations..."
adb -s emulator-5554 shell settings put global window_animation_scale 0.0
adb -s emulator-5554 shell settings put global transition_animation_scale 0.0
adb -s emulator-5554 shell settings put global animator_duration_scale 0.0

echo "All set. Emulator & Appium are ready. Keeping container alive..."
tail -f /dev/null
