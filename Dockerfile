# Use OpenJDK 22 with a Debian base image (for apt-get support)
FROM eclipse-temurin:22-jdk

# Set environment variables
ENV ANDROID_HOME=/root/android-sdk
ENV PATH=$ANDROID_HOME/emulator:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools:$PATH

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
    && rm -rf /var/lib/apt/lists/*  # Clean up to reduce image size


# Install Android SDK and emulator
RUN mkdir -p $ANDROID_HOME/cmdline-tools/latest \
    && wget https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip -O cmdline-tools.zip \
    && unzip cmdline-tools.zip -d $ANDROID_HOME/cmdline-tools/latest \
    && rm cmdline-tools.zip

# Update PATH for SDK tools
ENV PATH=$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH

# Accept Android SDK licenses
RUN yes | $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager --licenses || true

# Install necessary SDK tools
RUN $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager "platform-tools" "platforms;android-35" "system-images;android-35;google_apis;x86_64" "emulator"

# Create an AVD (Android Virtual Device)
RUN echo "no" | $ANDROID_HOME/cmdline-tools/latest/bin/avdmanager create avd -n emu -k "system-images;android-35;google_apis;x86_64" --device "pixel_3"

# Expose necessary ports for ADB
EXPOSE 5555
EXPOSE 5900

# Start Emulator when container runs
CMD \
    $ANDROID_HOME/emulator/emulator -avd emu -no-audio -no-window -gpu swiftshader_indirect -no-snapshot -no-boot-anim -verbose & \
    sleep 30 && adb devices && tail -f /dev/null