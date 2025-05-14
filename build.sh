#!/bin/bash
set -e

# Make sure QEMU binary formats are properly installed
echo "Installing QEMU binary formats..."
docker run --privileged --rm tonistiigi/binfmt --install all

# Make sure Docker experimental features are enabled
echo "Checking Docker experimental features..."
docker version | grep -i experimental

# Verify QEMU is properly registered
echo "Verifying QEMU registration:"
ls -la /proc/sys/fs/binfmt_misc/qemu-*

# Build the ARM64 Docker image
echo "Building ARM64 Docker image..."
docker buildx build --platform linux/arm64 -t jemalloc-test:arm64 --load .

# Verify the image architecture
echo "Verifying image architecture:"
docker inspect jemalloc-test:arm64 | grep Architecture

# Test running the container with QEMU emulation
echo "Testing container execution with explicit platform flag:"
docker run --platform linux/arm64 --rm jemalloc-test:arm64
