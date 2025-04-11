#!/bin/bash

echo "🚀 Starting emulator..."

# Start emulator in background
nohup "$ANDROID_HOME"/emulator/emulator -avd emu -no-audio -no-window -gpu swiftshader_indirect -no-snapshot -no-boot-anim > emulator.log 2>&1 &

# Wait for emulator to fully boot
boot_completed=""
while [ "$boot_completed" != "1" ]; do
  sleep 5
  boot_completed=$(adb -s emulator-5554 shell getprop sys.boot_completed | tr -d '\r\n' || true)
  echo "⏳ Waiting for emulator to boot..."
done
echo "✅ Emulator has booted!"
adb devices

# Start Appium in background
echo "🚀 Starting Appium server..."
nohup appium -a 0.0.0.0 -p 4723 -pa /wd/hub --allow-cors --relaxed-security > appium.log 2>&1 &

# Wait for Appium to be ready
until curl -s http://localhost:4723/wd/hub/status | grep -q '"ready":[ ]*true'; do
  sleep 2
  echo "⏳ Waiting for Appium to be ready..."
done
echo "✅ Appium server is ready!"

# Keep container alive
tail -f /dev/null
