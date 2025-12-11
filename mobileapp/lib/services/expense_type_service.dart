import 'package:dio/dio.dart';
import '../core/api/api_client.dart';
import '../models/expense_type.dart';

class ExpenseTypeService {
  final ApiClient _apiClient = ApiClient();

  Future<List<ExpenseType>> getAll() async {
    try {
      final response = await _apiClient.get('/expense-types');
      return (response.data as List)
          .map((json) => ExpenseType.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load expense types: $e');
    }
  }

  Future<List<ExpenseType>> getActive() async {
    try {
      final response = await _apiClient.get('/expense-types/active');
      return (response.data as List)
          .map((json) => ExpenseType.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load active expense types: $e');
    }
  }

  Future<ExpenseType> getById(int id) async {
    try {
      final response = await _apiClient.get('/expense-types/$id');
      return ExpenseType.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load expense type: $e');
    }
  }

  Future<ExpenseType> create(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post('/expense-types', data: data);
      return ExpenseType.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create expense type: $e');
    }
  }

  Future<ExpenseType> update(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.patch('/expense-types/$id', data: data);
      return ExpenseType.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update expense type: $e');
    }
  }

  Future<void> delete(int id) async {
    try {
      await _apiClient.delete('/expense-types/$id');
    } catch (e) {
      throw Exception('Failed to delete expense type: $e');
    }
  }
}
