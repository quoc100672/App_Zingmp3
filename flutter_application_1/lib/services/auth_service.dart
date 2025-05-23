import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService {
  static String get baseUrl {
    // Use 10.0.2.2 for Android emulator and localhost for web
    if (kIsWeb) {
      return 'http://127.0.0.1:3000/api/auth';
    } else {
      // For Android emulator
      const host = '10.0.2.2';
      print('Using Android emulator host: $host');
      return 'http://$host:3000/api/auth';
    }
  }

  static const Duration timeoutDuration = Duration(seconds: 10);
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';

  final http.Client _client = http.Client();

  // Register
  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    try {
      print('Registering with URL: $baseUrl/register');
      final response = await _client.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'email': email,
          'password': password,
        }),
      ).timeout(timeoutDuration);

      print('Register response: ${response.body}');
      final data = json.decode(response.body);
      
      if (response.statusCode == 201) {
        await _saveAuthData(data);
        return {'success': true, 'message': 'Registration successful'};
      } else if (response.statusCode == 400) {
        final message = data['message'] ?? 'Registration failed';
        throw Exception(message);
      } else {
        throw Exception('Server error occurred');
      }
    } catch (e) {
      print('Register error: $e');
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Connection timeout. Please check your internet connection.');
      }
      rethrow;
    }
  }

  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      print('Attempting login at URL: $baseUrl/login');
      
      final response = await _client.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'email': email,
          'password': password,
        }),
      ).timeout(timeoutDuration);

      print('Login response status: ${response.statusCode}');
      print('Login response body: ${response.body}');

      final data = json.decode(response.body);
      
      if (response.statusCode == 200 && data['token'] != null) {
        await _saveAuthData(data);
        return data;
      } else {
        throw Exception(data['message'] ?? 'Login failed');
      }
    } catch (e) {
      print('Login error: $e');
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Connection timeout. Please check your internet connection.');
      }
      rethrow;
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(tokenKey);
      final userData = prefs.getString(userKey);
      
      print('Checking login state - Token: ${token != null}, UserData: ${userData != null}');
      
      if (token != null && userData != null) {
        // Validate token format
        if (token.split('.').length != 3) {
          print('Invalid token format, logging out');
          await logout();
          return false;
        }
        return true;
      }
      return false;
    } catch (e) {
      print('Error checking login state: $e');
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      print('Logging out...');
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(tokenKey);
      await prefs.remove(userKey);
      print('Logged out successfully');
    } catch (e) {
      print('Error during logout: $e');
      throw Exception('Logout failed: $e');
    }
  }

  // Get token
  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(tokenKey);
      print('Retrieved token: ${token?.substring(0, 10)}...');
      return token;
    } catch (e) {
      print('Error getting token: $e');
      return null;
    }
  }

  // Get current user
  Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString(userKey);
      if (userData != null) {
        return User.fromJson(json.decode(userData));
      }
      return null;
    } catch (e) {
      print('Get current user error: $e');
      await logout();
      return null;
    }
  }

  // Get error message from response
  String _getErrorMessage(http.Response response) {
    try {
      final data = json.decode(response.body);
      return data['message'] ?? 'An error occurred';
    } catch (e) {
      return 'An error occurred';
    }
  }

  Future<void> _saveAuthData(Map<String, dynamic> data) async {
    try {
      print('Saving auth data: $data');
      final prefs = await SharedPreferences.getInstance();
      
      if (data['token'] == null) {
        throw Exception('No token received from server');
      }
      
      await prefs.setString(tokenKey, data['token']);
      await prefs.setString(userKey, json.encode(data['user']));
      print('Auth data saved successfully');
    } catch (e) {
      print('Error saving auth data: $e');
      throw Exception('Failed to save auth data: $e');
    }
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> profileData) async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await _client.put(
        Uri.parse('$baseUrl/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(profileData),
      ).timeout(timeoutDuration);

      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        await _saveAuthData({
          'token': token,
          'user': data,
        });
        return {'success': true, 'user': data};
      } else {
        throw Exception(data['message'] ?? 'Failed to update profile');
      }
    } catch (e) {
      print('Update profile error: $e');
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Connection timeout. Please check your internet connection.');
      }
      rethrow;
    }
  }

  void dispose() {
    _client.close();
  }
}
