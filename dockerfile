FROM debian:bullseye-slim

ENV PYTHON_VERSION=3.13.3

# Install system dependencies (including for Tkinter and matplotlib)
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget build-essential libssl-dev zlib1g-dev libncurses5-dev \
    libbz2-dev libreadline-dev libsqlite3-dev curl libffi-dev \
    liblzma-dev uuid-dev libgdbm-dev tk-dev ca-certificates \
    libx11-dev libxext-dev libxrender-dev libxft-dev libxi-dev \
    x11-apps xvfb git \
    && rm -rf /var/lib/apt/lists/*

# Install Python 3.13.3 from source
RUN wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz && \
    tar -xzf Python-${PYTHON_VERSION}.tgz && \
    cd Python-${PYTHON_VERSION} && \
    ./configure --enable-optimizations && \
    make -j$(nproc) && \
    make altinstall && \
    cd .. && rm -rf Python-${PYTHON_VERSION} Python-${PYTHON_VERSION}.tgz

# Create working directory
WORKDIR /app

# Set Python as default
RUN ln -s /usr/local/bin/python3.13 /usr/local/bin/python

# Install Python packages
COPY requirements.txt .
RUN python -m pip install --upgrade pip && \
    python -m pip install --no-cache-dir -r requirements.txt

# Copy the rest of the app
COPY . .

# Entry point to run the app with X11 headless mode
CMD ["xvfb-run", "python", "run.py"]