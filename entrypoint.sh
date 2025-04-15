#!/bin/bash
set -e

#echo "[1/5] Starting Appium server..."
#appium -a 0.0.0.0 -p 4723 -pa /wd/hub --allow-cors --relaxed-security > /app/appium_log.txt 2>&1 &
#sleep 10
#
#echo "[2/5] Starting Android Emulator..."
#"$ANDROID_HOME"/emulator/emulator -avd emu -no-audio -no-window -gpu swiftshader_indirect -no-snapshot -no-boot-anim -verbose &
#
#echo "[3/5] Waiting for Emulator to boot..."
#sleep 30
#boot_completed=""
#until [[ "$boot_completed" == "1" ]]; do
#  sleep 10
#  boot_completed=$("$ANDROID_HOME"/platform-tools/adb -s emulator-5554 shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')
#  echo "Current boot_completed value: '$boot_completed'"
#done
#echo "Emulator boot completed."
#
#echo "[4/5] Disabling hidden APIs and animations..."
#"$ANDROID_HOME"/platform-tools/adb -s emulator-5554 shell settings delete global hidden_api_policy_pre_p_apps || true
#"$ANDROID_HOME"/platform-tools/adb -s emulator-5554 shell settings delete global hidden_api_policy_p_apps || true
#"$ANDROID_HOME"/platform-tools/adb -s emulator-5554 shell settings delete global hidden_api_policy || true
#
#"$ANDROID_HOME"/platform-tools/adb -s emulator-5554 shell settings put global window_animation_scale 0
#"$ANDROID_HOME"/platform-tools/adb -s emulator-5554 shell settings put global transition_animation_scale 0
#"$ANDROID_HOME"/platform-tools/adb -s emulator-5554 shell settings put global animator_duration_scale 0
#
#echo "[5/5] All set. Emulator & Appium are ready. Keeping container alive..."
#tail -f /dev/null


#!/bin/bash
echo "[1/5] Starting Android Emulator..."
"$ANDROID_HOME"/emulator/emulator -avd emu \
  -no-audio -no-window -gpu swiftshader_indirect \
  -no-snapshot -no-boot-anim -verbose > /app/emulator_log.txt 2>&1 &

echo "[2/5] Starting Appium server..."
appium -a 0.0.0.0 -p 4723 -pa /wd/hub --allow-cors --relaxed-security > appium_log.txt 2>&1 &

echo "[3/5] Waiting for Emulator to boot..."
adb wait-for-device

echo "[4/5] Disabling hidden APIs and animations..."
adb shell settings put global window_animation_scale 0.0
adb shell settings put global transition_animation_scale 0.0
adb shell settings put global animator_duration_scale 0.0

# Keep the container session active
echo "[5/5] All set. Emulator & Appium are ready. Keeping container alive..."
tail -f /dev/null