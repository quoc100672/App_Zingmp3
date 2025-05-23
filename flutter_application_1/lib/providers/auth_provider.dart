import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isAuthenticated = false;
  String? _token;
  String? _userId;
  bool _isLoading = false;
  String? _error;
  bool _isCheckingAuth = false;
  String? _name;
  String? _email;

  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;
  String? get userId => _userId;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get name => _name;
  String? get email => _email;

  AuthProvider() {
    print('Creating AuthProvider');
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    if (_isCheckingAuth) return;
    _isCheckingAuth = true;
    _isLoading = true;
    notifyListeners();
    
    try {
      print('Checking authentication state...');
      final isLoggedIn = await _authService.isLoggedIn();
      print('Is logged in: $isLoggedIn');
      
      if (isLoggedIn) {
        final token = await _authService.getToken();
        final user = await _authService.getCurrentUser();
        print('Retrieved token and user: ${token != null}, ${user != null}');
        
        if (token != null && user != null) {
          _token = token;
          _userId = user.id;
          _name = user.name;
          _email = user.email;
          _isAuthenticated = true;
          print('Authentication state restored successfully');
        } else {
          print('Missing token or user data, logging out');
          await logout();
        }
      } else {
        print('Not logged in, clearing state');
        await _clearAuthState();
      }
    } catch (e) {
      print('Error checking auth state: $e');
      _error = 'Failed to restore login state';
      await _clearAuthState();
    } finally {
      _isCheckingAuth = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _clearAuthState() async {
    _isAuthenticated = false;
    _token = null;
    _userId = null;
    _name = null;
    _email = null;
    await _authService.logout();
  }

  Future<bool> login(String email, String password) async {
    if (_isLoading) return false;
    
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      print('Attempting login with email: $email');
      final response = await _authService.login(email, password);
      print('Login response: ${response.toString()}');
      
      if (response['token'] != null) {
        _token = response['token'];
        _userId = response['user']['id'];
        _name = response['user']['name'];
        _email = response['user']['email'];
        _isAuthenticated = true;
        _error = null;
        print('Login successful: $_userId, $_name');
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        print('Login failed: No token in response');
        await _clearAuthState();
        _error = 'Login failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('Login error: $e');
      await _clearAuthState();
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    if (_isLoading) return;
    
    try {
      _isLoading = true;
      notifyListeners();
      
      await _clearAuthState();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String name, String email, String password) async {
    if (_isLoading) return false;
    
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _authService.register(name, email, password);
      if (response['success']) {
        // After successful registration, try to login
        final loginSuccess = await login(email, password);
        if (!loginSuccess) {
          _error = 'Registration successful but login failed. Please try logging in manually.';
          notifyListeners();
        }
        return loginSuccess;
      }
      return false;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<bool> updateProfile(Map<String, dynamic> profileData) async {
    if (_isLoading) return false;
    
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _authService.updateProfile(profileData);
      if (response['success']) {
        _name = profileData['name'] ?? _name;
        _email = profileData['email'] ?? _email;
        _isLoading = false;
        notifyListeners();
        return true;
      }
      
      _error = 'Failed to update profile';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
} 