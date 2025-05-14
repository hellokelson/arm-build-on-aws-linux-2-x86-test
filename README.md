# Building ARM Docker Images on x86 EC2 Instances

This repository contains a test environment for building and running ARM64 Docker images on x86 EC2 instances using Docker BuildX and QEMU emulation.

## Prerequisites

- EC2 instance running Amazon Linux 2 (x86_64)
- AMI ID: ami-0090481fc3887c878
- Region: us-west-2
- Recommended instance type: t3.medium or larger

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
- `launch-instance.sh`: Helper script to launch an EC2 instance with the correct configuration

## How It Works

### Cross-Architecture Building

This solution enables building ARM64 Docker images on x86 hardware through:

1. **QEMU User-Mode Emulation**: Allows execution of ARM64 binaries on x86 systems
2. **Docker BuildX**: Provides multi-architecture build capabilities
3. **Platform Flags**: Specifies ARM64 as the target architecture

### Key Components

- **Docker BuildX**: Creates isolated build environments with proper architecture support
- **QEMU Binary Registration**: Registers ARM64 binary formats with the kernel
- **Docker Experimental Features**: Enables advanced features needed for cross-architecture support

### Build Process

1. The setup script:
   - Installs Docker and required dependencies
   - Installs QEMU for ARM64 emulation
   - Registers QEMU binary formats with the kernel
   - Creates a Docker BuildX builder with proper configuration
   - Enables Docker experimental features

2. The build script:
   - Verifies QEMU and Docker configuration
   - Builds the ARM64 Docker image using BuildX
   - Tests running the container with proper emulation

### Running ARM64 Containers on x86

To run the built ARM64 container on an x86 system, the `--platform` flag is essential:

```bash
docker run --platform linux/arm64 --rm jemalloc-test:arm64
```

This instructs Docker to use QEMU emulation when executing the container.

## Use Cases

- Testing ARM64 containers before deploying to ARM-based environments (like AWS Graviton)
- Developing for multiple architectures from a single development machine
- CI/CD pipelines that need to build for multiple architectures
- Cost optimization by using x86 instances for ARM64 development

## Performance Considerations

- Building ARM64 images on x86 hardware is slower than native builds
- QEMU emulation adds overhead when running ARM64 containers
- For production builds, consider using native ARM64 instances

## Troubleshooting

If you encounter issues:

1. Verify Docker is running: `systemctl status docker`
2. Check QEMU installation: `ls -la /usr/bin/qemu-*`
3. Verify BuildX setup: `docker buildx ls`
4. Check for sufficient disk space: `df -h`
5. Ensure Docker experimental features are enabled: `docker version | grep -i experimental`
6. Verify QEMU binary formats are registered: `ls -la /proc/sys/fs/binfmt_misc/qemu-*`

## Common Errors and Solutions

### "exec format error" when running containers
This typically means QEMU emulation isn't properly configured. Make sure to:
- Run containers with `--platform linux/arm64` flag
- Verify QEMU is properly installed and registered

### BuildX errors about existing builders
If you encounter errors about existing builders:
- Remove the existing builder: `docker buildx rm arm-builder`
- Check for lingering containers: `docker ps -a | grep buildx_buildkit`
- Remove any lingering containers: `docker rm -f <container-id>`

## System Requirements

The setup has been tested with:
- Amazon Linux 2
- Kernel 5.10+
- Docker 25.0.8+
- QEMU 3.1.0+
