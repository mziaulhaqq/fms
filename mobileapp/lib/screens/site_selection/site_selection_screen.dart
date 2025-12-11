import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/lease.dart';
import '../../services/lease_service.dart';
import '../../services/mining_site_service.dart';
import '../../providers/site_context_provider.dart';

class SiteSelectionScreen extends StatefulWidget {
  const SiteSelectionScreen({Key? key}) : super(key: key);

  @override
  State<SiteSelectionScreen> createState() => _SiteSelectionScreenState();
}

class _SiteSelectionScreenState extends State<SiteSelectionScreen> {
  final LeaseService _leaseService = LeaseService();
  final MiningSiteService _siteService = MiningSiteService();

  List<Lease> _leases = [];
  List<Map<String, dynamic>> _sites = [];
  
  Lease? _selectedLease;
  Map<String, dynamic>? _selectedSite;
  
  bool _isLoadingLeases = true;
  bool _isLoadingSites = false;

  @override
  void initState() {
    super.initState();
    _loadLeases();
  }

  Future<void> _loadLeases() async {
    try {
      final leases = await _leaseService.getActive();
      setState(() {
        _leases = leases;
        _isLoadingLeases = false;
      });
    } catch (e) {
      setState(() => _isLoadingLeases = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading leases: $e')),
        );
      }
    }
  }

  Future<void> _loadSitesForLease(int leaseId) async {
    setState(() => _isLoadingSites = true);
    
    try {
      final allSites = await _siteService.getMiningSites();
      final filteredSites = allSites
          .where((site) => site['leaseId'] == leaseId)
          .toList();
      
      setState(() {
        _sites = filteredSites;
        _isLoadingSites = false;
        _selectedSite = null; // Reset site selection when lease changes
      });
    } catch (e) {
      setState(() => _isLoadingSites = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading sites: $e')),
        );
      }
    }
  }

  void _saveSelection() {
    if (_selectedLease == null || _selectedSite == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both lease and site'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Save to provider
    final provider = Provider.of<SiteContextProvider>(context, listen: false);
    provider.setContext(lease: _selectedLease, site: _selectedSite);

    // Navigate to dashboard
    Navigator.pushReplacementNamed(context, '/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Lease & Site'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
      ),
      body: _isLoadingLeases
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  const Icon(
                    Icons.location_on,
                    size: 64,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Choose Your Work Context',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Select a lease and mining site to view related data',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Lease Selection
                  const Text(
                    'Select Lease',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_leases.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              size: 48,
                              color: AppColors.warning,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'No leases available',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Please contact admin to create leases',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ..._leases.map((lease) {
                      final isSelected = _selectedLease?.id == lease.id;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        color: isSelected ? AppColors.primary.withOpacity(0.1) : null,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isSelected
                                ? AppColors.primary
                                : AppColors.primary.withOpacity(0.2),
                            child: Icon(
                              Icons.description,
                              color: isSelected ? Colors.white : AppColors.primary,
                            ),
                          ),
                          title: Text(
                            lease.leaseName,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? AppColors.primary : AppColors.textPrimary,
                            ),
                          ),
                          subtitle: lease.location != null
                              ? Text(lease.location!)
                              : null,
                          trailing: isSelected
                              ? const Icon(Icons.check_circle, color: AppColors.success)
                              : null,
                          onTap: () {
                            setState(() {
                              _selectedLease = lease;
                              _selectedSite = null;
                            });
                            _loadSitesForLease(lease.id);
                          },
                        ),
                      );
                    }).toList(),

                  const SizedBox(height: 24),

                  // Site Selection
                  if (_selectedLease != null) ...[
                    const Text(
                      'Select Mining Site',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_isLoadingSites)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (_sites.isEmpty)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.warning_amber_outlined,
                                size: 48,
                                color: AppColors.warning,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'No sites for this lease',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Please create a mining site for this lease',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ..._sites.map((site) {
                        final isSelected = _selectedSite?['id'] == site['id'];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          color: isSelected ? AppColors.success.withOpacity(0.1) : null,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isSelected
                                  ? AppColors.success
                                  : AppColors.success.withOpacity(0.2),
                              child: Icon(
                                Icons.location_on,
                                color: isSelected ? Colors.white : AppColors.success,
                              ),
                            ),
                            title: Text(
                              site['name'] as String,
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? AppColors.success : AppColors.textPrimary,
                              ),
                            ),
                            subtitle: site['location'] != null
                                ? Text(site['location'] as String)
                                : null,
                            trailing: isSelected
                                ? const Icon(Icons.check_circle, color: AppColors.success)
                                : null,
                            onTap: () {
                              setState(() => _selectedSite = site);
                            },
                          ),
                        );
                      }).toList(),
                  ],

                  const SizedBox(height: 32),

                  // Continue Button
                  ElevatedButton(
                    onPressed: (_selectedLease != null && _selectedSite != null)
                        ? _saveSelection
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textOnPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      disabledBackgroundColor: AppColors.textSecondary,
                    ),
                    child: const Text(
                      'Continue to Dashboard',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Skip Button (for admins who might not need context)
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/dashboard');
                    },
                    child: const Text(
                      'Skip for now',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
