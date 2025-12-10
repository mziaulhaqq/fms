import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/client.dart';
import '../../services/client_service.dart';

class ClientFormScreen extends StatefulWidget {
  final Client? client;

  const ClientFormScreen({super.key, this.client});

  @override
  State<ClientFormScreen> createState() => _ClientFormScreenState();
}

class _ClientFormScreenState extends State<ClientFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _clientService = ClientService();
  bool _isLoading = false;

  late TextEditingController _businessNameController;
  late TextEditingController _ownerNameController;
  late TextEditingController _addressController;
  late TextEditingController _ownerContactController;
  late TextEditingController _munshiNameController;
  late TextEditingController _munshiContactController;
  late TextEditingController _descriptionController;
  bool _isActive = true;

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

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final client = Client(
          id: widget.client?.id,
          businessName: _businessNameController.text,
          ownerName: _ownerNameController.text,
          address: _addressController.text.isEmpty ? null : _addressController.text,
          ownerContact: _ownerContactController.text.isEmpty ? null : _ownerContactController.text,
          munshiName: _munshiNameController.text.isEmpty ? null : _munshiNameController.text,
          munshiContact: _munshiContactController.text.isEmpty ? null : _munshiContactController.text,
          description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
          isActive: _isActive,
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
