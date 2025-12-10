import '../core/api/api_client.dart';
import '../core/constants/api_config.dart';
import '../models/expense_category.dart';

class ExpenseCategoryService {
  final ApiClient _apiClient = ApiClient();

  Future<List<ExpenseCategory>> getExpenseCategories() async {
    try {
      final response = await _apiClient.get(ApiConfig.expenseCategories);
      final List<dynamic> data = response.data;
      return data.map((json) => ExpenseCategory.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load expense categories: $e');
    }
  }

  Future<ExpenseCategory> getExpenseCategoryById(int id) async {
    try {
      final response = await _apiClient.get('${ApiConfig.expenseCategories}/$id');
      return ExpenseCategory.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load expense category: $e');
    }
  }

  Future<ExpenseCategory> createExpenseCategory(ExpenseCategory category) async {
    try {
      final response = await _apiClient.post(
        ApiConfig.expenseCategories,
        data: category.toJson(),
      );
      return ExpenseCategory.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create expense category: $e');
    }
  }

  Future<ExpenseCategory> updateExpenseCategory(int id, ExpenseCategory category) async {
    try {
      final response = await _apiClient.patch(
        '${ApiConfig.expenseCategories}/$id',
        data: category.toJson(),
      );
      return ExpenseCategory.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update expense category: $e');
    }
  }

  Future<void> deleteExpenseCategory(int id) async {
    try {
      await _apiClient.delete('${ApiConfig.expenseCategories}/$id');
    } catch (e) {
      throw Exception('Failed to delete expense category: $e');
    }
  }
}
