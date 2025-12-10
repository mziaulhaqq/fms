import '../core/api/api_client.dart';
import '../core/constants/api_config.dart';
import '../models/expense.dart';

class ExpenseService {
  final ApiClient _apiClient = ApiClient();

  Future<List<Expense>> getExpenses() async {
    try {
      final response = await _apiClient.get(ApiConfig.expenses);
      final List<dynamic> data = response.data;
      return data.map((json) => Expense.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load expenses: $e');
    }
  }

  Future<Expense> getExpenseById(int id) async {
    try {
      final response = await _apiClient.get('${ApiConfig.expenses}/$id');
      return Expense.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load expense: $e');
    }
  }

  Future<Expense> createExpense(Expense expense) async {
    try {
      final response = await _apiClient.post(
        ApiConfig.expenses,
        data: expense.toJsonRequest(),
      );
      return Expense.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create expense: $e');
    }
  }

  Future<Expense> updateExpense(int id, Expense expense) async {
    try {
      final response = await _apiClient.patch(
        '${ApiConfig.expenses}/$id',
        data: expense.toJsonRequest(),
      );
      return Expense.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update expense: $e');
    }
  }

  Future<void> deleteExpense(int id) async {
    try {
      await _apiClient.delete('${ApiConfig.expenses}/$id');
    } catch (e) {
      throw Exception('Failed to delete expense: $e');
    }
  }
}
