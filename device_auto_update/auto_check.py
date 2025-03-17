import os
import json
import time
import requests
import threading

# Định nghĩa thông tin server
DOMAIN_REMOTE = "hec08rwqwte.sn.mynetname.net"
DOMAIN_LAN = "192.168.88.100"
PORT = "8040"

CHECK_UPDATE_API = "/api/v1/check-update"
DEVICE_INFO_PATH = "/home/.device_info"

def run_dummy_function():
    """Hàm giả lập thực hiện hành động khi có cập nhật"""
    print("🚀 Dummy function is running... Update detected!")

def check_server_access(domain):
    """Kiểm tra xem server có thể truy cập được không"""
    url = f"http://{domain}:{PORT}{CHECK_UPDATE_API}"
    try:
        response = requests.get(url, timeout=3)
        return response.status_code == 200
    except requests.exceptions.RequestException:
        return False

def select_server():
    """Chọn server phù hợp dựa vào môi trường mạng"""
    if check_server_access(DOMAIN_REMOTE):
        return f"http://{DOMAIN_REMOTE}"

    if check_server_access(DOMAIN_LAN):
        return f"http://{DOMAIN_LAN}"

    return None

def check_update_loop():
    """Gọi API `/check-update` mỗi 5 giây"""
    while True:
        server = select_server()
        if not server:
            print("❌ Không tìm thấy server, thử lại sau 10 giây...")
            time.sleep(10)
            continue  # Thử lại sau

        url = f"{server}:{PORT}{CHECK_UPDATE_API}"

        try:
            response = requests.get(url, timeout=5)
            if response.status_code == 200:
                update_status = response.json().get("update_available", False)
                if update_status:
                    print("✅ Update detected! Running dummy function...")
                    run_dummy_function()
                else:
                    print("🔍 No update available.")
            else:
                print(f"⚠️ Server returned status code {response.status_code}")
        except Exception as e:
            print(f"⚠️ Error checking update: {e}")

        time.sleep(5)

if __name__ == "__main__":
    print("🔄 Starting auto_check_update tool...")
    update_thread = threading.Thread(target=check_update_loop, daemon=True)
    update_thread.start()

    while True:
        time.sleep(1)  # Giữ chương trình chạy
