import 'package:dio/dio.dart';
import '../core/api/api_client.dart';
import '../models/receivable.dart';

class ReceivableService {
  final ApiClient _apiClient = ApiClient();

  Future<List<Receivable>> getAll({
    int? clientId,
    int? miningSiteId,
  }) async {
    try {
      String url = '/receivables';
      Map<String, dynamic> queryParams = {};
      
      if (clientId != null) {
        queryParams['clientId'] = clientId;
      }
      if (miningSiteId != null) {
        queryParams['miningSiteId'] = miningSiteId;
      }

      final response = await _apiClient.get(url, queryParameters: queryParams);
      return (response.data as List)
          .map((json) => Receivable.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load receivables: $e');
    }
  }

  Future<List<Receivable>> getByClient(int clientId) async {
    return getAll(clientId: clientId);
  }

  Future<List<Receivable>> getPendingByClient(int clientId) async {
    try {
      final response = await _apiClient.get('/receivables/pending/client/$clientId');
      return (response.data as List)
          .map((json) => Receivable.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load pending receivables: $e');
    }
  }

  Future<List<Receivable>> getByMiningSite(int miningSiteId) async {
    return getAll(miningSiteId: miningSiteId);
  }

  Future<Receivable> getById(int id) async {
    try {
      final response = await _apiClient.get('/receivables/$id');
      return Receivable.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load receivable: $e');
    }
  }

  Future<Receivable> create(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post('/receivables', data: data);
      return Receivable.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create receivable: $e');
    }
  }

  Future<Receivable> update(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.patch('/receivables/$id', data: data);
      return Receivable.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update receivable: $e');
    }
  }

  Future<void> delete(int id) async {
    try {
      await _apiClient.delete('/receivables/$id');
    } catch (e) {
      throw Exception('Failed to delete receivable: $e');
    }
  }
}
