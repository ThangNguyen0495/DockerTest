# Use Ubuntu 22.04
FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /app

COPY . .

RUN apt-get update --fix-missing && apt-get install -y \
    wget curl tar unzip git sudo maven libgl1 mesa-utils libgl1-mesa-dri \
    && rm -rf /var/lib/apt/lists/*

# Install Java 22
RUN wget -q https://download.java.net/java/GA/jdk22.0.1/c7ec1332f7bb44aeba2eb341ae18aca4/8/GPL/openjdk-22.0.1_linux-x64_bin.tar.gz -O openjdk.tar.gz \
    && tar -xvf openjdk.tar.gz && mv jdk-22.0.1 /opt/

ENV JAVA_HOME=/opt/jdk-22.0.1
ENV PATH=$JAVA_HOME/bin:$PATH

# Set Android SDK environment
ENV ANDROID_HOME=/root/android-sdk
ENV ANDROID_SDK_ROOT=/root/android-sdk
ENV CMDLINE_TOOLS=$ANDROID_HOME/cmdline-tools
ENV PATH=$ANDROID_HOME/emulator:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools:$PATH

# Download Android SDK CLI
RUN mkdir -p $CMDLINE_TOOLS/latest && cd $CMDLINE_TOOLS/latest && \
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-8512546_latest.zip -O cmdline-tools.zip && \
    unzip cmdline-tools.zip && rm cmdline-tools.zip && mv cmdline-tools/* . && rm -rf cmdline-tools

# Accept licenses and install SDK components
RUN yes | $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager --sdk_root=$ANDROID_HOME --licenses || true
RUN $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager --sdk_root=$ANDROID_HOME \
    "platform-tools" \
    "platforms;android-35" \
    "build-tools;35.0.0" \
    "system-images;android-35;google_apis;x86_64" \
    "emulator"

# Create emulator (Pixel 3 as example)
RUN echo "no" | $ANDROID_HOME/cmdline-tools/latest/bin/avdmanager create avd -n emu -k "system-images;android-35;google_apis;x86_64" --device "pixel_3"

# Customize AVD configuration
RUN AVD_PATH="$HOME/.android/avd/emu.avd/config.ini" && \
    if [ -f "$AVD_PATH" ]; then \
        echo "Modifying emulator config..." && \
        echo "hw.cpu.ncore=4" >> "$AVD_PATH" && \
        echo "hw.ramSize=4096" >> "$AVD_PATH" && \
        echo "hw.heapSize=512" >> "$AVD_PATH" && \
        echo "disk.dataPartition.size=6G" >> "$AVD_PATH" && \
        echo "hw.keyboard=yes" >> "$AVD_PATH"; \
    else \
        echo "AVD not found! Skipping configuration." && exit 1; \
    fi

# Install Node.js v20 + Appium
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && apt-get install -y nodejs
RUN npm install -g appium && appium driver install uiautomator2

# Copy the Bash file into the container
COPY entrypoint.sh /app/entrypoint.sh

# Make the Bash file executable
RUN chmod +x entrypoint.sh

# Run the Bash file when the container starts
CMD ["bash", "/app/entrypoint.sh"]