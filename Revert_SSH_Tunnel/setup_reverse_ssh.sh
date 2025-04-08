#!/bin/bash

# Cấu hình thông tin Server
SERVER_USER="user"  # Thay user bằng username trên server
SERVER_HOST="server.example.com"  # Thay bằng domain hoặc IP của server
PORT_API="http://hec08rwqwte.sn.mynetname.net:8040/get-ssh-tunnel-port"  # API để lấy port

echo "🚀 Bắt đầu cài đặt Reverse SSH Tunnel..."

# 1️⃣ Gọi API để lấy SSH Tunnel Port
echo "🌐 Đang lấy SSH Tunnel Port từ server..."
REVERSE_PORT=$(curl -s $PORT_API)

# Kiểm tra nếu không nhận được port hợp lệ
if ! [[ "$REVERSE_PORT" =~ ^[0-9]+$ ]]; then
    echo "❌ Lỗi: Không lấy được SSH Tunnel Port từ server!"
    exit 1
fi

echo "✅ SSH Tunnel Port nhận được: $REVERSE_PORT"

# 2️⃣ Tạo SSH Key nếu chưa có
if [ ! -f ~/.ssh/id_rsa ]; then
    echo "🔑 Đang tạo SSH Key..."
    ssh-keygen -t rsa -b 4096 -N "" -f ~/.ssh/id_rsa
else
    echo "✅ SSH Key đã tồn tại."
fi

# 3️⃣ Sao chép SSH Key lên server (sẽ yêu cầu nhập mật khẩu một lần)
echo "🔗 Đang sao chép SSH Key lên server..."
ssh-copy-id ${SERVER_USER}@${SERVER_HOST}

# 4️⃣ Kiểm tra kết nối SSH không cần mật khẩu
if ssh -o BatchMode=yes -o ConnectTimeout=5 ${SERVER_USER}@${SERVER_HOST} "echo SSH thành công"; then
    echo "✅ Đăng nhập SSH không cần mật khẩu đã được thiết lập!"
else
    echo "❌ SSH vẫn yêu cầu mật khẩu! Kiểm tra lại quá trình sao chép SSH Key."
    exit 1
fi

# 5️⃣ Tạo Systemd Service để Jetson tự động SSH vào server với port nhận được từ API
echo "⚙️ Đang tạo systemd service..."
SERVICE_FILE="/etc/systemd/system/reverse-ssh.service"

sudo bash -c "cat > $SERVICE_FILE" <<EOF
[Unit]
Description=Reverse SSH Tunnel to Server
After=network.target

[Service]
User=$USER
ExecStart=/usr/bin/ssh -o ServerAliveInterval=60 -o ExitOnForwardFailure=yes -N -R ${REVERSE_PORT}:localhost:22 ${SERVER_USER}@${SERVER_HOST}
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# 6️⃣ Kích hoạt và khởi động service
echo "🚀 Đang kích hoạt Reverse SSH Tunnel..."
sudo systemctl daemon-reload
sudo systemctl enable reverse-ssh
sudo systemctl start reverse-ssh

# 7️⃣ Kiểm tra trạng thái
echo "📡 Trạng thái Reverse SSH Tunnel:"
sudo systemctl status reverse-ssh --no-pager

echo "✅ Cài đặt hoàn tất! Bây giờ bạn có thể SSH từ server vào Jetson bằng:"
echo "    ssh -p ${REVERSE_PORT} ${USER}@localhost (chạy trên server)"
