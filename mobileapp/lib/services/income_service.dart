import '../core/api/api_client.dart';
import '../core/constants/api_config.dart';
import '../models/income.dart';

class IncomeService {
  final ApiClient _apiClient = ApiClient();

  Future<List<Income>> getIncomes() async {
    try {
      final response = await _apiClient.get(ApiConfig.income);
      final List<dynamic> data = response.data;
      return data.map((json) => Income.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load income records: $e');
    }
  }

  Future<Income> getIncomeById(int id) async {
    try {
      final response = await _apiClient.get('${ApiConfig.income}/$id');
      return Income.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load income record: $e');
    }
  }

  Future<Income> createIncome(Income income) async {
    try {
      final response = await _apiClient.post(
        ApiConfig.income,
        data: income.toJsonRequest(),
      );
      return Income.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create income record: $e');
    }
  }

  Future<Income> updateIncome(int id, Income income) async {
    try {
      final response = await _apiClient.patch(
        '${ApiConfig.income}/$id',
        data: income.toJsonRequest(),
      );
      return Income.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update income record: $e');
    }
  }

  Future<void> deleteIncome(int id) async {
    try {
      await _apiClient.delete('${ApiConfig.income}/$id');
    } catch (e) {
      throw Exception('Failed to delete income record: $e');
    }
  }
}
