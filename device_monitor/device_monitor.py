import os
import json
import time
import requests
import socket
import threading
import netifaces

DEVICE_INFO_PATH = "/home/.device_info"
DOMAIN_REMOTE = "hec08rwqwte.sn.mynetname.net"
DOMAIN_LAN = "192.168.88.100"
PORT = "8040"

INIT_DEVICE_API = "/api/v1/init-device-id"
UPDATE_STATUS_API = "/api/v1/update-device-status"

def get_local_ip(interface="eth0"):  # Hoặc "wlan0" nếu dùng Wi-Fi
    try:
        return netifaces.ifaddresses(interface)[netifaces.AF_INET][0]['addr']
    except KeyError:
        return "Unknown"
    
def get_ip_addresses():
    """Lấy địa chỉ IP công khai và IP cục bộ"""
    try:
        public_ip = requests.get("https://api64.ipify.org?format=json", timeout=5).json().get("ip", "Unknown")
    except:
        public_ip = "Unknown"

    try:
        local_ip = get_local_ip()
    except:
        local_ip = "Unknown"

    return public_ip, local_ip

def check_server_access(domain):
    """Kiểm tra xem server có thể truy cập được không"""
    url = f"http://{domain}:{PORT}{INIT_DEVICE_API}"
    try:
        response = requests.post(url, json={"public_ip": "test", "local_ip": "test"}, timeout=3)
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

def load_device_info():
    """Đọc file ~/.device_info nếu tồn tại"""
    if os.path.exists(DEVICE_INFO_PATH):
        with open(DEVICE_INFO_PATH, "r") as f:
            return json.load(f)
    return {}

def save_device_info(data):
    """Lưu thông tin vào file ~/.device_info"""
    with open(DEVICE_INFO_PATH, "w") as f:
        json.dump(data, f, indent=4)

def init_device_id():
    """Gửi request để lấy device_id nếu chưa có"""
    device_info = load_device_info()
    
    # Lấy thông tin IP
    public_ip, local_ip = get_ip_addresses()
    device_info.update({"public_ip": public_ip, "local_ip": local_ip})
    save_device_info(device_info)

    while device_info.get("device_id") is None:
        server = select_server()
        if not server:
            print("❌ Không tìm thấy server phù hợp, thử lại sau 10 giây...")
            time.sleep(10)
            continue  # Thử lại sau

        url = f"{server}:{PORT}{INIT_DEVICE_API}"
        try:
            response = requests.post(url, json={"public_ip": public_ip, "local_ip": local_ip}, timeout=5)
            if response.status_code == 200:
                device_id = response.json().get("device_id")
                if device_id:
                    device_info["device_id"] = device_id
                    save_device_info(device_info)
                    print(f"✅ Device ID assigned: {device_id}")
                    return
        except Exception as e:
            print(f"⚠️ Error requesting device_id: {e}")

        time.sleep(10)

def update_device_status():
    """Cập nhật trạng thái thiết bị lên server mỗi 5 giây"""
    while True:
        device_info = load_device_info()
        server = select_server()
        if not server:
            print("❌ Không tìm thấy server, bỏ qua cập nhật trạng thái...")
            time.sleep(10)
            continue  # Thử lại sau

        url = f"{server}:{PORT}{UPDATE_STATUS_API}"

        try:
            payload = {
                "device_id": device_info.get("device_id", None),
                "public_ip": device_info["public_ip"],
                "local_ip": device_info["local_ip"]
            }
            response = requests.post(url, json=payload, timeout=5)
            if response.status_code == 200:
                print(f"✅ Device status updated: {device_info.get('device_id', 'Unknown Device')}")
            else:
                print(f"⚠️ Server returned status code {response.status_code}")
        except Exception as e:
            print(f"⚠️ Error updating device status: {e}")

        time.sleep(5)



if __name__ == "__main__":
    if os.geteuid() != 0:
        print("❌ This script must be run as root.")
        exit(1)
    
    if not os.path.exists(DEVICE_INFO_PATH):
        public_ip, local_ip = get_ip_addresses()
        save_device_info({"public_ip": public_ip, "local_ip": local_ip, "device_id": None})
    
    init_thread = threading.Thread(target=init_device_id, daemon=True)
    init_thread.start()

    update_device_status()
