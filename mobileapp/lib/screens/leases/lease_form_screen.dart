import 'package:flutter/material.dart';
import '../../models/lease.dart';
import '../../services/lease_service.dart';

class LeaseFormScreen extends StatefulWidget {
  final Lease? lease;

  const LeaseFormScreen({Key? key, this.lease}) : super(key: key);

  @override
  State<LeaseFormScreen> createState() => _LeaseFormScreenState();
}

class _LeaseFormScreenState extends State<LeaseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final LeaseService _service = LeaseService();
  
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.lease?.leaseName ?? '');
    _locationController =
        TextEditingController(text: widget.lease?.location ?? '');
    _isActive = widget.lease?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final data = {
      'leaseName': _nameController.text.trim(),
      'location': _locationController.text.trim().isEmpty
          ? null
          : _locationController.text.trim(),
      'isActive': _isActive,
    };

    try {
      if (widget.lease == null) {
        await _service.create(data);
      } else {
        await _service.update(widget.lease!.id, data);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.lease == null
                ? 'Lease created successfully'
                : 'Lease updated successfully'),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
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
        title: Text(widget.lease == null ? 'Add Lease' : 'Edit Lease'),
        backgroundColor: Colors.blue,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Lease Name *',
                      hintText: 'e.g., Main Coal Lease',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.label),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a lease name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      labelText: 'Location',
                      hintText: 'Optional location',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Active'),
                    subtitle: const Text('Is this lease active?'),
                    value: _isActive,
                    onChanged: (value) => setState(() => _isActive = value),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      widget.lease == null ? 'Create' : 'Update',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
