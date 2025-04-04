# Use a stable base image (Ubuntu 22.04 - Jammy)
FROM ubuntu:latest

# Set non-interactive mode to avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update --fix-missing && apt-get install -y \
    wget \
    curl \
    tar \
    unzip \
    git \
    sudo \
    maven \
    libgl1 \
    mesa-utils \
    libgl1-mesa-dri \
    && rm -rf /var/lib/apt/lists/*  # Clean up to reduce image size

RUN wget -q https://download.java.net/java/GA/jdk22.0.1/c7ec1332f7bb44aeba2eb341ae18aca4/8/GPL/openjdk-22.0.1_linux-x64_bin.tar.gz -O openjdk-22.0.1_linux-x64_bin.tar.gz \
    && tar -xvf openjdk-22.0.1_linux-x64_bin.tar.gz \
    && mv jdk-22.0.1 /opt/

# Set JAVA_HOME and update PATH
ENV JAVA_HOME=/opt/jdk-22.0.1
ENV PATH=$JAVA_HOME/bin:$PATH

# Download Android command-line tools
WORKDIR $CMDLINE_TOOLS/latest
RUN wget -q https://dl.google.com/android/repository/commandlinetools-linux-8512546_latest.zip -O cmdline-tools.zip \
    && unzip cmdline-tools.zip \
    && rm cmdline-tools.zip \
    && mv cmdline-tools/* . \
    && rm -rf cmdline-tools


# Install Google Chrome browser
RUN wget -q -O - https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb > google-chrome.deb && \
    dpkg -i google-chrome.deb || apt-get install -f && \
    rm google-chrome.deb
