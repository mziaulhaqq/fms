import 'package:dio/dio.dart';
import '../core/api/api_client.dart';
import '../models/liability.dart';

class LiabilityService {
  final ApiClient _apiClient = ApiClient();

  Future<List<Liability>> getAll({
    int? clientId,
    int? miningSiteId,
    String? type,
  }) async {
    try {
      String url = '/liabilities';
      Map<String, dynamic> queryParams = {};
      
      if (clientId != null) {
        queryParams['clientId'] = clientId;
      }
      if (miningSiteId != null) {
        queryParams['miningSiteId'] = miningSiteId;
      }
      if (type != null) {
        queryParams['type'] = type;
      }

      final response = await _apiClient.get(url, queryParameters: queryParams);
      return (response.data as List)
          .map((json) => Liability.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load liabilities: $e');
    }
  }

  Future<List<Liability>> getByClient(int clientId) async {
    return getAll(clientId: clientId);
  }

  Future<List<Liability>> getActiveByClient(int clientId) async {
    try {
      final response = await _apiClient.get('/liabilities/active/client/$clientId');
      return (response.data as List)
          .map((json) => Liability.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load active liabilities: $e');
    }
  }

  Future<List<Liability>> getByMiningSite(int miningSiteId) async {
    return getAll(miningSiteId: miningSiteId);
  }

  Future<List<Liability>> getLoans() async {
    return getAll(type: 'Loan');
  }

  Future<List<Liability>> getAdvancedPayments() async {
    return getAll(type: 'Advanced Payment');
  }

  Future<Liability> getById(int id) async {
    try {
      final response = await _apiClient.get('/liabilities/$id');
      return Liability.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load liability: $e');
    }
  }

  Future<Liability> create(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post('/liabilities', data: data);
      return Liability.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create liability: $e');
    }
  }

  Future<Liability> update(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.patch('/liabilities/$id', data: data);
      return Liability.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update liability: $e');
    }
  }

  Future<void> delete(int id) async {
    try {
      await _apiClient.delete('/liabilities/$id');
    } catch (e) {
      throw Exception('Failed to delete liability: $e');
    }
  }
}
