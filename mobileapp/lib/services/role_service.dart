import '../core/api/api_client.dart';
import '../models/role.dart';

class RoleService {
  final ApiClient _apiClient = ApiClient();

  // Get all roles
  Future<List<Role>> getRoles() async {
    try {
      final response = await _apiClient.get('/user-roles');
      final List<dynamic> data = response.data;
      return data.map((json) => Role.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load roles: $e');
    }
  }

  // Get user's assigned roles
  Future<List<UserAssignedRole>> getUserRoles(int userId) async {
    try {
      final response = await _apiClient.get('/user-assigned-roles');
      final List<dynamic> data = response.data;
      final allAssignments = data.map((json) => UserAssignedRole.fromJson(json)).toList();
      
      // Filter by userId
      return allAssignments.where((assignment) => assignment.userId == userId).toList();
    } catch (e) {
      throw Exception('Failed to load user roles: $e');
    }
  }

  // Assign role to user
  Future<UserAssignedRole> assignRoleToUser({
    required int userId,
    required int roleId,
  }) async {
    try {
      final response = await _apiClient.post('/user-assigned-roles', data: {
        'userId': userId,
        'roleId': roleId,
        'status': 'active',
      });
      return UserAssignedRole.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to assign role: $e');
    }
  }

  // Update role assignment status
  Future<void> updateRoleAssignment({
    required int assignmentId,
    required String status,
  }) async {
    try {
      await _apiClient.patch('/user-assigned-roles/$assignmentId', data: {
        'status': status,
      });
    } catch (e) {
      throw Exception('Failed to update role assignment: $e');
    }
  }

  // Remove role from user
  Future<void> removeRoleFromUser(int assignmentId) async {
    try {
      await _apiClient.delete('/user-assigned-roles/$assignmentId');
    } catch (e) {
      throw Exception('Failed to remove role: $e');
    }
  }
}
