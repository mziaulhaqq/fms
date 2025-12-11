import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/lease.dart';

class SiteContextProvider extends ChangeNotifier {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  Lease? _selectedLease;
  Map<String, dynamic>? _selectedSite;
  
  Lease? get selectedLease => _selectedLease;
  Map<String, dynamic>? get selectedSite => _selectedSite;
  
  int? get selectedLeaseId => _selectedLease?.id;
  int? get selectedSiteId => _selectedSite?['id'] as int?;
  
  String get selectedLeaseName => _selectedLease?.leaseName ?? 'No Lease Selected';
  String get selectedSiteName => _selectedSite?['name'] as String? ?? 'No Site Selected';
  
  bool get hasSelection => _selectedLease != null && _selectedSite != null;
  bool get hasLeaseSelection => _selectedLease != null;
  bool get hasSiteSelection => _selectedSite != null;

  // Initialize from storage on app start
  Future<void> initialize() async {
    try {
      final leaseId = await _secureStorage.read(key: 'selected_lease_id');
      final leaseName = await _secureStorage.read(key: 'selected_lease_name');
      final leaseLocation = await _secureStorage.read(key: 'selected_lease_location');
      
      final siteId = await _secureStorage.read(key: 'selected_site_id');
      final siteName = await _secureStorage.read(key: 'selected_site_name');
      final siteLocation = await _secureStorage.read(key: 'selected_site_location');
      
      if (leaseId != null && leaseName != null) {
        _selectedLease = Lease(
          id: int.parse(leaseId),
          leaseName: leaseName,
          location: leaseLocation,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          createdById: 0,
        );
      }
      
      if (siteId != null && siteName != null) {
        _selectedSite = {
          'id': int.parse(siteId),
          'name': siteName,
          'location': siteLocation,
        };
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing site context: $e');
    }
  }

  // Set selected lease
  Future<void> setLease(Lease? lease) async {
    _selectedLease = lease;
    
    if (lease != null) {
      await _secureStorage.write(key: 'selected_lease_id', value: lease.id.toString());
      await _secureStorage.write(key: 'selected_lease_name', value: lease.leaseName);
      await _secureStorage.write(key: 'selected_lease_location', value: lease.location ?? '');
    } else {
      await _secureStorage.delete(key: 'selected_lease_id');
      await _secureStorage.delete(key: 'selected_lease_name');
      await _secureStorage.delete(key: 'selected_lease_location');
    }
    
    notifyListeners();
  }

  // Set selected site
  Future<void> setSite(Map<String, dynamic>? site) async {
    _selectedSite = site;
    
    if (site != null) {
      await _secureStorage.write(key: 'selected_site_id', value: site['id'].toString());
      await _secureStorage.write(key: 'selected_site_name', value: site['name'] as String);
      await _secureStorage.write(key: 'selected_site_location', value: site['location'] as String? ?? '');
    } else {
      await _secureStorage.delete(key: 'selected_site_id');
      await _secureStorage.delete(key: 'selected_site_name');
      await _secureStorage.delete(key: 'selected_site_location');
    }
    
    notifyListeners();
  }

  // Set both lease and site
  Future<void> setContext({Lease? lease, Map<String, dynamic>? site}) async {
    await setLease(lease);
    await setSite(site);
  }

  // Clear selection
  Future<void> clearSelection() async {
    _selectedLease = null;
    _selectedSite = null;
    
    await _secureStorage.delete(key: 'selected_lease_id');
    await _secureStorage.delete(key: 'selected_lease_name');
    await _secureStorage.delete(key: 'selected_lease_location');
    await _secureStorage.delete(key: 'selected_site_id');
    await _secureStorage.delete(key: 'selected_site_name');
    await _secureStorage.delete(key: 'selected_site_location');
    
    notifyListeners();
  }

  // Get display text for UI
  String getContextDisplay() {
    if (!hasSelection) return 'Select Lease & Site';
    return '$selectedLeaseName / $selectedSiteName';
  }
}
