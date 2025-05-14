# Building ARM Docker Images on x86 EC2 Instances

This repository contains a test environment for building ARM64 Docker images on x86 EC2 instances using Docker BuildX and QEMU.

## Prerequisites

- EC2 instance running Amazon Linux 2 (x86_64)
- AMI ID: ami-0090481fc3887c878
- Region: us-west-2

## Setup Instructions

1. Launch an EC2 instance using the specified AMI in us-west-2
2. Clone this repository
3. Make the scripts executable:
   ```
   chmod +x setup.sh build.sh
   ```
4. Run the setup script:
   ```
   ./setup.sh
   ```
5. Log out and log back in to apply group changes
6. Run the build script:
   ```
   ./build.sh
   ```

## What's Included

- `Dockerfile`: Multi-stage build for a Rust application using jemalloc
- `jemalloc-test/`: Simple Rust application that uses the jemalloc allocator
- `setup.sh`: Script to set up the build environment with Docker and QEMU
- `build.sh`: Script to build and test the ARM64 Docker image

## How It Works

The setup uses Docker BuildX with QEMU emulation to build ARM64 containers on x86 hardware. The key components are:

1. QEMU user-mode emulation for ARM64
2. Docker BuildX for multi-architecture builds
3. Platform flag to specify ARM64 target architecture

## Troubleshooting

If you encounter issues:

1. Verify Docker is running: `systemctl status docker`
2. Check QEMU installation: `ls -la /usr/bin/qemu-*`
3. Verify BuildX setup: `docker buildx ls`
4. Check for sufficient disk space: `df -h`
