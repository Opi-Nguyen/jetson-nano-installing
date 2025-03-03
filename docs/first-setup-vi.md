# Hướng Dẫn Cài Đặt JetPack cho Jetson Nano Developer Kit

## 1. Giới thiệu
Jetson Nano Developer Kit là nền tảng phát triển AI mạnh mẽ và tiết kiệm năng lượng, hỗ trợ NVIDIA JetPack - một bộ công cụ phần mềm tích hợp đầy đủ để phát triển AI trên nền tảng Jetson.

Thông tin chi tiết về các phiên bản JetPack có thể tham khảo tại:
- [JetPack Release Archive](https://developer.nvidia.com/embedded/jetpack-archive)
- [Hướng dẫn cài đặt chi tiết](https://developer.nvidia.com/embedded/learn/get-started-jetson-nano-devkit)

Lưu ý: Jetson Nano Developer Kit chỉ có thể cài đặt hệ điều hành thông qua ghi image lên thẻ SD Card.

---

## 2. Tải và Ghi JetPack Image lên Thẻ SD
### 2.1. Tải JetPack Image
JetPack có thể được tải về từ trang chính thức của NVIDIA:
- **Tải xuống JetPack 4.6.1:** [Link tải](https://developer.nvidia.com/jetson-nano-sd-card-image)
- Hoặc sử dụng lệnh `wget`:
  ```bash
  wget https://developer.nvidia.com/jetson-nano-sd-card-image
  ```

### 2.2. Cài đặt Etcher
Etcher là công cụ phổ biến để ghi image lên thẻ SD. Để cài đặt, chạy lệnh sau:
```bash
sudo bash install_etcher.sh
```
Sau khi cài đặt, mở Etcher, chọn image JetPack đã tải xuống, chọn thẻ SD và nhấn **Flash** để tiến hành ghi image.

---

## 3. Thiết lập Ban Đầu & Khởi Động Jetson Nano

### 3.1. Xác định Thiết Bị TTY
Trước khi kết nối Jetson Nano với máy tính Linux, kiểm tra danh sách các thiết bị serial hiện có bằng lệnh:
```bash
dmesg | grep --color 'tty'
```
Sau đó, kết nối Jetson Nano với máy tính qua cổng Micro-USB và chạy lại lệnh trên để xác định thiết bị mới được thêm vào. Ví dụ:
```
[xxxxxx.xxxxxx] cdc_acm 1-5:1.2: ttyACM0: USB ACM device
```
Thiết bị mới được nhận diện là `/dev/ttyACM0`. Xác nhận bằng lệnh:
```bash
ls -l /dev/ttyACM0
```
Ví dụ kết quả:
```
crw-rw---- 1 root dialout 166, 0 Oct  2 02:45 /dev/ttyACM0
```

### 3.2. Kết Nối Serial Console bằng `screen`
Nếu chưa cài đặt `screen`, cài đặt bằng lệnh:
```bash
sudo apt-get install -y screen
```
Sau đó, kết nối với Jetson Nano bằng lệnh:
```bash
sudo screen /dev/ttyACM0 115200
```

### 3.3. Thoát Khỏi `screen`
Để thoát khỏi phiên làm việc với `screen`, nhấn tổ hợp phím **Ctrl + A**, sau đó nhấn **K** và chọn **Y** để xác nhận.

### 3.4. Hoàn Thành Cài Đặt
Sau khi kết nối với Jetson Nano, nếu màn hình thiết lập ban đầu không xuất hiện, nhấn **SPACE** để hiển thị giao diện thiết lập.

---

## 4. Kết Luận
Quá trình cài đặt JetPack cho Jetson Nano Developer Kit yêu cầu ghi image lên thẻ SD và thực hiện các thiết lập ban đầu thông qua Serial Console. Hướng dẫn này giúp bạn hoàn tất quá trình cài đặt một cách nhanh chóng và chính xác.

Nếu có bất kỳ vấn đề nào, vui lòng tham khảo tài liệu chính thức từ NVIDIA hoặc cộng đồng Jetson để được hỗ trợ.

