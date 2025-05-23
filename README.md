# Zing MP3 Clone Application

Ứng dụng nghe nhạc được phát triển bằng Flutter, lấy cảm hứng từ Zing MP3.

## Tính năng

- 🎵 Phát nhạc trực tuyến
- 👤 Đăng nhập/Đăng ký tài khoản
- 📱 Giao diện người dùng thân thiện
- 📋 Quản lý playlist
- ❤️ Yêu thích bài hát
- 🎨 Giao diện tối/sáng
- 🔄 Đồng bộ hóa dữ liệu

## Công nghệ sử dụng

- Flutter
- MongoDB
- Provider Pattern
- REST API

## Cài đặt

1. Clone repository:
```bash
git clone https://github.com/quoc100672/App_Zingmp3.git
```

2. Di chuyển vào thư mục project:
```bash
cd App_Zingmp3
```

3. Cài đặt dependencies:
```bash
flutter pub get
```

4. Chạy ứng dụng:
```bash
flutter run
```

## Cấu trúc thư mục

```
lib/
├── models/         # Data models
├── providers/      # State management
├── screens/        # UI screens
├── services/       # API services
├── widgets/        # Reusable components
└── theme/          # App theme
```

## Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0
  provider: ^6.0.5
  shared_preferences: ^2.2.2
  just_audio: ^0.9.36
  audio_session: ^0.1.18
  mongo_dart: ^0.9.3
  share_plus: ^7.2.1
  # và các package khác...
```

## Screenshots

[Thêm screenshots của ứng dụng ở đây]

## Tác giả

- Tên của bạn
- Email: email@example.com
- GitHub: @quoc100672

## License

MIT License - xem [LICENSE.md](LICENSE.md) để biết thêm chi tiết 