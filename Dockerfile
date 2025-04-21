FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Cập nhật repo và cài các phụ thuộc cần thiết
RUN apt-get update && apt-get install -y \
  wget \
  curl \
  gnupg \
  unzip \
  fonts-liberation \
  xdg-utils \
  libappindicator3-1 \
  libasound2 \
  libatk-bridge2.0-0 \
  libatk1.0-0 \
  libcups2 \
  libdbus-1-3 \
  libgdk-pixbuf2.0-0 \
  libnspr4 \
  libnss3 \
  libx11-xcb1 \
  libxcomposite1 \
  libxdamage1 \
  libxrandr2 \
  --no-install-recommends

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