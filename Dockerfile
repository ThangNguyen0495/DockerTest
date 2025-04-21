FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive

# Update apt cache
RUN apt-get update

# Install wget
RUN apt-get install -y wget

# Install curl
RUN apt-get install -y curl

# Install tar
RUN apt-get install -y tar

# Install unzip
RUN apt-get install -y unzip

# Install sudo
RUN apt-get install -y sudo

# Install maven
RUN apt-get install -y maven

# Install libgl1
RUN apt-get install -y libgl1

# Install mesa-utils (optional, can be removed if not needed)
RUN apt-get install -y mesa-utils

# Install libgl1-mesa-dri (can be replaced with libgl1-mesa-glx if needed)
RUN apt-get install -y libgl1-mesa-dri

RUN apt-get update && apt-get install -y libpulse0

# Clean up apt cache to reduce image size
RUN rm -rf /var/lib/apt/lists/*

# Install Java 22
RUN wget -q https://download.java.net/java/GA/jdk22.0.1/c7ec1332f7bb44aeba2eb341ae18aca4/8/GPL/openjdk-22.0.1_linux-x64_bin.tar.gz -O openjdk.tar.gz \
    && tar -xvf openjdk.tar.gz && mv jdk-22.0.1 /opt/

ENV JAVA_HOME=/opt/jdk-22.0.1
ENV PATH=$JAVA_HOME/bin:$PATH

# Cài Google Chrome mới nhất
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    dpkg -i google-chrome-stable_current_amd64.deb || apt-get install -fy

# Chạy thử để verify
CMD ["bash"]