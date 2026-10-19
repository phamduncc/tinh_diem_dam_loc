# 🎴 ĐIỂM SÂM - SỔ ĐIỂM SÂM LỐC OFFLINE

> **Ứng dụng tính điểm và quản lý bàn chơi bài Sâm Lốc chuyên nghiệp, tiện lợi, hoạt động hoàn toàn Offline trên đa nền tảng.**

---

## 📌 1. TỔNG QUAN DỰ ÁN

| Thuộc tính | Chi tiết |
| :--- | :--- |
| **Tên ứng dụng** | **Điểm Sâm** (*Sâm Lốc Scorekeeper*) |
| **Thể loại** | Tiện ích / Sổ tay tính điểm trò chơi dân gian (*Utility / Board Game Tool*) |
| **Nền tảng hỗ trợ** | Android, iOS, Windows, Web |
| **Công nghệ phát triển** | Flutter (Dart SDK ^3.11.5) |
| **Kiến trúc quản lý trạng thái** | Provider Pattern |
| **Cơ sở dữ liệu** | SharedPreferences (Lưu trữ cục bộ - Local Storage) |
| **Chế độ hoạt động** | **Offline 100%** – Không cần internet, không cần tạo tài khoản, không quảng cáo |

### 🎯 Mục tiêu phát triển
Khi chơi bài Sâm Lốc ngoài đời thực với bạn bè, người thân hoặc dịp lễ Tết, việc tính nhẩm số lá phạt, thối 2 đen, thối 2 đỏ, thối tứ quý, cóng (cháy bài), ăn sâm hoặc đền sâm thường rất phức tạp và dễ gây tranh cãi hay nhầm lẫn nếu ghi chép bằng giấy bút thông thường.

**Điểm Sâm** ra đời nhằm số hóa toàn bộ trải nghiệm ghi điểm:
- Thao tác nhập điểm **siêu nhanh chỉ trong vài giây** sau mỗi ván.
- **Tự động áp dụng công thức phạt chính xác** theo đúng luật chơi Sâm Lốc dân gian.
- **Cân bằng điểm tuyệt đối (Zero-Sum)**: Tổng điểm cả bàn luôn luôn bằng 0, minh bạch tuyệt đối cho mọi người chơi.
- Trải nghiệm mượt mà, giao diện sang trọng, hiện đại với cả chế độ Sáng (Light) và Tối (Dark).

---

## 🌟 2. CÁC TÍNH NĂNG NỔI BẬT

### 👥 2.1. Quản lý bàn chơi & Người chơi linh hoạt
- Hỗ trợ thiết lập bàn chơi từ **2 đến 5 người** (quy chuẩn bài Sâm Lốc thông thường).
- Đặt tên bàn chơi linh hoạt kèm thời gian tạo.
- Tự do đặt tên người chơi hoặc chọn nhanh từ danh sách tên gần đây (Recent Players).
- Mỗi người chơi được gán màu đại diện (avatar color) riêng biệt giúp dễ dàng nhận diện trên bảng điểm.

### ⚡ 2.2. Nhập điểm thông minh đa kịch bản (Quick Round Sheet)
Ứng dụng hỗ trợ đầy đủ tất cả các tình huống phát sinh trong thực tế của một ván bài Sâm Lốc:
1. **Thắng ván thông thường (Normal Win):**
   - Chọn người về Nhất.
   - Chọn nhanh số lá còn lại trên tay của từng người thua (từ 1 đến 10 lá).
   - Đánh dấu trạng thái **Cóng (Cháy bài)** nếu người thua không đánh ra được lá bài nào.
   - Chọn số lượng **Thối Heo đen (2 bích, 2 tép)**, **Thối Heo đỏ (2 cơ, 2 rô)**, và **Thối Tứ quý**.
2. **Báo Sâm thành công (Xin Sâm thắng):**
   - Người xin Sâm đánh một mạch về hết bài mà không ai chặn được.
   - Người xin Sâm ăn trọn số điểm phạt cố định từ tất cả người chơi còn lại trên bàn.
