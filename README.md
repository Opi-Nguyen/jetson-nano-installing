# Jetson Nano Developer Kit JetPack Installation Guide

## 1. Introduction
The Jetson Nano Developer Kit is a powerful and energy-efficient AI development platform that supports NVIDIA JetPack—a comprehensive software toolkit for AI development on the Jetson platform.

For detailed information about JetPack versions, refer to:
- [JetPack Release Archive](https://developer.nvidia.com/embedded/jetpack-archive)
- [Detailed Installation Guide](https://developer.nvidia.com/embedded/learn/get-started-jetson-nano-devkit)

Note: The Jetson Nano Developer Kit can only be installed by flashing an image onto an SD card.

---

## 2. Downloading and Flashing JetPack Image onto an SD Card
### 2.1. Download JetPack Image
JetPack can be downloaded from NVIDIA's official website:
- **Download JetPack 4.6.1:** [Download Link](https://developer.nvidia.com/jetson-nano-sd-card-image)
- Or use the `wget` command:
  ```bash
  wget https://developer.nvidia.com/jetson-nano-sd-card-image
  ```

### 2.2. Install Etcher
Etcher is a popular tool for flashing images onto SD cards. To install, run the following command:
```bash
sudo bash install_etcher.sh
```
After installation, open Etcher, select the downloaded JetPack image, choose the SD card, and click **Flash** to begin the process.

---

## 3. Initial Setup & Booting Jetson Nano

### 3.1. Identify TTY Device
Before connecting Jetson Nano to a Linux computer, check the existing serial devices using:
```bash
dmesg | grep --color 'tty'
```
Then, connect the Jetson Nano to the computer via the Micro-USB port and run the command again to identify the newly added device. Example output:
```
[xxxxxx.xxxxxx] cdc_acm 1-5:1.2: ttyACM0: USB ACM device
```
The newly detected device is `/dev/ttyACM0`. Verify with:
```bash
ls -l /dev/ttyACM0
```
Example output:
```
crw-rw---- 1 root dialout 166, 0 Oct  2 02:45 /dev/ttyACM0
```

### 3.2. Connect to Serial Console using `screen`
If `screen` is not installed, install it using:
```bash
sudo apt-get install -y screen
```
Then, connect to Jetson Nano using:
```bash
sudo screen /dev/ttyACM0 115200
```

### 3.3. Exit `screen`
To exit the `screen` session, press **Ctrl + A**, then **K**, and confirm with **Y**.

### 3.4. Complete the Setup
Once connected to Jetson Nano, press **SPACE** if the initial setup screen does not appear automatically.

---

## 4. Conclusion
Installing JetPack on the Jetson Nano Developer Kit involves flashing an image onto an SD card and performing initial setup via a Serial Console. This guide ensures a smooth and accurate installation process.

If you encounter any issues, refer to NVIDIA's official documentation or the Jetson community for support.

