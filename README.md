# 🎴 Điểm Sâm - Sổ Điểm Sâm Lốc Offline

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Windows%20%7C%20Web-blue)]()
[![License](https://img.shields.io/badge/License-MIT-green)]()

> **Điểm Sâm** là ứng dụng di động tính điểm và quản lý bàn chơi bài **Sâm Lốc** chuyên nghiệp, trực quan và tiện lợi, hoạt động **100% Offline** không cần mạng internet, không tài khoản, không quảng cáo.

📖 **Tài liệu tham khảo**:
- [Tài liệu mô tả chi tiết dự án (MO_TA_UNG_DUNG.md)](file:///c:/Users/dupv3/Documents/tinh_diem_dam_loc/MO_TA_UNG_DUNG.md)
- [Thông tin đăng tải Google Play Store (GOOGLE_PLAY_DESCRIPTION.md)](file:///c:/Users/dupv3/Documents/tinh_diem_dam_loc/GOOGLE_PLAY_DESCRIPTION.md)

---

## ✨ Điểm Nổi Bật

- ⚡ **Ghi điểm siêu tốc (Quick Round Sheet):** Nhập điểm ván đấu chỉ trong 3-5 giây.
- 🧮 **Tự động hóa toàn bộ luật Sâm Lốc:**
  - Thắng thường theo số lá còn lại.
  - Phạt **Cóng (cháy bài)**.
  - Phạt **Thối 2 đen, Thối 2 đỏ, Thối Tứ quý**.
  - Tính điểm **Báo Sâm (Xin Sâm) thành công** & **Đền Sâm** (đền cho người chặn hoặc đền cả bàn).
  - Tính điểm **Ăn trắng (Tới trắng)**: Sảnh rồng, Tứ quý 2, Đồng màu, 5 đôi, 3 sám cô.
  - Cho phép điều chỉnh điểm thủ công linh hoạt.
- ⚖️ **Cân bằng bàn đấu (Zero-Sum):** Tự động đảm bảo tổng điểm bàn chơi luôn bằng 0.
- 👥 **Linh hoạt từ 2 - 5 người chơi:** Đổi tên người chơi, gán màu đại diện, lưu danh sách người chơi gần đây.
- ⚙️ **Tùy chỉnh luật chơi:** Tự do điều chỉnh mức phạt/thưởng từng tình huống theo luật địa phương.
- 📜 **Lịch sử ván đấu & Hoàn tác:** Xem lại chi tiết từng ván của các bàn trước đó, hỗ trợ nút Undo khi nhập nhầm.
- 🌓 **Giao diện hiện đại & Dark Mode:** Thiết kế phong cách Casino cao cấp, hỗ trợ cả giao diện Sáng và Tối.
- 🔒 **An toàn & Offline 100%:** Toàn bộ dữ liệu được lưu cục bộ trên thiết bị của bạn.

---

## 📱 Ảnh Chụp & Giao Diện

- **Màn hình chính:** Theo dõi bàn chơi đang diễn ra, lối tắt mở bàn mới, truy cập lịch sử và cài đặt.
- **Bàn chơi trực tiếp:** Bảng điểm trực quan với huy hiệu Vàng, Bạc, Đồng cho các vị trí dẫn đầu.
- **Bảng nhập điểm:** Giao diện thẻ trượt thông minh, chọn số lá và thối heo chỉ với 1 chạm.
- **Sổ tay luật chơi:** Tra cứu nhanh luật Sâm Lốc dân gian chuẩn miền Bắc.

---

## 🚀 Hướng Dẫn Cài Đặt & Khởi Chạy

### Điều kiện tiên quyết
- Đã cài đặt [Flutter SDK](https://flutter.dev/docs/get-started/install)
- Đã cấu hình máy ảo hoặc kết nối điện thoại Android / iOS / Windows Desktop

### Các bước thực hiện:
```bash
# 1. Clone hoặc tải mã nguồn về máy
cd tinh_diem_dam_loc

# 2. Cài đặt các gói thư viện
flutter pub get

# 3. Chạy ứng dụng trên thiết bị
flutter run
```

---

## 📂 Cấu Trúc Thư Mục

```plaintext
lib/
├── core/                  # Constants, chủ đề màu sắc Dark/Light (AppTheme)
├── data/
│   ├── database/          # LocalStorage bằng SharedPreferences
│   └── models/            # Player, GameRules, Round, Game
├── services/
│   ├── scoring_engine.dart# Thuật toán tính điểm Sâm Lốc
│   └── game_provider.dart # Quản lý trạng thái bàn chơi (Provider)
├── features/
│   ├── home/              # Màn hình chính
│   ├── new_game/          # Thiết lập tạo bàn mới
│   ├── game/              # Bảng điểm trực tiếp, nhập điểm, bảng xếp hạng
│   ├── history/           # Xem lại lịch sử các bàn chơi đã lưu
│   └── settings/          # Cài đặt luật chơi & hướng dẫn luật
└── main.dart              # Khởi tạo ứng dụng
```

---

## 📄 Tài Liệu Tham Khảo

Chi tiết về thiết kế hệ thống, công thức toán học tính điểm và kịch bản sử dụng được trình bày đầy đủ tại:  
👉 [Tài liệu mô tả ứng dụng chi tiết (MO_TA_UNG_DUNG.md)](file:///c:/Users/dupv3/Documents/tinh_diem_dam_loc/MO_TA_UNG_DUNG.md)
