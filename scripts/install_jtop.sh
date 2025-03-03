#!/bin/bash

echo "Updating package lists..."
sudo apt update -y

echo "Installing python3-pip..."
sudo apt install -y python3-pip

echo "Installing jetson-stats (jtop)..."
sudo pip3 install -U jetson-stats

# Kiểm tra jtop đã cài đặt thành công hay chưa
if command -v jtop &> /dev/null; then
    echo "jtop installed successfully!"
    echo "You can run it using: jtop"
else
    echo "Installation failed. Please check for errors and try again."
fi
