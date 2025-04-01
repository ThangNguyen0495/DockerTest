# Use a stable base image (Ubuntu 22.04 - Jammy)
FROM ubuntu:22.04

# Set non-interactive mode to avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update --fix-missing && apt-get install -y \
    wget \
    unzip \
    curl \
    git \
    sudo \
    maven \
    libgl1 \
    mesa-utils \
    libgl1-mesa-dri \
    && rm -rf /var/lib/apt/lists/*  # Clean up to reduce image size \
RUN sudo apt-get install -y qemu-kvm

# Install Eclipse Temurin JDK 22
RUN wget -O /tmp/jdk.tar.gz https://github.com/adoptium/temurin22-binaries/releases/download/jdk-22%2B36/OpenJDK22U-jdk_x64_linux_hotspot_22_36.tar.gz \
    && mkdir -p /opt/jdk \
    && tar -xzf /tmp/jdk.tar.gz -C /opt/jdk --strip-components=1 \
    && rm /tmp/jdk.tar.gz

# Set Java environment variables
ENV JAVA_HOME=/usr
ENV PATH="$JAVA_HOME/bin:$PATH"

# Verify Java installation
RUN java -version

# Set environment variables
ENV ANDROID_HOME=/root/android-sdk
ENV ANDROID_SDK_ROOT=/root/android-sdk
ENV CMDLINE_TOOLS=$ANDROID_HOME/cmdline-tools
ENV PATH=$ANDROID_HOME/emulator:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools:$PATH

# Download Android command-line tools
WORKDIR $CMDLINE_TOOLS/latest
RUN wget -q https://dl.google.com/android/repository/commandlinetools-linux-8512546_latest.zip -O cmdline-tools.zip \
    && unzip cmdline-tools.zip \
    && rm cmdline-tools.zip \
    && mv cmdline-tools/* . \
    && rm -rf cmdline-tools

# Ensure correct directory structure
RUN ls -R $ANDROID_HOME

# Accept SDK licenses
RUN yes | $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager --sdk_root=$ANDROID_HOME --licenses || true

# Install necessary SDK tools
RUN $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager --sdk_root=$ANDROID_HOME \
    "platform-tools" \
    "platforms;android-35" \
    "build-tools;35.0.0" \
    "system-images;android-35;google_apis;x86_64" \
    "emulator"

# Create an AVD (Android Virtual Device)
RUN echo "no" | $ANDROID_HOME/cmdline-tools/latest/bin/avdmanager create avd -n emu -k "system-images;android-35;google_apis;x86_64" --device "pixel_3"

# Start Emulator when container runs
CMD $ANDROID_HOME/emulator/emulator -avd emu -no-audio -no-window -gpu swiftshader_indirect -no-snapshot -no-boot-anim -verbose & \
    sleep 5; \
    boot_completed=""; \
    while [ "$boot_completed" != "1" ]; do \
      sleep 5; \
      boot_completed=$($ANDROID_HOME/platform-tools/adb -s emulator-5554 shell getprop sys.boot_completed || true); \
      echo "Waiting for emulator to boot..."; \
    done; \
    echo "Emulator has booted!"; \
    $ANDROID_HOME/platform-tools/adb -s emulator-5554 shell input keyevent 82 || true; \
    echo "Unlocking emulator..."; \
    adb -P 5037 -s emulator-5554 shell settings delete global hidden_api_policy_pre_p_apps; \
    adb -P 5037 -s emulator-5554 shell settings delete global hidden_api_policy_p_apps; \
    adb -P 5037 -s emulator-5554 shell settings delete global hidden_api_policy; \
    adb -P 5037 -s emulator-5554 shell settings put global window_animation_scale 0; \
    adb -P 5037 -s emulator-5554 shell settings put global transition_animation_scale 0; \
    adb -P 5037 -s emulator-5554 shell settings put global animator_duration_scale 0; \
    echo "Configuration Completed."; \
    $ANDROID_HOME/platform-tools/adb devices; \
    tail -f /dev/null

# Install Node.js v20 & npm
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs

# Install Appium globally
RUN npm install -g appium && appium driver install uiautomator2

# Start Appium
CMD nohup appium -a 0.0.0.0 -p 4723 -pa /wd/hub > appium_log.txt 2>&1 & \
    tail -f appium_log.txt