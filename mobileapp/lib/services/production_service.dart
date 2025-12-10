import '../core/api/api_client.dart';
import '../core/constants/api_config.dart';
import '../models/production.dart';

class ProductionService {
  final ApiClient _apiClient = ApiClient();

  Future<List<Production>> getProduction() async {
    try {
      final response = await _apiClient.get(ApiConfig.production);
      final List<dynamic> data = response.data;
      return data.map((json) => Production.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load production records: $e');
    }
  }

  Future<List<Production>> getAllProduction() => getProduction();

  Future<Production> getProductionById(int id) async {
    try {
      final response = await _apiClient.get('${ApiConfig.production}/$id');
      return Production.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load production record: $e');
    }
  }

  Future<Production> createProduction(Production production) async {
    try {
      final response = await _apiClient.post(
        ApiConfig.production,
        data: production.toJson(),
      );
      return Production.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create production record: $e');
    }
  }

  Future<Production> updateProduction(int id, Production production) async {
    try {
      final response = await _apiClient.patch(
        '${ApiConfig.production}/$id',
        data: production.toJson(),
      );
      return Production.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update production record: $e');
    }
  }

  Future<void> deleteProduction(int id) async {
    try {
      await _apiClient.delete('${ApiConfig.production}/$id');
    } catch (e) {
      throw Exception('Failed to delete production record: $e');
    }
  }
}
