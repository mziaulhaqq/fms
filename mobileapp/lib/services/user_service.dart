import '../core/api/api_client.dart';
import '../core/constants/api_config.dart';
import '../models/user.dart';

class UserService {
  final ApiClient _apiClient = ApiClient();

  Future<List<User>> getUsers() async {
    try {
      final response = await _apiClient.get(ApiConfig.users);
      return (response.data as List).map((json) => User.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch users: $e');
    }
  }

  Future<User> getUserById(int id) async {
    try {
      final response = await _apiClient.get('${ApiConfig.users}/$id');
      return User.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch user: $e');
    }
  }

  Future<User> createUser(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post(ApiConfig.users, data: data);
      return User.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  Future<User> updateUser(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.patch('${ApiConfig.users}/$id', data: data);
      return User.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  Future<void> deleteUser(int id) async {
    try {
      await _apiClient.delete('${ApiConfig.users}/$id');
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  Future<User> toggleUserStatus(int id) async {
    try {
      final response = await _apiClient.patch('${ApiConfig.users}/$id/toggle-status', data: {});
      return User.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to toggle user status: $e');
    }
  }
}
