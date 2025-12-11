import 'package:dio/dio.dart';
import '../core/api/api_client.dart';
import '../models/account_type.dart';

class AccountTypeService {
  final ApiClient _apiClient = ApiClient();

  Future<List<AccountType>> getAll() async {
    try {
      final response = await _apiClient.get('/account-types');
      return (response.data as List)
          .map((json) => AccountType.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load account types: $e');
    }
  }

  Future<List<AccountType>> getActive() async {
    try {
      final response = await _apiClient.get('/account-types/active');
      return (response.data as List)
          .map((json) => AccountType.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load active account types: $e');
    }
  }

  Future<AccountType> getById(int id) async {
    try {
      final response = await _apiClient.get('/account-types/$id');
      return AccountType.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load account type: $e');
    }
  }

  Future<AccountType> create(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post('/account-types', data: data);
      return AccountType.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create account type: $e');
    }
  }

  Future<AccountType> update(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.patch('/account-types/$id', data: data);
      return AccountType.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update account type: $e');
    }
  }

  Future<void> delete(int id) async {
    try {
      await _apiClient.delete('/account-types/$id');
    } catch (e) {
      throw Exception('Failed to delete account type: $e');
    }
  }
}
