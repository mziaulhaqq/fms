import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/mining_site.dart';
import '../../services/mining_site_service.dart';
import '../../services/lease_service.dart';

class MiningSiteFormScreen extends StatefulWidget {
  final MiningSite? miningSite;

  const MiningSiteFormScreen({super.key, this.miningSite});

  @override
  State<MiningSiteFormScreen> createState() => _MiningSiteFormScreenState();
}

class _MiningSiteFormScreenState extends State<MiningSiteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final MiningSiteService _miningSiteService = MiningSiteService();
  final LeaseService _leaseService = LeaseService();

  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _descriptionController;
  late bool _isActive;
  int? _selectedLeaseId;
  
  List<Map<String, dynamic>> _leases = [];
  bool _isLoadingLeases = true;

  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.miningSite != null;
    _nameController = TextEditingController(text: widget.miningSite?.name ?? '');
    _locationController = TextEditingController(text: widget.miningSite?.location ?? '');
    _descriptionController = TextEditingController(text: widget.miningSite?.description ?? '');
    _isActive = widget.miningSite?.isActive ?? true;
    _selectedLeaseId = widget.miningSite?.leaseId;
    _loadLeases();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadLeases() async {
    try {
      final leases = await _leaseService.getActive();
      setState(() {
        _leases = leases.map((lease) => {
          'id': lease.id,
          'leaseName': lease.leaseName,
        }).toList();
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

  Future<void> _saveSite() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final site = MiningSite(
      id: widget.miningSite?.id,
      name: _nameController.text.trim(),
      location: _locationController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      isActive: _isActive,
      leaseId: _selectedLeaseId,
    );

    try {
      if (_isEditing) {
        await _miningSiteService.updateMiningSite(site.id!, site);
      } else {
        await _miningSiteService.createMiningSite(site);
      }
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'Site updated successfully'
                  : 'Site created successfully',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Site' : 'New Site'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Lease Dropdown
            DropdownButtonFormField<int>(
              value: _selectedLeaseId,
              decoration: const InputDecoration(
                labelText: 'Lease (Optional)',
                hintText: 'Select a lease',
                prefixIcon: Icon(Icons.description),
                border: OutlineInputBorder(),
              ),
              items: _isLoadingLeases
                  ? []
                  : [
                      const DropdownMenuItem<int>(
                        value: null,
                        child: Text('No Lease'),
                      ),
                      ..._leases.map((lease) {
                        return DropdownMenuItem<int>(
                          value: lease['id'] as int,
                          child: Text(lease['leaseName'] as String),
                        );
                      }).toList(),
                    ],
              onChanged: _isLoadingLeases
                  ? null
                  : (value) {
                      setState(() => _selectedLeaseId = value);
                    },
            ),
            const SizedBox(height: 16),
            
            // Name Field
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Site Name',
                hintText: 'Enter site name',
                prefixIcon: const Icon(Icons.business),
                suffixIcon: _nameController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _nameController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                border: const OutlineInputBorder(),
                counterText: '${_nameController.text.length}/100',
              ),
              textCapitalization: TextCapitalization.words,
              maxLength: 100,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a site name';
                }
                if (value.trim().length < 2) {
                  return 'Site name must be at least 2 characters';
                }
                return null;
              },
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),

            // Location Field
            TextFormField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: 'Location',
                hintText: 'Enter site location/address',
                prefixIcon: const Icon(Icons.location_on),
                suffixIcon: _locationController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _locationController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                border: const OutlineInputBorder(),
                counterText: '${_locationController.text.length}/200',
              ),
              textCapitalization: TextCapitalization.words,
              maxLength: 200,
              maxLines: 2,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a location';
                }
                return null;
              },
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),

            // Description Field
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'Enter site description',
                prefixIcon: const Icon(Icons.description),
                alignLabelWithHint: true,
                suffixIcon: _descriptionController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _descriptionController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                border: const OutlineInputBorder(),
                counterText: '${_descriptionController.text.length}/500',
              ),
              maxLength: 500,
              maxLines: 4,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),

            // Active Status Switch
            Card(
              child: SwitchListTile(
                value: _isActive,
                onChanged: (value) => setState(() => _isActive = value),
                title: const Text('Active Status'),
                subtitle: Text(_isActive ? 'Site is active' : 'Site is inactive'),
                secondary: Icon(
                  _isActive ? Icons.check_circle : Icons.cancel,
                  color: _isActive ? AppColors.success : AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Live Preview Card
            if (_nameController.text.isNotEmpty || _locationController.text.isNotEmpty) ...[
              const Text(
                'Preview',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        child: Text(
                          _nameController.text.isNotEmpty
                              ? _nameController.text[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _nameController.text.isNotEmpty
                                        ? _nameController.text
                                        : 'Site Name',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _isActive
                                        ? AppColors.success
                                        : AppColors.textSecondary,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _isActive ? 'Active' : 'Inactive',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (_locationController.text.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    size: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      _locationController.text,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textSecondary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            if (_descriptionController.text.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                _descriptionController.text,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Submit Button
            ElevatedButton(
              onPressed: _isLoading ? null : _saveSite,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_isEditing ? 'Update Site' : 'Create Site'),
            ),
          ],
        ),
      ),
    );
  }
}
