FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive

# Cài các dependency cơ bản
RUN apt-get update && apt-get install -y \
    wget unzip curl gnupg2 ca-certificates fonts-liberation libappindicator3-1 libasound2 libatk-bridge2.0-0 \
    libnspr4 libnss3 libxss1 libxcomposite1 libxcursor1 libxdamage1 libxi6 libxtst6 libgbm-dev libxrandr2 xdg-utils \
    && rm -rf /var/lib/apt/lists/*

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