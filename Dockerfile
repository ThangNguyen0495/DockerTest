# Use OpenJDK 22 with a Debian base image (for apt-get support)
FROM eclipse-temurin:22-jdk

# Set environment variables
ENV ANDROID_HOME=/root/android-sdk
ENV CMDLINE_TOOLS=$ANDROID_HOME/cmdline-tools/latest
ENV PATH=$CMDLINE_TOOLS/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH

# Install dependencies
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    curl \
    git \
    sudo \
    maven \
    libgl1-mesa-glx \
    libgl1-mesa-dri \
    && rm -rf /var/lib/apt/lists/*

# Install Android SDK command-line tools
RUN mkdir -p $CMDLINE_TOOLS \
    && wget https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip -O cmdline-tools.zip \
    && unzip cmdline-tools.zip -d $CMDLINE_TOOLS \
    && rm cmdline-tools.zip

# Accept Android SDK licenses
RUN yes | $CMDLINE_TOOLS/bin/sdkmanager --licenses

# Install necessary SDK tools
RUN $CMDLINE_TOOLS/bin/sdkmanager "platform-tools" "platforms;android-35" "system-images;android-35;google_apis;x86_64" "emulator"

# Create an AVD (Android Virtual Device)
RUN echo "no" | $CMDLINE_TOOLS/bin/avdmanager create avd -n emu -k "system-images;android-35;google_apis;x86_64" --device "pixel_3"

# Expose necessary ports for ADB
EXPOSE 5555
EXPOSE 5900

# Start Emulator when container runs
CMD \
    $ANDROID_HOME/emulator/emulator -avd emu -no-audio -no-window -gpu swiftshader_indirect -no-snapshot -no-boot-anim -verbose & \
    sleep 30 && adb devices && tail -f /dev/null