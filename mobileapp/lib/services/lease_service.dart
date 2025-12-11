import 'package:dio/dio.dart';
import '../core/api/api_client.dart';
import '../models/lease.dart';

class LeaseService {
  final ApiClient _apiClient = ApiClient();

  Future<List<Lease>> getAll() async {
    try {
      final response = await _apiClient.get('/leases');
      return (response.data as List)
          .map((json) => Lease.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load leases: $e');
    }
  }

  Future<List<Lease>> getActive() async {
    try {
      final response = await _apiClient.get('/leases/active');
      return (response.data as List)
          .map((json) => Lease.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load active leases: $e');
    }
  }

  Future<Lease> getById(int id) async {
    try {
      final response = await _apiClient.get('/leases/$id');
      return Lease.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load lease: $e');
    }
  }

  Future<Lease> create(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post('/leases', data: data);
      return Lease.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create lease: $e');
    }
  }

  Future<Lease> update(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.patch('/leases/$id', data: data);
      return Lease.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update lease: $e');
    }
  }

  Future<void> delete(int id) async {
    try {
      await _apiClient.delete('/leases/$id');
    } catch (e) {
      throw Exception('Failed to delete lease: $e');
    }
  }
}
