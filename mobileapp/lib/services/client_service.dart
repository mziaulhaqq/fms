import '../core/api/api_client.dart';
import '../core/constants/api_config.dart';
import '../models/client.dart';

class ClientService {
  final ApiClient _apiClient = ApiClient();

  // Get all clients
  Future<List<Client>> getClients() async {
    try {
      final response = await _apiClient.get(ApiConfig.clients);
      final List<dynamic> data = response.data;
      return data.map((json) => Client.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load clients: $e');
    }
  }

  // Alias for consistency with other services
  Future<List<Client>> getAllClients() => getClients();

  // Get client by ID
  Future<Client> getClientById(int id) async {
    try {
      final response = await _apiClient.get('${ApiConfig.clients}/$id');
      return Client.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load client: $e');
    }
  }

  // Create client
  Future<Client> createClient(Client client) async {
    try {
      final response = await _apiClient.post(
        ApiConfig.clients,
        data: client.toJson(),
      );
      return Client.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create client: $e');
    }
  }

  // Update client
  Future<Client> updateClient(int id, Client client) async {
    try {
      final response = await _apiClient.patch(
        '${ApiConfig.clients}/$id',
        data: client.toJson(),
      );
      return Client.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update client: $e');
    }
  }

  // Delete client
  Future<void> deleteClient(int id) async {
    try {
      await _apiClient.delete('${ApiConfig.clients}/$id');
    } catch (e) {
      throw Exception('Failed to delete client: $e');
    }
  }
}
