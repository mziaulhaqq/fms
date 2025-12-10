import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../core/api/api_client.dart';
import '../core/constants/api_config.dart';

class AuthService {
  final _storage = const FlutterSecureStorage();
  final _apiClient = ApiClient();
  
  static const String _keyAccessToken = 'access_token';
  static const String _keyUserData = 'user_data';
  
  // Login with real API
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _apiClient.post(
        ApiConfig.authLogin,
        data: {
          'username': username,
          'password': password,
        },
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        
        // Store access token securely
        await _storage.write(
          key: _keyAccessToken,
          value: data['access_token'],
        );
        
        // Store user data
        await _storage.write(
          key: _keyUserData,
          value: jsonEncode(data['user']),
        );
        
        return {
          'success': true,
          'user': data['user'],
          'message': 'Login successful',
        };
      }
      
      return {
        'success': false,
        'message': 'Login failed',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', ''),
      };
    }
  }
  
  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: _keyAccessToken);
    return token != null && token.isNotEmpty;
  }
  
  // Get access token
  Future<String?> getAccessToken() async {
    return await _storage.read(key: _keyAccessToken);
  }
  
  // Get current user data
  Future<Map<String, dynamic>?> getCurrentUser() async {
    final userDataJson = await _storage.read(key: _keyUserData);
    if (userDataJson != null) {
      return jsonDecode(userDataJson);
    }
    return null;
  }
  
  // Get current user email
  Future<String?> getCurrentUserEmail() async {
    final user = await getCurrentUser();
    return user?['email'];
  }
  
  // Get current user full name
  Future<String?> getCurrentUserFullName() async {
    final user = await getCurrentUser();
    return user?['fullName'];
  }
  
  // Get current user ID
  Future<int?> getCurrentUserId() async {
    final user = await getCurrentUser();
    return user?['id'];
  }
  
  // Logout
  Future<void> logout() async {
    await _storage.delete(key: _keyAccessToken);
    await _storage.delete(key: _keyUserData);
  }
  
  // Clear all stored data
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
