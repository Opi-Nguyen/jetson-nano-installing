#!/bin/bash

# --- Thông tin cấu hình (có thể chỉnh sửa hoặc truyền vào từ biến môi trường) ---
SERVER_PUBLIC_IP="103.147.34.134"
SERVER_PUBLIC_KEY="48m5fxw6BdMxr+QLbAZ5VymhPJRBsvEpCJqsR3M59VI="
SERVER_USER="root"
CAMERA_IP="192.168.1.201"
CAMERA_PORT="554"
JETSON_USER=$(whoami)
SSH_KEY_PATH="/home/$JETSON_USER/.ssh/id_rsa"

# --- IP VPN sẽ được truyền vào khi chạy, ví dụ: sudo bash install.sh 10.0.0.10 ---
VPN_IP=${1:-""}
if [ -z "$VPN_IP" ]; then
    echo "❌ Bạn cần truyền IP VPN cho Jetson (ví dụ: sudo bash $0 10.0.0.10)"
    exit 1
fi

# --- Kiểm tra quyền root ---
if [ "$EUID" -ne 0 ]; then
    echo "❌ Vui lòng chạy script với quyền sudo: sudo bash $0 $VPN_IP"
    exit 1
fi

# --- Cài đặt WireGuard ---
echo "📦 Cài đặt WireGuard và SSH client..."
apt update
apt install -y wireguard openssh-client

# --- Tạo khóa WireGuard ---
echo "🔑 Tạo khóa WireGuard..."
wg genkey | tee /etc/wireguard/client_private.key | wg pubkey > /etc/wireguard/client_public.key
CLIENT_PRIVATE_KEY=$(cat /etc/wireguard/client_private.key)
CLIENT_PUBLIC_KEY=$(cat /etc/wireguard/client_public.key)
echo "Khóa công khai của Jetson (lưu lại để thêm vào server): $CLIENT_PUBLIC_KEY"

# --- Tạo file cấu hình WireGuard ---
echo "⚙️ Tạo file cấu hình WireGuard (/etc/wireguard/wg0.conf)..."
cat <<EOF > /etc/wireguard/wg0.conf
[Interface]
PrivateKey = $CLIENT_PRIVATE_KEY
Address = $VPN_IP/24
DNS = 8.8.8.8

[Peer]
PublicKey = $SERVER_PUBLIC_KEY
Endpoint = $SERVER_PUBLIC_IP:51820
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
EOF

# --- Khởi động WireGuard ---
echo "🚀 Khởi động WireGuard..."
wg-quick up wg0
systemctl enable wg-quick@wg0

# --- Tạo script tự động kết nối lại VPN ---
echo "🔄 Tạo script kiểm tra kết nối VPN mỗi phút..."
cat <<EOF > /usr/local/bin/auto_reconnect.sh
#!/bin/bash
VPN_PEER_IP="10.0.0.1"
INTERFACE="wg0"
LOG_FILE="/var/log/wg_auto_reconnect.log"
TIMESTAMP=\$(date "+%Y-%m-%d %H:%M:%S")

ping -c 2 -W 2 \$VPN_PEER_IP > /dev/null 2>&1
if [ \$? -ne 0 ]; then
    echo "\$TIMESTAMP ❌ VPN lost. Restarting..." | tee -a \$LOG_FILE
    wg-quick down \$INTERFACE
    sleep 2
    wg-quick up \$INTERFACE
    ping -c 2 -W 2 \$VPN_PEER_IP > /dev/null 2>&1
    [ \$? -eq 0 ] && echo "\$TIMESTAMP ✅ VPN reconnected." | tee -a \$LOG_FILE || echo "\$TIMESTAMP ❌ VPN reconnection failed." | tee -a \$LOG_FILE
else
    echo "\$TIMESTAMP ✅ VPN OK." >> \$LOG_FILE
fi
EOF
chmod +x /usr/local/bin/auto_reconnect.sh
(crontab -l 2>/dev/null; echo "* * * * * /usr/local/bin/auto_reconnect.sh") | crontab -

# --- Tạo script reverse SSH tunnel ---
echo "🌐 Tạo script reverse SSH tunnel..."
cat <<EOF > /usr/local/bin/rttunnel.sh
#!/bin/bash
SERVER_USER="$SERVER_USER"
SERVER_IP="10.0.0.1"
REMOTE_PORT=8554
CAMERA_IP="$CAMERA_IP"
CAMERA_PORT="$CAMERA_PORT"
SSH_KEY="$SSH_KEY_PATH"
LOG_FILE="/var/log/rttunnel.log"

while true; do
    TUNNEL_CHECK=\$(ps aux | grep "[s]sh -N -R \$REMOTE_PORT")
    if [ -z "\$TUNNEL_CHECK" ]; then
        echo "\$(date) - ❌ Tunnel not found. Restarting..." | tee -a \$LOG_FILE
        ssh -i \$SSH_KEY -N -R \$REMOTE_PORT:\$CAMERA_IP:\$CAMERA_PORT \$SERVER_USER@\$SERVER_IP &
        sleep 5
        [ \$? -eq 0 ] && echo "\$(date) - ✅ Tunnel created." | tee -a \$LOG_FILE || echo "\$(date) - ❌ Tunnel failed." | tee -a \$LOG_FILE
    else
        echo "\$(date) - ✅ Tunnel is running." >> \$LOG_FILE
    fi
    sleep 30
done
EOF
chmod +x /usr/local/bin/rttunnel.sh

# --- Service chạy tunnel ---
echo "🛠️ Tạo systemd service reverse SSH..."
cat <<EOF > /etc/systemd/system/rttunnel.service
[Unit]
Description=Auto SSH Reverse Tunnel for Camera
After=network-online.target wg-quick@wg0.service

[Service]
Type=simple
ExecStart=/usr/local/bin/rttunnel.sh
Restart=always
User=jetson

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable rttunnel.service
systemctl start rttunnel.service

# --- Tạo SSH key nếu chưa có ---
if [ ! -f "$SSH_KEY_PATH" ]; then
    echo "🔒 Tạo SSH key mới..."
    ssh-keygen -t rsa -b 4096 -f "$SSH_KEY_PATH" -N ""
    echo "📋 Copy khóa công khai này lên server ($SERVER_USER@$SERVER_PUBLIC_IP):"
    cat "${SSH_KEY_PATH}.pub"
fi

# --- Hoàn tất ---
echo "✅ Hoàn tất thiết lập!"
echo "  - VPN IP của thiết bị: $VPN_IP"
echo "  - Khóa công khai Jetson: $CLIENT_PUBLIC_KEY"
echo "👉 Thêm vào cấu hình server (wg0.conf)"


#run sudo bash install_wireguard.sh 10.0.0.10