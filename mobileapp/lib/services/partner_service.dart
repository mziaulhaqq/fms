import '../core/api/api_client.dart';
import '../core/constants/api_config.dart';
import '../models/partner.dart';

class PartnerService {
  final ApiClient _apiClient = ApiClient();

  // Get all partners
  Future<List<Partner>> getPartners() async {
    try {
      final response = await _apiClient.get(ApiConfig.partners);
      final List<dynamic> data = response.data;
      return data.map((json) => Partner.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load partners: $e');
    }
  }

  // Alias for consistency
  Future<List<Partner>> getAllPartners() => getPartners();

  // Get partner by ID
  Future<Partner> getPartnerById(int id) async {
    try {
      final response = await _apiClient.get('${ApiConfig.partners}/$id');
      return Partner.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load partner: $e');
    }
  }

  // Create partner
  Future<Partner> createPartner(Partner partner) async {
    try {
      final data = partner.toJson();
      // Remove fields that shouldn't be in create DTO
      data.remove('id');
      data.remove('createdAt');
      data.remove('updatedAt');
      
      final response = await _apiClient.post(
        ApiConfig.partners,
        data: data,
      );
      return Partner.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create partner: $e');
    }
  }

  // Update partner
  Future<Partner> updatePartner(int id, Partner partner) async {
    try {
      final data = partner.toJson();
      // Remove fields that shouldn't be in update DTO
      data.remove('id');
      data.remove('createdAt');
      data.remove('updatedAt');
      
      final response = await _apiClient.patch(
        '${ApiConfig.partners}/$id',
        data: data,
      );
      return Partner.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update partner: $e');
    }
  }

  // Delete partner
  Future<void> deletePartner(int id) async {
    try {
      await _apiClient.delete('${ApiConfig.partners}/$id');
    } catch (e) {
      throw Exception('Failed to delete partner: $e');
    }
  }
}
