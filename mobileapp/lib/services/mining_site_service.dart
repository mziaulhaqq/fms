import '../core/api/api_client.dart';
import '../core/constants/api_config.dart';
import '../models/mining_site.dart';

class MiningSiteService {
  final ApiClient _apiClient = ApiClient();

  Future<List<MiningSite>> getAllMiningSites() async {
    try {
      final response = await _apiClient.get(ApiConfig.miningSites);
      final List<dynamic> data = response.data;
      return data.map((json) => MiningSite.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load mining sites: $e');
    }
  }

  // Alias for dropdown usage - returns simplified map format
  Future<List<Map<String, dynamic>>> getMiningSites() async {
    try {
      final response = await _apiClient.get(ApiConfig.miningSites);
      final List<dynamic> data = response.data;
      return data.map((json) => {
        'id': json['id'],
        'name': json['name'],
        'leaseId': json['leaseId'],
        'location': json['location'],
        'isActive': json['isActive'],
      }).toList();
    } catch (e) {
      throw Exception('Failed to load mining sites: $e');
    }
  }

  Future<MiningSite> getMiningSiteById(int id) async {
    try {
      final response = await _apiClient.get('${ApiConfig.miningSites}/$id');
      return MiningSite.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load mining site: $e');
    }
  }

  Future<MiningSite> createMiningSite(MiningSite site) async {
    try {
      final response = await _apiClient.post(
        ApiConfig.miningSites,
        data: site.toJsonRequest(),
      );
      return MiningSite.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create mining site: $e');
    }
  }

  Future<MiningSite> updateMiningSite(int id, MiningSite site) async {
    try {
      final response = await _apiClient.patch(
        '${ApiConfig.miningSites}/$id',
        data: site.toJsonRequest(),
      );
      return MiningSite.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update mining site: $e');
    }
  }

  Future<void> deleteMiningSite(int id) async {
    try {
      await _apiClient.delete('${ApiConfig.miningSites}/$id');
    } catch (e) {
      throw Exception('Failed to delete mining site: $e');
    }
  }
}
