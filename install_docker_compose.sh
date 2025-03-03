# pip3 install --upgrade pip setuptools wheel
# pip3 install setuptools-rust
# pip3 install docker-compose
# export PATH=$HOME/.local/bin:$PATH
# echo 'export PATH=$HOME/.local/bin:$PATH' >> ~/.bashrc
# source ~/.bashrc
# docker-compose --version

#!/bin/bash

echo "Starting docker-compose installation..."

# Update pip, setuptools, and wheel
echo "Updating pip, setuptools, and wheel..."
pip3 install --upgrade pip setuptools wheel

# Install setuptools-rust (required for some dependencies)
echo "Installing setuptools-rust..."
pip3 install setuptools-rust

# Install docker-compose
echo "Installing docker-compose..."
pip3 install --user docker-compose

# Add ~/.local/bin to PATH if not already present
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo "Adding ~/.local/bin to PATH..."
    export PATH=$HOME/.local/bin:$PATH
    echo 'export PATH=$HOME/.local/bin:$PATH' >> ~/.bashrc
    source ~/.bashrc
fi

# Verify installation
echo "Checking docker-compose version..."
docker_compose_version=$(docker-compose --version 2>/dev/null)

if [[ $? -eq 0 ]]; then
    echo "✅ Docker Compose installed successfully: $docker_compose_version"
else
    echo "❌ Docker Compose installation failed."
    exit 1
fi

echo "Installation completed!"
