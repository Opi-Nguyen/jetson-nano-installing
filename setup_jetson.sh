#!/bin/bash

# Đặt chế độ dừng script nếu có lỗi xảy ra
set -e

# Định nghĩa đường dẫn của các script con
DOCKER_COMPOSE_SCRIPT="scripts/install_docker_compose.sh"
JTOP_SCRIPT="scripts/install_jtop.sh"
DEVICE_MONITOR_SCRIPT="device_monitor/install_device_monitor.sh"

# Kiểm tra sự tồn tại của các script
function check_script_existence() {
    if [[ ! -f "$1" ]]; then
        echo "❌ Error: $1 not found!"
        exit 1
    fi
}

# Hàm chạy cài đặt từng phần
function install_docker_compose() {
    check_script_existence "$DOCKER_COMPOSE_SCRIPT"
    echo "🔹 Installing Docker Compose..."
    bash "$DOCKER_COMPOSE_SCRIPT"
    echo "✅ Docker Compose installed successfully!"
}

function install_jtop() {
    check_script_existence "$JTOP_SCRIPT"
    echo "🔹 Installing jtop..."
    bash "$JTOP_SCRIPT"
    echo "✅ jtop installed successfully!"
}

function install_device_monitor() {
    check_script_existence "$DEVICE_MONITOR_SCRIPT"

    # Kiểm tra xem service có tồn tại không
    if systemctl list-units --type=service | grep -q "device_monitor.service"; then
        echo "🛑 Stopping and removing existing device_monitor.service..."
        sudo systemctl stop device_monitor.service || true
        sudo systemctl disable device_monitor.service || true
        sudo rm -f /etc/systemd/system/device_monitor.service
        sudo systemctl daemon-reload
        sudo systemctl reset-failed
        echo "✅ device_monitor.service removed successfully!"
    fi

    echo "🔹 Installing Device Monitor..."
    sudo bash "$DEVICE_MONITOR_SCRIPT"

    echo "✅ Device Monitor installed successfully!"
}

# Hiển thị menu lựa chọn
function show_menu() {
    echo "==========================================="
    echo "         INSTALLATION MENU                 "
    echo "==========================================="
    echo "1) Install ALL (Docker Compose, jtop, Device Monitor)"
    echo "2) Install Docker Compose only"
    echo "3) Install jtop only"
    echo "4) Install Device Monitor only"
    echo "5) Exit"
    echo "==========================================="
    read -p "Select an option [1-5]: " choice
}

# Chạy menu và xử lý lựa chọn
while true; do
    show_menu
    case $choice in
        1)
            install_docker_compose
            install_jtop
            install_device_monitor
            echo "✅ All components installed successfully!"
            break
            ;;
        2)
            install_docker_compose
            break
            ;;
        3)
            install_jtop
            break
            ;;
        4)
            install_device_monitor
            break
            ;;
        5)
            echo "Exiting installation."
            exit 0
            ;;
        *)
            echo "❌ Invalid option, please choose again."
            ;;
    esac
done
