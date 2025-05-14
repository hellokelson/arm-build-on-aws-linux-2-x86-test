#!/bin/bash
set -e

# Update and install dependencies
sudo yum update -y
sudo yum install -y docker git

# Start Docker service
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user

# Install QEMU for multi-architecture support
sudo amazon-linux-extras install epel -y
sudo yum install -y qemu qemu-user qemu-user-static

# Set up Docker buildx
sudo docker run --privileged --rm tonistiigi/binfmt --install all
sudo docker buildx create --name arm64builder --driver docker-container --use
sudo docker buildx inspect --bootstrap

echo "Setup complete! You may need to log out and back in for group changes to take effect."
echo "Run the build script with: ./build.sh"
