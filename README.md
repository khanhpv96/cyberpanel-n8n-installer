# 🚀 CyberPanel + n8n Auto Installer

**Script cài đặt tự động CyberPanel và n8n cho VPS Ubuntu mới**

Chỉ với 1 lệnh duy nhất, biến VPS Ubuntu trống thành máy chủ web hosting + automation hoàn chỉnh!

## ✨ Bạn sẽ có gì

- 🌐 **CyberPanel** - Control panel quản lý hosting hiện đại
- 🔧 **n8n** - Nền tảng tự động hóa workflow mạnh mẽ
- 🛡️ **SSL miễn phí** - Chứng chỉ Let's Encrypt tự động
- ⚡ **Tối ưu hóa** - Cấu hình sẵn để tương thích tối đa
- 🔒 **Bảo mật** - Authentication và hardening cơ bản

## 📋 Yêu cầu VPS

- **OS:** Ubuntu 20.04, 22.04, hoặc 24.04 (mới cài)
- **RAM:** Tối thiểu 2GB (khuyến nghị 4GB)
- **Ổ cứng:** Tối thiểu 20GB
- **CPU:** Tối thiểu 1 vCPU (khuyến nghị 2 vCPU)

## 🎯 Cài đặt nhanh

### Bước 1: Cấu hình DNS
Trước khi chạy script, tạo các DNS record:

```
# Cho n8n
Type: A Record
Name: n8n
Value: IP_VPS_CỦA_BẠN
TTL: 300

# Tùy chọn: Cho CyberPanel
Type: A Record  
Name: panel
Value: IP_VPS_CỦA_BẠN
TTL: 300
```

### Bước 2: Chạy script

Kết nối SSH vào VPS Ubuntu mới và chạy:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/khanhpv96/cyberpanel-n8n-installer/main/install.sh)
```

**Hoặc:**
```bash
curl -fsSL https://raw.githubusercontent.com/khanhpv96/cyberpanel-n8n-installer/main/install.sh -o install.sh
chmod +x install.sh
sudo bash install.sh
```

### Bước 3: Nhập thông tin

Script sẽ hỏi:
1. **Domain cho n8n** (VD: `n8n.domain-cua-ban.com`)
2. **Mật khẩu admin n8n** (tối thiểu 8 ký tự)
3. **Hostname CyberPanel** (tùy chọn: `panel.domain-cua-ban.com`)
4. **Cài firewall không** (y/n, mặc định: không)

### Bước 4: Đợi hoàn thành

Quá trình cài đặt mất **10-15 phút**. Script sẽ tự động:
- ✅ Kiểm tra hệ thống
- ✅ Cập nhật Ubuntu
- ✅ Cài CyberPanel + OpenLiteSpeed
- ✅ Cài Node.js + n8n
- ✅ Cấu hình services
- ✅ Hiển thị thông tin truy cập

## 🌟 Truy cập sau khi cài

### CyberPanel (Quản lý hosting)
```
URL: https://IP_VPS:8090
hoặc: https://panel.domain-cua-ban.com:8090

Username: admin
Password: [hiện trong quá trình cài]
```

### n8n (Automation)
```
URL: http://n8n.domain-cua-ban.com:5678

Username: admin  
Password: [mật khẩu bạn đã chọn]
```

## 🔧 Các lệnh quản lý

### Kiểm tra trạng thái services
```bash
systemctl status cyberpanel
systemctl status n8n
systemctl status lshttpd
```

### Restart services
```bash
systemctl restart cyberpanel
systemctl restart n8n
```

### Xem logs
```bash
journalctl -u n8n -f
tail -f /usr/local/CyberCP/logs/access.log
```

## 🔍 Xử lý lỗi thường gặp

### Không truy cập được CyberPanel/n8n
```bash
# Kiểm tra services đang chạy
systemctl status cyberpanel n8n lshttpd

# Kiểm tra ports
sudo netstat -tlnp | grep -E ':(8090|5678)'
```

### n8n không khởi động
```bash
# Xem logs n8n
journalctl -u n8n -f

# Test thủ công
cd /opt/n8n && source .env && n8n start
```

### DNS không resolve
```bash
nslookup domain-cua-ban.com
ping domain-cua-ban.com
```

## 📊 Tài nguyên sử dụng

```
CyberPanel:     ~300-500MB RAM
n8n:           ~100-200MB RAM  
OpenLiteSpeed: ~50-100MB RAM
MySQL:         ~200-400MB RAM
---
Tổng cộng:     ~650-1200MB RAM
```

## 🚀 Bước tiếp theo

### 1. Thiết lập CyberPanel
- Truy cập web interface
- Chạy Setup Wizard
- Tạo website đầu tiên

### 2. Sử dụng n8n
- Truy cập n8n interface  
- Tạo workflow đầu tiên
- Khám phá 400+ integrations

### 3. Tạo website
- CyberPanel → Websites → Create Website
- Cài WordPress hoặc upload files
- Cấu hình SSL

## 🔒 Bảo mật

Script đã bao gồm:
- ✅ Basic authentication
- ✅ SSL certificates
- ✅ Secure cookie settings
- ✅ Service isolation

**Khuyến nghị thêm:**
- Đặt mật khẩu mạnh
- Cập nhật hệ thống định kỳ
- Monitor access logs
- Backup thường xuyên

## 🤝 Đóng góp

Mọi đóng góp đều được chào đón! Hãy:
1. Fork repository này
2. Tạo feature branch
3. Test kỹ lưỡng
4. Gửi pull request

## ⚠️ Lưu ý

- Test trên môi trường development trước
- Luôn backup dữ liệu quan trọng
- Tuân thủ best practices bảo mật
- Script này chỉ dành cho mục đích giáo dục và tự động hóa

---

**Made with ❤️ cho cộng đồng Vietnamese**

*Tiết kiệm thời gian, tự động hóa mọi thứ, tập trung vào điều quan trọng nhất!*
