# Use a stable base image (Ubuntu 22.04 - Jammy)
FROM ubuntu:latest

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

# Install Node.js v20 & npm
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs

# Install Appium globally
RUN npm install -g appium && appium driver install uiautomator2

# Start Appium and Android emulator
CMD bash -c "$ANDROID_HOME/emulator/emulator -avd emu -no-audio -no-window -gpu swiftshader_indirect -no-snapshot -no-boot-anim -verbose & \
             sleep 30 && adb devices && appium -a 0.0.0.0 -p 4723 -pa /wd/hub"