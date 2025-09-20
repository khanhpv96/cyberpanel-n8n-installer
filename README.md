## **Cách sử dụng script:**

### **1. Tải và chạy script:**
```bash
# Tải script
curl -fsSL https://raw.githubusercontent.com/khanhpv96/cyberpanel-n8n-installer/main/install.sh -o install.sh

# Cấp quyền thực thi
chmod +x install.sh

# Chạy script
sudo bash install.sh
```

### **2. Script sẽ hỏi thông tin:**
- **n8n domain:** `n8n.hovandat.com`
- **n8n password:** Mật khẩu admin (tối thiểu 8 ký tự)
- **CyberPanel hostname:** `panel.your-domain.com` (optional)
- **Setup firewall:** y/n (mặc định: không)

### **3. Script tự động thực hiện:**
✅ Kiểm tra hệ thống và requirements  
✅ Cài đặt CyberPanel với OpenLiteSpeed  
✅ Cài đặt Node.js LTS  
✅ Cài đặt và cấu hình n8n  
✅ Tạo systemd service cho n8n  
✅ Cấu hình firewall (nếu chọn)  
✅ Hiển thị thông tin truy cập  

## **Tính năng đặc biệt:**

🔧 **Tự động hóa CyberPanel:** Dùng expect script để trả lời các câu hỏi  
🛡️ **An toàn:** Kiểm tra version Ubuntu, RAM, disk space  
📝 **Logging:** Tất cả log được lưu vào `/var/log/cyberpanel-n8n-install.log`  
⚡ **Tối ưu n8n:** Cấu hình polling mode tương thích OpenLiteSpeed  
