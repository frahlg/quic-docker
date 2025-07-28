FROM python:3.13-bookworm

# Install system dependencies for building (cmake, git, build-essentials, python3-dev)
# as well as mbedtls-dev to use system-installed mbedtls
RUN apt-get update && apt-get install -y \
    git \
    cmake \
    build-essential \
    python3-dev \
    libmbedtls-dev \
    libmbedcrypto7 \
    libmbedx509-1 \
    && rm -rf /var/lib/apt/lists/*

# Clone repo and set up
RUN git clone https://github.com/wanghaEMQ/pynng-mqtt.git /app
WORKDIR /app
RUN git submodule update --init --recursive

# Build and install MsQuic, then update library cache
RUN cd nng/extern/msquic && \
    mkdir -p build && \
    cd build && \
    cmake .. && \
    make -j$(nproc) && \
    make install && \
    ldconfig

# Update mbedtls to a newer version that works with modern CMake
# Use mbedtls-3.6.4 which is the latest stable version
RUN sed -i "s/MBEDTLS_REV = '04a049bda1ceca48060b57bc4bcf5203ce591421'/MBEDTLS_REV = 'mbedtls-3.6.4'/" setup.py

# Clean build directories to avoid "File exists" errors during pip
RUN rm -rf mbedtls/build nng/build build .eggs/ dist/ *.egg-info 2>/dev/null || true

# Install pynng-mqtt (editable mode for development)
RUN pip install --no-cache-dir -e . && \
    pip install --no-cache-dir asyncio

# Default command: Run bash so you can test interactively
CMD ["bash"]