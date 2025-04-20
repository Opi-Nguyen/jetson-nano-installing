#!/bin/bash

set -e

echo "🚀 Bắt đầu cài đặt Docker Compose (plugin chính thức) cho Jetson Nano..."

# Kiểm tra Docker đã được cài hay chưa
if ! command -v docker &> /dev/null; then
    echo "❌ Docker chưa được cài. Hãy cài Docker trước khi tiếp tục."
    exit 1
fi

# Cài curl nếu chưa có
if ! command -v curl &> /dev/null; then
    echo "🔧 curl chưa có, đang cài đặt..."
    sudo apt update
    sudo apt install -y curl
else
    echo "✅ curl đã được cài."
fi

# Tạo thư mục plugin nếu chưa tồn tại
mkdir -p ~/.docker/cli-plugins

# Tải Docker Compose plugin (dành cho Jetson Nano - aarch64)
echo "⬇️ Đang tải docker-compose plugin..."
curl -SL https://github.com/docker/compose/releases/download/v2.24.5/docker-compose-linux-aarch64 \
    -o ~/.docker/cli-plugins/docker-compose

# Cấp quyền thực thi
chmod +x ~/.docker/cli-plugins/docker-compose

# Kiểm tra phiên bản
echo "🔍 Kiểm tra phiên bản docker compose..."
docker compose version

# Thêm user hiện tại vào nhóm docker
echo "👤 Thêm người dùng '$USER' vào nhóm docker..."
sudo groupadd docker 2>/dev/null || true
sudo usermod -aG docker $USER

echo "✅ Cài đặt Docker Compose plugin thành công!"
echo "🔁 Vui lòng **logout hoặc reboot** để áp dụng quyền nhóm docker."
echo "👉 Sau đó bạn có thể dùng: docker compose up -d"
