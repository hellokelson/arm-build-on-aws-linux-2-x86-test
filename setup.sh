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

# Register QEMU binary formats
echo "Installing QEMU binary formats..."
sudo docker run --privileged --rm tonistiigi/binfmt --install all

# Set up Docker buildx
echo "Setting up Docker buildx..."
# Remove the builder if it already exists
if docker buildx ls | grep -q arm64builder; then
  echo "Builder 'arm64builder' already exists, removing it..."
  sudo docker buildx rm arm64builder
fi

# Create a new builder
echo "Creating new builder 'arm64builder'..."
sudo docker buildx create --name arm64builder --driver docker-container --use

# Bootstrap the builder
sudo docker buildx inspect --bootstrap

# Enable experimental features in Docker
echo "Enabling Docker experimental features..."
if [ ! -f /etc/docker/daemon.json ]; then
  echo '{
  "experimental": true
}' | sudo tee /etc/docker/daemon.json
  # Restart Docker to apply changes
  sudo systemctl restart docker
else
  # Check if experimental is already enabled
  if ! grep -q '"experimental": true' /etc/docker/daemon.json; then
    # Try to use jq if available
    if command -v jq &> /dev/null; then
      sudo cp /etc/docker/daemon.json /etc/docker/daemon.json.bak
      sudo jq '. + {"experimental": true}' /etc/docker/daemon.json.bak | sudo tee /etc/docker/daemon.json
    else
      echo "Warning: jq not found. Please manually edit /etc/docker/daemon.json to add: \"experimental\": true"
    fi
    # Restart Docker to apply changes
    sudo systemctl restart docker
  fi
fi

echo "Setup complete! You may need to log out and back in for group changes to take effect."
echo "Run the build script with: ./build.sh"
