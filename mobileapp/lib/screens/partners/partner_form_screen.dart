import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/partner.dart';
import '../../models/mining_site.dart';
import '../../models/lease.dart';
import '../../services/partner_service.dart';
import '../../services/mining_site_service.dart';
import '../../services/lease_service.dart';
import '../../providers/site_context_provider.dart';

class PartnerFormScreen extends StatefulWidget {
  final Partner? partner;

  const PartnerFormScreen({super.key, this.partner});

  @override
  State<PartnerFormScreen> createState() => _PartnerFormScreenState();
}

class _PartnerFormScreenState extends State<PartnerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _partnerService = PartnerService();
  final _miningSiteService = MiningSiteService();
  final _leaseService = LeaseService();
  bool _isLoading = false;
  bool _isLoadingData = true;
  List<MiningSite> _miningSites = [];
  List<Lease> _leases = [];

  late TextEditingController _nameController;
  late TextEditingController _cnicController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _sharePercentageController;
  int? _selectedLeaseId;
  int? _selectedMineId;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    
    // Get site context
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final siteContext = Provider.of<SiteContextProvider>(context, listen: false);
      if (siteContext.selectedLeaseId != null && _selectedLeaseId == null) {
        setState(() {
          _selectedLeaseId = siteContext.selectedLeaseId;
        });
      }
      if (siteContext.selectedSiteId != null && _selectedMineId == null) {
        setState(() {
          _selectedMineId = siteContext.selectedSiteId;
        });
      }
    });
    
    _nameController = TextEditingController(text: widget.partner?.name ?? '');
    _cnicController = TextEditingController(text: widget.partner?.cnic ?? '');
    _emailController = TextEditingController(text: widget.partner?.email ?? '');
    _phoneController = TextEditingController(text: widget.partner?.phone ?? '');
    _addressController = TextEditingController(text: widget.partner?.address ?? '');
    _sharePercentageController = TextEditingController(
      text: widget.partner?.sharePercentage?.toString() ?? '',
    );
    _selectedLeaseId = widget.partner?.leaseId;
    _selectedMineId = widget.partner?.miningSiteId;
    _isActive = widget.partner?.isActive ?? true;
    _loadData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cnicController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _sharePercentageController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final sites = await _miningSiteService.getAllMiningSites();
      final leases = await _leaseService.getActive();
      setState(() {
        _miningSites = sites;
        _leases = leases;
        _isLoadingData = false;
      });
    } catch (e) {
      setState(() => _isLoadingData = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load data: $e', style: const TextStyle(fontSize: 13)),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final partner = Partner(
          id: widget.partner?.id ?? 0,
          name: _nameController.text,
          cnic: _cnicController.text,
          email: _emailController.text.isEmpty ? null : _emailController.text,
          phone: _phoneController.text.isEmpty ? null : _phoneController.text,
          address: _addressController.text.isEmpty ? null : _addressController.text,
          sharePercentage: _sharePercentageController.text.isEmpty
              ? null
              : double.tryParse(_sharePercentageController.text),
          leaseId: _selectedLeaseId,
          miningSiteId: _selectedMineId,
          isActive: _isActive,
          createdAt: widget.partner?.createdAt ?? DateTime.now(),
          updatedAt: DateTime.now(),
        );

        if (widget.partner?.id != null) {
          await _partnerService.updatePartner(widget.partner!.id, partner);
        } else {
          await _partnerService.createPartner(partner);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.partner != null
                    ? 'Partner updated successfully'
                    : 'Partner created successfully',
                style: const TextStyle(fontSize: 13),
              ),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e', style: const TextStyle(fontSize: 13)),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.partner != null ? 'Edit Partner' : 'New Partner',
          style: const TextStyle(fontSize: 18),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(14),
          children: [
            // Name
            TextFormField(
              controller: _nameController,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                labelText: 'Partner Name *',
                labelStyle: const TextStyle(fontSize: 13),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Partner name is required' : null,
            ),
            const SizedBox(height: 14),

            // CNIC
            TextFormField(
              controller: _cnicController,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                labelText: 'CNIC *',
                labelStyle: const TextStyle(fontSize: 13),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'CNIC is required' : null,
            ),
            const SizedBox(height: 14),

            // Email
            TextFormField(
              controller: _emailController,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: const TextStyle(fontSize: 13),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 14),

            // Phone
            TextFormField(
              controller: _phoneController,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                labelText: 'Phone',
                labelStyle: const TextStyle(fontSize: 13),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 14),

            // Address
            TextFormField(
              controller: _addressController,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                labelText: 'Address',
                labelStyle: const TextStyle(fontSize: 13),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 14),

            // Share Percentage
            TextFormField(
              controller: _sharePercentageController,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                labelText: 'Share Percentage (%)',
                labelStyle: const TextStyle(fontSize: 13),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final percentage = double.tryParse(value);
                  if (percentage == null) {
                    return 'Please enter a valid number';
                  }
                  if (percentage < 0 || percentage > 100) {
                    return 'Percentage must be between 0 and 100';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 14),

            // Lease Dropdown
            _isLoadingData
                ? const Center(child: CircularProgressIndicator())
                : DropdownButtonFormField<int>(
                    value: _selectedLeaseId,
                    style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Lease',
                      labelStyle: const TextStyle(fontSize: 13),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      filled: true,
                      fillColor: AppColors.surface,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    items: [
                      const DropdownMenuItem<int>(
                        value: null,
                        child: Text('Select Lease', style: TextStyle(fontSize: 14)),
                      ),
                      ..._leases.map((lease) => DropdownMenuItem<int>(
                            value: lease.id,
                            child: Text(lease.leaseName, style: const TextStyle(fontSize: 14)),
                          )),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedLeaseId = value;
                        // Reset mine selection when lease changes
                        _selectedMineId = null;
                      });
                    },
                  ),
            const SizedBox(height: 14),

            // Mining Site Dropdown (filtered by lease)
            _isLoadingData
                ? const Center(child: CircularProgressIndicator())
                : DropdownButtonFormField<int>(
                    value: _selectedMineId,
                    style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Mining Site',
                      labelStyle: const TextStyle(fontSize: 13),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      filled: true,
                      fillColor: AppColors.surface,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    items: [
                      const DropdownMenuItem<int>(
                        value: null,
                        child: Text('Select Mining Site', style: TextStyle(fontSize: 14)),
                      ),
                      ..._miningSites
                          .where((site) => _selectedLeaseId == null || site.leaseId == _selectedLeaseId)
                          .map((site) => DropdownMenuItem<int>(
                                value: site.id,
                                child: Text(site.name, style: const TextStyle(fontSize: 14)),
                              )),
                    ],
                    onChanged: (value) => setState(() => _selectedMineId = value),
                  ),
            const SizedBox(height: 14),

            // Active Switch
            SwitchListTile(
              title: const Text('Active', style: TextStyle(fontSize: 14)),
              value: _isActive,
              onChanged: (value) => setState(() => _isActive = value),
              activeColor: AppColors.success,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: AppColors.border),
              ),
              tileColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            ),
            const SizedBox(height: 20),

            // Submit Button
            ElevatedButton(
              onPressed: _isLoading ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.textOnPrimary,
                        ),
                      ),
                    )
                  : Text(
                      widget.partner != null ? 'Update Partner' : 'Create Partner',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
