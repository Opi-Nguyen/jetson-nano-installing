#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
INSTALL_DIR="/opt/jetson_rtsp_tunnel"
SERVICE_NAME="jetson-rtsp-tunnel.service"
SERVICE_PATH="/etc/systemd/system/$SERVICE_NAME"
CONFIG_FILE="$INSTALL_DIR/config.json"
DEVICE_INFO_FILE="/home/.device_info"

echo "[1/5] 🚚 Copy toàn bộ package vào $INSTALL_DIR..."
sudo mkdir -p "$INSTALL_DIR"
sudo cp "$SCRIPT_DIR"/* "$INSTALL_DIR/"
sudo chmod +x "$INSTALL_DIR/start_tunnel.py"

echo "[2/5] 🛠️ Nhập thông tin kết nối server:"
read -p "👉 Tên người dùng server (user): " SERVER_USER
read -p "👉 Địa chỉ server (host): " SERVER_HOST
read -p "👉 Forward port trên server (VD: 8154, hoặc để trống dùng mặc định): " FORWARD_PORT

# Cập nhật config.json
echo "[3/5] ⚙️ Cập nhật cấu hình..."
sudo jq ".server_user = \"$SERVER_USER\" | .server_host = \"$SERVER_HOST\"" "$INSTALL_DIR/config.json" > "$INSTALL_DIR/config.tmp"
sudo mv "$INSTALL_DIR/config.tmp" "$CONFIG_FILE"

# Ghi /home/.device_info nếu có forward_port
if [ -n "$FORWARD_PORT" ]; then
    echo "{\"forward_port\": $FORWARD_PORT}" | sudo tee "$DEVICE_INFO_FILE" > /dev/null
    echo "✅ Đã lưu forward_port vào $DEVICE_INFO_FILE"
fi

# Kiểm tra port
PORT_TO_USE=$(jq -r '.forward_port' "$DEVICE_INFO_FILE" 2>/dev/null || jq -r '.default_forward_port' "$CONFIG_FILE")

if [ -z "$PORT_TO_USE" ] || [ "$PORT_TO_USE" == "null" ]; then
    echo "❌ Không có cổng forward hợp lệ. Dừng cài đặt."
    exit 1
fi

# Cài đặt systemd service
echo "[4/5] 🧩 Cài đặt systemd service..."
sudo cp "$INSTALL_DIR/$SERVICE_NAME" "$SERVICE_PATH"
sudo sed -i "s|ExecStart=.*|ExecStart=/usr/bin/python3 $INSTALL_DIR/start_tunnel.py|" "$SERVICE_PATH"
sudo chmod 644 "$SERVICE_PATH"
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable "$SERVICE_NAME"
sudo systemctl restart "$SERVICE_NAME"

echo "[5/5] ✅ Dịch vụ đã được cài đặt và khởi động!"
echo "👉 Dịch vụ sẽ tự động tạo reverse SSH tunnel tới $SERVER_HOST:$PORT_TO_USE mỗi khi khởi động lại."
