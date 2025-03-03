#!/bin/bash

# Define variables
BALENA_VERSION="2.1.0"
BALENA_DEB="balena-etcher_${BALENA_VERSION}_amd64.deb"
BALENA_URL="https://github.com/balena-io/etcher/releases/download/v${BALENA_VERSION}/${BALENA_DEB}"

echo "🚀 Starting installation of Balena Etcher v${BALENA_VERSION}..."

# Update package list
echo "🕐 Updating package list..."
sudo apt update -y

# Check if wget is installed
if ! command -v wget &> /dev/null; then
    echo "⚠️ wget is not installed. Installing wget..."
    sudo apt install wget -y
fi

# Download the .deb package
echo "⬇️ Downloading Balena Etcher from: $BALENA_URL"
wget -O "$BALENA_DEB" "$BALENA_URL"

# Verify if the file was downloaded successfully
if [ ! -f "$BALENA_DEB" ]; then
    echo "❌ Error: Failed to download Balena Etcher!"
    exit 1
fi

# Install Balena Etcher
echo "⚙️ Installing Balena Etcher..."
sudo apt install ./"$BALENA_DEB" -y

# Verify if the installation was successful
if command -v balena-etcher-electron &> /dev/null; then
    echo "✅ Balena Etcher has been successfully installed!"
else
    echo "❌ Installation failed!"
    exit 1
fi

# Remove the downloaded .deb file after successful installation
echo "🗑️ Removing the downloaded .deb file..."
rm -f "$BALENA_DEB"

echo "🎉 Installation of Balena Etcher v${BALENA_VERSION} completed successfully!"
