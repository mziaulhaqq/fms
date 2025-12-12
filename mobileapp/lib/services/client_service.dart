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

  // Get clients as simple map for dropdowns
  Future<List<Map<String, dynamic>>> getClientsForDropdown() async {
    try {
      final response = await _apiClient.get(ApiConfig.clients);
      final List<dynamic> data = response.data;
      return data.map((json) => {
        'id': json['id'],
        'clientName': json['businessName'], // Map businessName to clientName for dropdown
      }).toList();
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
      final data = client.toJson();
      // Remove fields that shouldn't be in create DTO
      data.remove('id');
      data.remove('createdAt');
      data.remove('updatedAt');
      data.remove('createdById');
      data.remove('modifiedById');
      
      final response = await _apiClient.post(
        ApiConfig.clients,
        data: data,
      );
      return Client.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create client: $e');
    }
  }

  // Update client
  Future<Client> updateClient(int id, Client client) async {
    try {
      final data = client.toJson();
      // Remove fields that shouldn't be in update DTO
      data.remove('id');
      data.remove('createdAt');
      data.remove('updatedAt');
      data.remove('createdById');
      data.remove('modifiedById');
      
      final response = await _apiClient.patch(
        '${ApiConfig.clients}/$id',
        data: data,
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
