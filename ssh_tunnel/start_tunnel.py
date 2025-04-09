#!/usr/bin/env python3
import json
import os
import subprocess
import sys

CONFIG_PATH = os.path.join(os.path.dirname(__file__), "config.json")
DEVICE_INFO_PATH = "/home/.device_info"

def load_config():
    with open(CONFIG_PATH, "r") as f:
        return json.load(f)

def load_device_info():
    if not os.path.exists(DEVICE_INFO_PATH):
        return None
    with open(DEVICE_INFO_PATH, "r") as f:
        return json.load(f)

def main():
    config = load_config()
    device_info = load_device_info()

    forward_port = None
    if device_info and "forward_port" in device_info:
        forward_port = device_info["forward_port"]
    elif "default_forward_port" in config:
        forward_port = config["default_forward_port"]

    if not forward_port:
        print("ERROR: Không có thông tin forward_port để thiết lập reverse tunnel.")
        sys.exit(1)

    server_user = config["server_user"]
    server_host = config["server_host"]

    ssh_cmd = [
        "ssh",
        "-o", "StrictHostKeyChecking=no",
        "-N",
        "-R", f"{forward_port}:localhost:8554",
        f"{server_user}@{server_host}"
    ]

    print(f"Đang khởi chạy reverse tunnel tới {server_host}:{forward_port}...")
    subprocess.run(ssh_cmd)

if __name__ == "__main__":
    main()
