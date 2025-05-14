#!/bin/bash
set -e

# Build the ARM64 Docker image
docker buildx build --platform linux/arm64 -t jemalloc-test:arm64 --load .

# Verify the image architecture
echo "Verifying image architecture:"
docker inspect jemalloc-test:arm64 | grep Architecture

# Test running the container with QEMU emulation
echo "Testing container execution:"
docker run --rm jemalloc-test:arm64
