FROM debian:bullseye

ENV DEBIAN_FRONTEND=noninteractive

# Update apt cache and install base tools
RUN apt-get update && \
    apt-get install -y wget tar && \
    apt-get install -y maven && \
#    apt-get install -y fonts-liberation xdg-utils libcurl3-gnutls libcurl3-nss libcurl4 libgbm1 && \
    apt-get install -y firefox-esr && \
    rm -rf /var/lib/apt/lists/*

# Install OpenJDK 22
RUN wget -q https://download.java.net/java/GA/jdk22.0.1/c7ec1332f7bb44aeba2eb341ae18aca4/8/GPL/openjdk-22.0.1_linux-x64_bin.tar.gz -O openjdk.tar.gz && \
    tar -xf openjdk.tar.gz && mv jdk-22.0.1 /opt/ && rm openjdk.tar.gz

ENV JAVA_HOME=/opt/jdk-22.0.1
ENV PATH="$JAVA_HOME/bin:$PATH"

# Run the Bash file when the container starts
CMD ["tail", "-f", "/dev/null"]
