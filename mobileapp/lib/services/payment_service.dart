import 'package:dio/dio.dart';
import '../core/api/api_client.dart';
import '../models/payment.dart';

class PaymentService {
  final ApiClient _apiClient = ApiClient();

  Future<List<Payment>> getAll({
    int? clientId,
    int? miningSiteId,
    String? type,
  }) async {
    try {
      String url = '/payments';
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
          .map((json) => Payment.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load payments: $e');
    }
  }

  Future<List<Payment>> getByClient(int clientId) async {
    return getAll(clientId: clientId);
  }

  Future<List<Payment>> getByMiningSite(int miningSiteId) async {
    return getAll(miningSiteId: miningSiteId);
  }

  Future<List<Payment>> getPayableDeductions() async {
    return getAll(type: 'Payable Deduction');
  }

  Future<List<Payment>> getReceivablePayments() async {
    return getAll(type: 'Receivable Payment');
  }

  Future<Payment> getById(int id) async {
    try {
      final response = await _apiClient.get('/payments/$id');
      return Payment.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load payment: $e');
    }
  }

  Future<Payment> create(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post('/payments', data: data);
      return Payment.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create payment: $e');
    }
  }

  Future<Payment> update(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.patch('/payments/$id', data: data);
      return Payment.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update payment: $e');
    }
  }

  Future<void> delete(int id) async {
    try {
      await _apiClient.delete('/payments/$id');
    } catch (e) {
      throw Exception('Failed to delete payment: $e');
    }
  }
}
