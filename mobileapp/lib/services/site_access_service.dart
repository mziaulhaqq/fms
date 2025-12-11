import '../core/api/api_client.dart';

class SiteAccessService {
  final _apiClient = ApiClient();

  /// Get all sites that a user has access to
  Future<List<Map<String, dynamic>>> getUserAccessibleSites(int userId) async {
    try {
      final response = await _apiClient.get(
        '/site-supervisors/user/$userId/sites',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((item) => item as Map<String, dynamic>).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching user accessible sites: $e');
      return [];
    }
  }

  /// Check if user has access to a specific site
  Future<bool> hasAccessToSite(int userId, int siteId, List<Map<String, dynamic>>? accessibleSites) async {
    try {
      // If we already have the accessible sites list, check it
      if (accessibleSites != null) {
        return accessibleSites.any((s) => s['siteId'] == siteId);
      }

      // Otherwise, fetch from API
      final sites = await getUserAccessibleSites(userId);
      return sites.any((s) => s['siteId'] == siteId);
    } catch (e) {
      print('Error checking site access: $e');
      return false;
    }
  }
}
