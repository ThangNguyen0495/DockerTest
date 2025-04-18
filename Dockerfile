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

# Cài Google Chrome mới nhất
RUN wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" \
    > /etc/apt/sources.list.d/google-chrome.list && \
    apt-get update && apt-get install -y google-chrome-stable

# Thêm user để tránh lỗi sandbox
RUN useradd -m chrome && \
    mkdir -p /home/chrome && chown -R chrome /home/chrome

USER chrome
WORKDIR /app

# Chạy thử để verify
CMD ["google-chrome-stable", "--version"]