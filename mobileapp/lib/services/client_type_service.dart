import 'package:dio/dio.dart';
import '../core/api/api_client.dart';
import '../models/client_type.dart';

class ClientTypeService {
  final ApiClient _apiClient = ApiClient();

  Future<List<ClientType>> getAll() async {
    try {
      final response = await _apiClient.get('/client-types');
      return (response.data as List)
          .map((json) => ClientType.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load client types: $e');
    }
  }

  Future<List<ClientType>> getActive() async {
    try {
      final response = await _apiClient.get('/client-types/active');
      return (response.data as List)
          .map((json) => ClientType.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load active client types: $e');
    }
  }

  Future<ClientType> getById(int id) async {
    try {
      final response = await _apiClient.get('/client-types/$id');
      return ClientType.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load client type: $e');
    }
  }

  Future<ClientType> create(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post('/client-types', data: data);
      return ClientType.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create client type: $e');
    }
  }

  Future<ClientType> update(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.patch('/client-types/$id', data: data);
      return ClientType.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update client type: $e');
    }
  }

  Future<void> delete(int id) async {
    try {
      await _apiClient.delete('/client-types/$id');
    } catch (e) {
      throw Exception('Failed to delete client type: $e');
    }
  }
}