3. **Đền Sâm (Bị chặn khi xin Sâm):**
   - Người xin Sâm bị đối thủ khác chặn bài.
   - Hỗ trợ 2 chế độ đền:
     - **Đền cho riêng người chặn:** Người chặn ăn toàn bộ số điểm phạt của người báo Sâm.
     - **Đền cho cả bàn:** Người báo Sâm trả điểm phạt cho từng người chơi trên bàn.
4. **Ăn trắng (Tới trắng):**
   - Về nhất ngay sau khi chia bài: Sảnh rồng (10 lá liên tiếp), Tứ quý 2, Đồng màu (10 lá cùng đỏ hoặc cùng đen), 5 đôi, hoặc 3 sám cô.
   - Ăn trọn điểm phạt ăn trắng từ tất cả người thua.
5. **Nhập thủ công (Manual Adjustment):**
   - Cho phép nhập trực tiếp số điểm âm/dương cho từng người chơi khi có quy ước cá cược hoặc thỏa thuận đặc biệt riêng ngoài luật chuẩn.

### 📊 2.3. Bảng điểm & Xếp hạng thời gian thực (Live Leaderboard)
- Hiển thị tổng điểm lũy kế của tất cả người chơi sau mỗi ván.
- Phân biệt trực quan điểm dương (màu xanh lá) và điểm âm (màu đỏ).
- Xếp hạng thời gian thực: Biểu tượng Vàng (Hạng 1), Bạc (Hạng 2), Đồng (Hạng 3).
- Thống kê chi tiết: Số ván thắng, số ván ăn Sâm, tỷ lệ phong độ.
- **Hoàn tác ván đấu (Undo Round):** Dễ dàng xóa ván đấu vừa nhập nếu lỡ ấn nhầm điểm số.

### ⚙️ 2.4. Tùy biến bộ luật chơi (Custom Rules Engine)
Mỗi địa phương hay nhóm bạn có thể có những quy định tính điểm khác nhau. Ứng dụng cho phép cấu hình chi tiết:
- **Điểm cơ bản mỗi lá:** Mặc định 1 điểm/lá.
- **Phạt Cóng (Cháy bài):** Mặc định tính tương đương 15 lá.
- **Phạt Thối 2 đen:** Mặc định 10 lá.
- **Phạt Thối 2 đỏ:** Mặc định 15 lá.
- **Phạt Thối Tứ quý:** Mặc định 15 lá.
- **Điểm Báo Sâm thành công:** Mặc định 20 lá/người.
- **Điểm Đền Sâm:** Mặc định 20 lá/người.
- **Điểm Ăn trắng:** Mặc định 20 lá/người.
- **Chế độ Zero-Sum:** Bật/Tắt tự động cân bằng tổng điểm bàn chơi = 0.

### 📜 2.5. Lịch sử bàn chơi & Chi tiết ván đấu (Game History)
- Tự động lưu trữ tất cả các bàn chơi đã kết thúc.
- Xem lại danh sách bàn theo thời gian: Tên bàn, số người chơi, số ván đã chơi, thời gian kết thúc, người chiến thắng chung cuộc.
- Xem chi tiết từng ván của bàn cũ: Ai thắng, kiểu thắng gì, ai bị cóng, ai thối heo, biến động điểm số từng người.
- Hỗ trợ chức năng **Chơi lại (Rematch)** giữ nguyên danh sách người chơi và cấu hình luật để mở bàn mới nhanh chóng.

### 📖 2.6. Sổ tay Hướng dẫn luật chơi Sâm Lốc
Tích hợp sẵn mục tra cứu luật chơi Sâm Lốc chuẩn miền Bắc:
- Quy tắc chia bài, độ lớn quân bài (không phân biệt chất, chỉ so độ lớn).
- Quy tắc Báo Sâm & Đền Sâm.
- Quy tắc Chặn bài & Bắt bài.
- Điều kiện Ăn trắng & Phạt Thối/Cóng.

### 🎨 2.7. Giao diện cao cấp (Modern Casino Aesthetics)
- Hỗ trợ cả 2 chế độ: **Giao diện Tối (Dark Theme)** thanh lịch phong cách sòng bài poker sang trọng & **Giao diện Sáng (Light Theme)** sạch sẽ, độ tương phản cao.
- Nút bấm lớn, thao tác 1 chạm thuận tiện ngay cả khi đang cầm điện thoại bằng một tay bên bàn cờ.
- Hiệu ứng chuyển động (animations) và màu sắc thẻ bài tinh tế.

