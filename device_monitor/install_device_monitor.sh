#!/bin/bash

set -e  # Dừng script nếu có lỗi

echo "Installing dependencies..."
sudo apt update -y
sudo apt install -y python3-pip

echo "Copying device monitor script..."
sudo mkdir -p /opt/device_monitor
sudo cp device_monitor/device_monitor.py /opt/device_monitor/
sudo chmod +x /opt/device_monitor/device_monitor.py

echo "Setting up systemd service..."

# Tạo file service để chạy cùng hệ thống
sudo bash -c 'cat > /etc/systemd/system/device_monitor.service <<EOF
[Unit]
Description=Device Monitor Service
After=network.target

[Service]
ExecStart=/usr/bin/python3 /opt/device_monitor/device_monitor.py
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF'

# Cấp quyền chạy
sudo chmod 644 /etc/systemd/system/device_monitor.service

# Reload systemd và kích hoạt dịch vụ
sudo systemctl daemon-reload
sudo systemctl enable device_monitor.service
sudo systemctl start device_monitor.service

echo "Device monitor service installed and started successfully."
