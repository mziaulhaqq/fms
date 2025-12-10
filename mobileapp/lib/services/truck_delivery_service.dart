import '../core/api/api_client.dart';
import '../core/constants/api_config.dart';
import '../models/truck_delivery.dart';

class TruckDeliveryService {
  final ApiClient _apiClient = ApiClient();

  Future<List<TruckDelivery>> getTruckDeliveries() async {
    try {
      final response = await _apiClient.get(ApiConfig.truckDeliveries);
      final List<dynamic> data = response.data;
      return data.map((json) => TruckDelivery.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load truck deliveries: $e');
    }
  }

  Future<List<TruckDelivery>> getAllTruckDeliveries() => getTruckDeliveries();

  Future<TruckDelivery> getTruckDeliveryById(int id) async {
    try {
      final response = await _apiClient.get('${ApiConfig.truckDeliveries}/$id');
      return TruckDelivery.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load truck delivery: $e');
    }
  }

  Future<TruckDelivery> createTruckDelivery(TruckDelivery delivery) async {
    try {
      final response = await _apiClient.post(
        ApiConfig.truckDeliveries,
        data: delivery.toJson(),
      );
      return TruckDelivery.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create truck delivery: $e');
    }
  }

  Future<TruckDelivery> updateTruckDelivery(int id, TruckDelivery delivery) async {
    try {
      final response = await _apiClient.patch(
        '${ApiConfig.truckDeliveries}/$id',
        data: delivery.toJson(),
      );
      return TruckDelivery.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update truck delivery: $e');
    }
  }

  Future<void> deleteTruckDelivery(int id) async {
    try {
      await _apiClient.delete('${ApiConfig.truckDeliveries}/$id');
    } catch (e) {
      throw Exception('Failed to delete truck delivery: $e');
    }
  }
}
