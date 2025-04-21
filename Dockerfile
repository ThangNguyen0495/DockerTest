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

RUN apt-get install -y fonts-liberation
RUN apt-get install -y xdg-utils
RUN apt-get install -y libappindicator3-1
RUN apt-get install -y libasound2
RUN apt-get install -y libatk-bridge2.0-0
RUN apt-get install -y libatk1.0-0
RUN apt-get install -y libcups2
RUN apt-get install -y libdbus-1-3
RUN apt-get install -y libgdk-pixbuf2.0-0
RUN apt-get install -y libnspr4
RUN apt-get install -y libnss3
RUN apt-get install -y libx11-xcb1
RUN apt-get install -y libxcomposite1
RUN apt-get install -y libxdamage1
RUN apt-get install -y libxrandr2


# Clean up apt cache to reduce image size
RUN rm -rf /var/lib/apt/lists/*

# Install Java 22
RUN wget -q https://download.java.net/java/GA/jdk22.0.1/c7ec1332f7bb44aeba2eb341ae18aca4/8/GPL/openjdk-22.0.1_linux-x64_bin.tar.gz -O openjdk.tar.gz \
    && tar -xvf openjdk.tar.gz && mv jdk-22.0.1 /opt/

ENV JAVA_HOME=/opt/jdk-22.0.1
ENV PATH=$JAVA_HOME/bin:$PATH

# Cài Google Chrome mới nhất
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    sudo dpkg -i google-chrome-stable_current_amd64.deb

# Chạy thử để verify
CMD ["bash"]