---

## 🧮 3. CÔNG THỨC & CƠ CHẾ TÍNH ĐIỂM CHI TIẾT

Cơ chế tính điểm được hiện thực hóa trong `ScoringEngine` (`lib/services/scoring_engine.dart`):

### 1. Ván thắng thường:
$$\text{Điểm phạt người thua } i = -\left( \text{Số lá còn lại} + (\text{Số Heo đen} \times 10) + (\text{Số Heo đỏ} \times 15) + (\text{Số Tứ quý} \times 15) \right) \times \text{Hệ số lá}$$
*(Nếu người chơi bị **Cóng**, số lá còn lại được thay thế bằng mức phạt Cóng = 15 lá)*

$$\text{Điểm người về Nhất} = \sum_{i \in \text{người thua}} |\text{Điểm phạt người thua } i|$$

### 2. Báo Sâm thành công:
$$\text{Điểm phạt mỗi người thua} = -20 \text{ điểm}$$
$$\text{Điểm người Báo Sâm} = + 20 \times (\text{Số người chơi} - 1)$$

### 3. Đền Sâm (Bị chặn):
- **Trường hợp đền riêng người chặn:**
  - Người báo Sâm hỏng: $- \left( 20 \times (\text{Số người chơi} - 1) \right)$
  - Người chặn thành công: $+ \left( 20 \times (\text{Số người chơi} - 1) \right)$
  - Những người chơi khác: $0$ điểm.
- **Trường hợp đền cả bàn:**
  - Mỗi người chơi khác: $+ 20$ điểm.
  - Người báo Sâm hỏng: $- \left( 20 \times (\text{Số người chơi} - 1) \right)$

### 4. Ăn trắng:
$$\text{Điểm phạt mỗi người thua} = -20 \text{ điểm}$$
$$\text{Điểm người Ăn trắng} = + 20 \times (\text{Số người chơi} - 1)$$

---

## 📁 4. CẤU TRÚC DỰ ÁN (PROJECT STRUCTURE)

```plaintext
tinh_diem_dam_loc/
├── lib/
│   ├── main.dart                          # Entry point khởi chạy ứng dụng & Provider Setup
│   ├── core/                              # Cấu hình lõi dùng chung
│   │   ├── constants/
│   │   │   └── app_constants.dart         # Hằng số (tên app, màu đại diện, storage keys)
│   │   └── theme/
│   │       └── app_theme.dart             # Cấu hình màu sắc, Theme Dark & Light, Typography
│   ├── data/                              # Dữ liệu & Models
│   │   ├── database/
│   │   │   └── local_storage.dart         # Tầng lưu trữ SharedPreferences
│   │   └── models/
│   │       ├── player.dart                # Model Người chơi (ID, tên, màu đại diện)
│   │       ├── game_rules.dart            # Model Bộ luật cấu hình điểm số
│   │       ├── round.dart                 # Model Ván đấu (người thắng, kiểu thắng, điểm số)
│   │       └── game.dart                  # Model Bàn chơi (danh sách ván, người chơi, xếp hạng)
│   ├── services/                          # Tầng xử lý nghiệp vụ & logic
│   │   ├── scoring_engine.dart            # Thuật toán tính điểm Sâm Lốc chuẩn xác
│   │   └── game_provider.dart             # State Management quản lý bàn đang chơi & lịch sử
│   └── features/                          # Các màn hình tính năng (Feature-based)
│       ├── home/
│       │   └── home_screen.dart           # Màn hình chính (Bàn đang diễn ra, lối tắt, menu)
│       ├── new_game/
│       │   └── new_game_screen.dart       # Màn hình tạo bàn chơi mới (chọn 2-5 người, đặt tên)
│       ├── game/
│       │   ├── game_screen.dart           # Màn hình bàn chơi trực tiếp (bảng điểm, nút ghi điểm)
│       │   └── widgets/
│       │       ├── scoreboard_card.dart   # Thẻ hiển thị điểm số người chơi
│       │       ├── quick_round_sheet.dart # Bottom sheet nhập điểm ván đấu siêu tốc
│       │       ├── round_history_view.dart# Danh sách ván đấu đã qua & nút Undo
│       │       └── game_leaderboard_dialog.dart # Bảng xếp hạng & tổng kết bàn
│       ├── history/
│       │   ├── history_screen.dart        # Màn hình danh sách lịch sử các bàn chơi
│       │   └── game_detail_screen.dart    # Xem lại chi tiết bàn chơi đã kết thúc
│       └── settings/
│           ├── settings_screen.dart       # Màn hình cài đặt tổng quan
│           ├── rules_config_screen.dart   # Màn hình điều chỉnh điểm số các mục luật
│           └── rules_guide_screen.dart    # Sổ tay hướng dẫn luật Sâm Lốc dân gian
├── pubspec.yaml                           # Khai báo thư viện & cấu hình dự án Flutter
└── README.md                              # Tài liệu giới thiệu dự án
```

