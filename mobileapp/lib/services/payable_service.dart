import 'package:dio/dio.dart';
import '../core/api/api_client.dart';
import '../models/payable.dart';

class PayableService {
  final ApiClient _apiClient = ApiClient();

  Future<List<Payable>> getAll({
    int? clientId,
    int? miningSiteId,
  }) async {
    try {
      String url = '/payables';
      Map<String, dynamic> queryParams = {};
      
      if (clientId != null) {
        queryParams['clientId'] = clientId;
      }
      if (miningSiteId != null) {
        queryParams['miningSiteId'] = miningSiteId;
      }

      final response = await _apiClient.get(url, queryParameters: queryParams);
      return (response.data as List)
          .map((json) => Payable.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load payables: $e');
    }
  }

  Future<List<Payable>> getByClient(int clientId) async {
    return getAll(clientId: clientId);
  }

  Future<List<Payable>> getActiveByClient(int clientId) async {
    try {
      final response = await _apiClient.get('/payables/active/client/$clientId');
      return (response.data as List)
          .map((json) => Payable.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load active payables: $e');
    }
  }

  Future<List<Payable>> getByMiningSite(int miningSiteId) async {
    return getAll(miningSiteId: miningSiteId);
  }

  Future<Payable> getById(int id) async {
    try {
      final response = await _apiClient.get('/payables/$id');
      return Payable.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load payable: $e');
    }
  }

  Future<Payable> create(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post('/payables', data: data);
      return Payable.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create payable: $e');
    }
  }

  Future<Payable> update(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.patch('/payables/$id', data: data);
      return Payable.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update payable: $e');
    }
  }

  Future<void> delete(int id) async {
    try {
      await _apiClient.delete('/payables/$id');
    } catch (e) {
      throw Exception('Failed to delete payable: $e');
    }
  }
}
