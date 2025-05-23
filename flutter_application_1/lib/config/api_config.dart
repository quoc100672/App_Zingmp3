import 'package:flutter/foundation.dart';

class ApiConfig {
  // For web
  static String get baseUrl {
    // Use 10.0.2.2 for Android emulator and localhost for web
    if (kIsWeb) {
      return 'http://127.0.0.1:3000';
    } else {
      // For Android emulator
      return 'http://10.0.2.2:3000';
    }
  }
  
  static const String apiPath = '/api';
  static const String authPath = '$apiPath/auth';
  static const String songsPath = '$apiPath/songs';
}
