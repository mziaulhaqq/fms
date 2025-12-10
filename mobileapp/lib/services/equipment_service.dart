import '../core/api/api_client.dart';
import '../core/constants/api_config.dart';
import '../models/equipment.dart';

class EquipmentService {
  final ApiClient _apiClient = ApiClient();

  Future<List<EquipmentModel>> getEquipment() async {
    try {
      final response = await _apiClient.get(ApiConfig.equipment);
      final List<dynamic> data = response.data;
      return data.map((json) => EquipmentModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load equipment: $e');
    }
  }

  Future<EquipmentModel> getEquipmentById(int id) async {
    try {
      final response = await _apiClient.get('${ApiConfig.equipment}/$id');
      return EquipmentModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load equipment: $e');
    }
  }

  Future<EquipmentModel> createEquipment(EquipmentModel equipment) async {
    try {
      final response = await _apiClient.post(
        ApiConfig.equipment,
        data: equipment.toJsonRequest(),
      );
      return EquipmentModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create equipment: $e');
    }
  }

  Future<EquipmentModel> updateEquipment(int id, EquipmentModel equipment) async {
    try {
      final response = await _apiClient.patch(
        '${ApiConfig.equipment}/$id',
        data: equipment.toJsonRequest(),
      );
      return EquipmentModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update equipment: $e');
    }
  }

  Future<void> deleteEquipment(int id) async {
    try {
      await _apiClient.delete('${ApiConfig.equipment}/$id');
    } catch (e) {
      throw Exception('Failed to delete equipment: $e');
    }
  }
}