---

## 🛠️ 5. CÔNG NGHỆ & THƯ VIỆN SỬ DỤNG

- **[Flutter SDK](https://flutter.dev/) & [Dart SDK](https://dart.dev/):** Khung phát triển ứng dụng đa nền tảng hiện đại, mượt mà 60/120 FPS.
- **[provider](https://pub.dev/packages/provider) (^6.1.5):** Quản lý trạng thái phản ứng nhanh (State Management), tách biệt UI và Business Logic.
- **[shared_preferences](https://pub.dev/packages/shared_preferences) (^2.5.6):** Lưu trữ dữ liệu liên tục (persistent storage) dưới dạng Key-Value cục bộ trên máy.
- **[intl](https://pub.dev/packages/intl) (^0.20.3):** Định dạng ngày tháng, số và tiền tệ chuẩn xác.
- **[uuid](https://pub.dev/packages/uuid) (^4.6.0):** Tạo mã định danh duy nhất (UUID v4) cho từng bàn chơi, ván chơi và người chơi.
- **[cupertino_icons](https://pub.dev/packages/cupertino_icons) (^1.0.8):** Bộ biểu tượng chuẩn phong cách iOS.

---

## 🚀 6. HƯỚNG DẪN CÀI ĐẶT & CHẠY DỰ ÁN

### Yêu cầu môi trường
- Đã cài đặt Flutter SDK (khuyến nghị phiên bản 3.19.0 trở lên).
- Cài đặt thiết bị giả lập (Android Emulator / iOS Simulator) hoặc cắm thiết bị thật, hoặc kích hoạt Windows Desktop/Web.

### Các bước chạy ứng dụng
1. **Mở thư mục dự án:**
   ```bash
   cd tinh_diem_dam_loc
   ```

2. **Cài đặt các gói phụ thuộc:**
   ```bash
   flutter pub get
   ```

3. **Kiểm tra trạng thái thiết bị:**
   ```bash
   flutter devices
   ```

4. **Khởi chạy ứng dụng:**
   ```bash
   flutter run
   ```

---

## 🔮 7. KẾ HOẠCH PHÁT TRIỂN TIẾP THEO (ROADMAP)

- [ ] **Chia sẻ bảng điểm (Share Scoreboard):** Xuất ảnh bảng điểm hoặc kết quả trận đấu ra định dạng PNG để gửi nhanh qua Zalo, Messenger, Facebook.
- [ ] **Chuyển đổi điểm ra tiền cược:** Tự động quy đổi điểm số ra số tiền tương ứng dựa trên mức cược mỗi điểm (VD: 1.000đ/điểm, 5.000đ/điểm, ...).
- [ ] **Biểu đồ biến động điểm (Score Chart):** Vẽ biểu đồ đường thể hiện phong độ và sự trồi sụt điểm số của các người chơi qua từng ván.
- [ ] **Hỗ trợ thêm các trò chơi bài dân gian khác:** Tiến Lên Miền Nam, Tá Lả (Phỏm), Ba Cây, Liêng, Mậu Binh (Binh Xập Xám).

---

## 📄 8. BẢN QUYỀN & GIẤY PHÉP

Dự án được xây dựng phục vụ nhu cầu tính điểm giải trí lành mạnh, phi lợi nhuận cho người chơi bài Sâm Lốc dân gian.
