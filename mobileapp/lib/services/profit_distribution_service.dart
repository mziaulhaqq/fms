import '../core/api/api_client.dart';
import '../core/constants/api_config.dart';
import '../models/profit_distribution.dart';

class ProfitDistributionService {
  final ApiClient _apiClient = ApiClient();

  Future<List<ProfitDistribution>> getProfitDistributions() async {
    try {
      final response = await _apiClient.get(ApiConfig.profitDistributions);
      final List<dynamic> data = response.data;
      return data.map((json) => ProfitDistribution.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load profit distributions: $e');
    }
  }

  Future<List<ProfitDistribution>> getAllProfitDistributions() => getProfitDistributions();

  Future<ProfitDistribution> getProfitDistributionById(int id) async {
    try {
      final response = await _apiClient.get('${ApiConfig.profitDistributions}/$id');
      return ProfitDistribution.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load profit distribution: $e');
    }
  }

  Future<ProfitDistribution> createProfitDistribution(ProfitDistribution distribution) async {
    try {
      final response = await _apiClient.post(
        ApiConfig.profitDistributions,
        data: distribution.toJson(),
      );
      return ProfitDistribution.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create profit distribution: $e');
    }
  }

  Future<ProfitDistribution> updateProfitDistribution(int id, ProfitDistribution distribution) async {
    try {
      final response = await _apiClient.patch(
        '${ApiConfig.profitDistributions}/$id',
        data: distribution.toJson(),
      );
      return ProfitDistribution.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update profit distribution: $e');
    }
  }

  Future<void> deleteProfitDistribution(int id) async {
    try {
      await _apiClient.delete('${ApiConfig.profitDistributions}/$id');
    } catch (e) {
      throw Exception('Failed to delete profit distribution: $e');
    }
  }
}
