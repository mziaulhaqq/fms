import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/client.dart';
import '../../services/client_service.dart';
import '../../services/client_type_service.dart';
import '../../providers/site_context_provider.dart';

class ClientFormScreen extends StatefulWidget {
  final Client? client;

  const ClientFormScreen({super.key, this.client});

  @override
  State<ClientFormScreen> createState() => _ClientFormScreenState();
}

class _ClientFormScreenState extends State<ClientFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _clientService = ClientService();
  final _clientTypeService = ClientTypeService();
  bool _isLoading = false;

  late TextEditingController _businessNameController;
  late TextEditingController _ownerNameController;
  late TextEditingController _addressController;
  late TextEditingController _ownerContactController;
  late TextEditingController _munshiNameController;
  late TextEditingController _munshiContactController;
  late TextEditingController _descriptionController;
  bool _isActive = true;
  int? _selectedClientTypeId;
  DateTime? _selectedOnboardingDate;
  
  List<Map<String, dynamic>> _clientTypes = [];
  bool _isLoadingTypes = true;

  @override
  void initState() {
    super.initState();
    _businessNameController = TextEditingController(text: widget.client?.businessName ?? '');
    _ownerNameController = TextEditingController(text: widget.client?.ownerName ?? '');
    _addressController = TextEditingController(text: widget.client?.address ?? '');
    _ownerContactController = TextEditingController(text: widget.client?.ownerContact ?? '');
    _munshiNameController = TextEditingController(text: widget.client?.munshiName ?? '');
    _munshiContactController = TextEditingController(text: widget.client?.munshiContact ?? '');
    _descriptionController = TextEditingController(text: widget.client?.description ?? '');
    _isActive = widget.client?.isActive ?? true;
    _selectedClientTypeId = widget.client?.clientTypeId;
    if (widget.client?.onboardingDate != null) {
      _selectedOnboardingDate = DateTime.tryParse(widget.client!.onboardingDate!);
    }
    _loadClientTypes();
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _ownerNameController.dispose();
    _addressController.dispose();
    _ownerContactController.dispose();
    _munshiNameController.dispose();
    _munshiContactController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadClientTypes() async {
    try {
      final types = await _clientTypeService.getActive();
      setState(() {
        _clientTypes = types.map((type) => {
          'id': type.id,
          'name': type.name,
        }).toList();
        _isLoadingTypes = false;
      });
    } catch (e) {
      setState(() => _isLoadingTypes = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading client types: $e')),
        );
      }
    }
  }

  Future<void> _selectOnboardingDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedOnboardingDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.textOnPrimary,
              surface: AppColors.surface,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedOnboardingDate) {
      setState(() {
        _selectedOnboardingDate = picked;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final siteContext = Provider.of<SiteContextProvider>(context, listen: false);
        
        final client = Client(
          id: widget.client?.id,
          siteId: widget.client?.siteId ?? siteContext.selectedSiteId,
          businessName: _businessNameController.text,
          ownerName: _ownerNameController.text,
          address: _addressController.text.isEmpty ? null : _addressController.text,
          ownerContact: _ownerContactController.text.isEmpty ? null : _ownerContactController.text,
          munshiName: _munshiNameController.text.isEmpty ? null : _munshiNameController.text,
          munshiContact: _munshiContactController.text.isEmpty ? null : _munshiContactController.text,
          description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
          onboardingDate: _selectedOnboardingDate?.toIso8601String().split('T')[0],
          isActive: _isActive,
          clientTypeId: _selectedClientTypeId,
        );

        if (widget.client?.id != null) {
          await _clientService.updateClient(widget.client!.id!, client);
        } else {
          await _clientService.createClient(client);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.client != null
                  ? 'Client updated successfully'
                  : 'Client created successfully'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
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
        title: Text(widget.client != null ? 'Edit Client' : 'New Client'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _businessNameController,
              decoration: InputDecoration(
                labelText: 'Business Name *',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: AppColors.surface,
              ),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Business name is required' : null,
            ),
            const SizedBox(height: 16),
            // Client Type Dropdown
            DropdownButtonFormField<int>(
              value: _selectedClientTypeId,
              decoration: InputDecoration(
                labelText: 'Client Type (Optional)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: AppColors.surface,
              ),
              items: _isLoadingTypes
                  ? []
                  : [
                      const DropdownMenuItem<int>(
                        value: null,
                        child: Text('No Type'),
                      ),
                      ..._clientTypes.map((type) {
                        return DropdownMenuItem<int>(
                          value: type['id'] as int,
                          child: Text(type['name'] as String),
                        );
                      }).toList(),
                    ],
              onChanged: _isLoadingTypes
                  ? null
                  : (value) {
                      setState(() => _selectedClientTypeId = value);
                    },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _ownerNameController,
              decoration: InputDecoration(
                labelText: 'Owner Name *',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: AppColors.surface,
              ),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Owner name is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: AppColors.surface,
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _ownerContactController,
              decoration: InputDecoration(
                labelText: 'Owner Contact',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: AppColors.surface,
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _munshiNameController,
              decoration: InputDecoration(
                labelText: 'Munshi Name',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: AppColors.surface,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _munshiContactController,
              decoration: InputDecoration(
                labelText: 'Munshi Contact',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: AppColors.surface,
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: AppColors.surface,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            // Onboarding Date Picker
            InkWell(
              onTap: _selectOnboardingDate,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Onboarding Date',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  filled: true,
                  fillColor: AppColors.surface,
                  suffixIcon: const Icon(Icons.calendar_today),
                ),
                child: Text(
                  _selectedOnboardingDate != null
                      ? '${_selectedOnboardingDate!.day.toString().padLeft(2, '0')}/${_selectedOnboardingDate!.month.toString().padLeft(2, '0')}/${_selectedOnboardingDate!.year}'
                      : 'Select date',
                  style: TextStyle(
                    color: _selectedOnboardingDate != null 
                        ? Colors.black87 
                        : Colors.grey[600],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Active'),
              value: _isActive,
              onChanged: (value) => setState(() => _isActive = value),
              activeColor: AppColors.success,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: AppColors.border),
              ),
              tileColor: AppColors.surface,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.textOnPrimary,
                        ),
                      ),
                    )
                  : Text(
                      widget.client != null ? 'Update Client' : 'Create Client',
                      style: const TextStyle(
                        fontSize: 16,
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
