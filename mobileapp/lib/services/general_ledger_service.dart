import 'package:dio/dio.dart';
import '../core/api/api_client.dart';
import '../models/general_ledger.dart';

class GeneralLedgerService {
  final ApiClient _apiClient = ApiClient();

  Future<List<GeneralLedger>> getAll({int? miningSiteId, int? accountTypeId}) async {
    try {
      String url = '/general-ledger';
      Map<String, dynamic> queryParams = {};
      
      if (miningSiteId != null) {
        queryParams['miningSiteId'] = miningSiteId;
      }
      if (accountTypeId != null) {
        queryParams['accountTypeId'] = accountTypeId;
      }

      final response = await _apiClient.get(url, queryParameters: queryParams);
      return (response.data as List)
          .map((json) => GeneralLedger.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load general ledger: $e');
    }
  }

  Future<List<GeneralLedger>> getByMiningSite(int miningSiteId) async {
    return getAll(miningSiteId: miningSiteId);
  }

  Future<List<GeneralLedger>> getByAccountType(int accountTypeId) async {
    return getAll(accountTypeId: accountTypeId);
  }

  Future<GeneralLedger> getById(int id) async {
    try {
      final response = await _apiClient.get('/general-ledger/$id');
      return GeneralLedger.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load general ledger account: $e');
    }
  }

  Future<GeneralLedger> create(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post('/general-ledger', data: data);
      return GeneralLedger.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create general ledger account: $e');
    }
  }

  Future<GeneralLedger> update(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.patch('/general-ledger/$id', data: data);
      return GeneralLedger.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update general ledger account: $e');
    }
  }

  Future<void> delete(int id) async {
    try {
      await _apiClient.delete('/general-ledger/$id');
    } catch (e) {
      throw Exception('Failed to delete general ledger account: $e');
    }
  }
}
