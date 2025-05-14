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

# More thorough cleanup of existing buildx builder
echo "Cleaning up any existing buildx builders named 'arm64builder'..."
# First try the standard removal
if docker buildx ls | grep -q arm64builder; then
  echo "Removing builder 'arm64builder'..."
  sudo docker buildx rm -f arm64builder || true
fi

# Check for any lingering builder containers and remove them
echo "Checking for lingering builder containers..."
BUILDER_CONTAINER=$(sudo docker ps -a | grep buildx_buildkit_arm64builder || true)
if [ ! -z "$BUILDER_CONTAINER" ]; then
  CONTAINER_ID=$(echo $BUILDER_CONTAINER | awk '{print $1}')
  echo "Found lingering container: $CONTAINER_ID, removing it..."
  sudo docker rm -f $CONTAINER_ID || true
fi

# Create a new builder with a unique name to avoid conflicts
BUILDER_NAME="arm64builder_$(date +%s)"
echo "Creating new builder '$BUILDER_NAME'..."
sudo docker buildx create --name $BUILDER_NAME --driver docker-container
sudo docker buildx use $BUILDER_NAME
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
