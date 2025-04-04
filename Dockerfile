# Use a stable base image (Ubuntu 22.04 - Jammy)
FROM ubuntu:latest

# Set non-interactive mode to avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update --fix-missing && apt-get install -y \
    wget \
    unzip \
    libgl1 \
    libnss3 \
    libgconf-2-4 \
    fonts-liberation \
    && rm -rf /var/lib/apt/lists/*

# Install Google Chrome browser
RUN wget -q -O google-chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    apt-get update && \
    apt-get install -y ./google-chrome.deb && \
    rm google-chrome.deb


# Install Java
RUN wget -q https://download.java.net/java/GA/jdk22.0.1/c7ec1332f7bb44aeba2eb341ae18aca4/8/GPL/openjdk-22.0.1_linux-x64_bin.tar.gz -O openjdk-22.0.1_linux-x64_bin.tar.gz \
    && tar -xvf openjdk-22.0.1_linux-x64_bin.tar.gz \
    && mv jdk-22.0.1 /opt/

# Set JAVA_HOME and update PATH
ENV JAVA_HOME=/opt/jdk-22.0.1
ENV PATH=$JAVA_HOME/bin:$PATH