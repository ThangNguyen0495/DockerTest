FROM openjdk:22-jdk

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /

#=============================
# Install Dependencies
#=============================
SHELL ["/bin/bash", "-c"]

RUN apt update && apt install -y \
    curl sudo wget unzip bzip2 \
    libdrm-dev libxkbcommon-dev libgbm-dev \
    libasound-dev libnss3 libxcursor1 \
    libpulse-dev libxshmfence-dev xauth \
    xvfb x11vnc fluxbox wmctrl libdbus-glib-1-2

#==============================
# Android SDK ARGS
#==============================
ARG ARCH="x86_64"
ARG TARGET="google_apis_playstore"
ARG API_LEVEL="34"
ARG BUILD_TOOLS="34.0.0"
ARG ANDROID_API_LEVEL="android-${API_LEVEL}"
ARG ANDROID_APIS="${TARGET};${ARCH}"
ARG EMULATOR_PACKAGE="system-images;${ANDROID_API_LEVEL};${ANDROID_APIS}"
ARG PLATFORM_VERSION="platforms;${ANDROID_API_LEVEL}"
ARG BUILD_TOOL="build-tools;${BUILD_TOOLS}"
ARG ANDROID_CMD="commandlinetools-linux-11076708_latest.zip"
ARG ANDROID_SDK_PACKAGES="${EMULATOR_PACKAGE} ${PLATFORM_VERSION} ${BUILD_TOOL} platform-tools emulator"

#==============================
# Set JAVA_HOME - SDK
#==============================
ENV ANDROID_SDK_ROOT=/opt/android
ENV PATH="$PATH:$ANDROID_SDK_ROOT/cmdline-tools/tools:$ANDROID_SDK_ROOT/cmdline-tools/tools/bin:$ANDROID_SDK_ROOT/emulator:$ANDROID_SDK_ROOT/platform-tools:$ANDROID_SDK_ROOT/build-tools/${BUILD_TOOLS}"
ENV DOCKER="true"

#============================================
# Install required Android CMD-line tools
#============================================
RUN wget https://dl.google.com/android/repository/${ANDROID_CMD} -P /tmp && \
    unzip -d $ANDROID_SDK_ROOT /tmp/$ANDROID_CMD && \
    mkdir -p $ANDROID_SDK_ROOT/cmdline-tools/tools && \
    mv $ANDROID_SDK_ROOT/cmdline-tools/bin $ANDROID_SDK_ROOT/cmdline-tools/tools/ && \
    mv $ANDROID_SDK_ROOT/cmdline-tools/lib $ANDROID_SDK_ROOT/cmdline-tools/tools/ && \
    mv $ANDROID_SDK_ROOT/cmdline-tools/source.properties $ANDROID_SDK_ROOT/cmdline-tools/tools/ && \
    mv $ANDROID_SDK_ROOT/cmdline-tools/NOTICE.txt $ANDROID_SDK_ROOT/cmdline-tools/tools/

#============================================
# Install required packages using SDK manager
#============================================
RUN yes Y | sdkmanager --licenses
RUN yes Y | sdkmanager --verbose --no_https ${ANDROID_SDK_PACKAGES}

#============================================
# Create required emulator
#============================================
ARG EMULATOR_NAME="nexus"
ARG EMULATOR_DEVICE="Nexus 6"
ENV EMULATOR_NAME=$EMULATOR_NAME
ENV DEVICE_NAME=$EMULATOR_DEVICE

RUN echo "no" | avdmanager --verbose create avd --force --name "${EMULATOR_NAME}" --device "${EMULATOR_DEVICE}" --package "${EMULATOR_PACKAGE}"

#====================================
# Install latest nodejs, npm & appium
#====================================
RUN curl -sL https://deb.nodesource.com/setup_20.x | bash && \
    apt-get install -y nodejs && \
    npm install -g npm && \
    npm install -g appium --unsafe-perm=true --allow-root && \
    appium driver install uiautomator2 && \
    npm cache clean --force && \
    apt-get clean && \
    rm -rf /tmp/* /var/lib/apt/lists/*

#=========================
# Copying Scripts to root
#=========================
COPY start_emu_headless.sh /start_emu_headless.sh
RUN chmod +x /start_emu_headless.sh

#=======================
# framework entry point
#=======================
CMD bash -c "$ANDROID_SDK_ROOT/emulator/emulator -avd emu -no-audio -no-window -gpu swiftshader_indirect -no-snapshot -no-boot-anim -verbose & \
             sleep 30 && adb devices && appium -a 0.0.0.0 -p 4723 -pa /wd/hub"
