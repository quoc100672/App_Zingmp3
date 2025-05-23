import 'dart:math';

class Helpers {
  // Random màu, random số, random item từ list
  static T randomItem<T>(List<T> items) {
    final rand = Random();
    return items[rand.nextInt(items.length)];
  }

  // Kiểm tra chuỗi có rỗng không
  static bool isNullOrEmpty(String? value) {
    return value == null || value.trim().isEmpty;
  }

  // Ví dụ check kết nối internet, bạn sẽ cần thêm package connectivity_plus...
}
