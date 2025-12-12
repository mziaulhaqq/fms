import 'package:flutter/material.dart';
import '../../models/payable.dart';
import '../../services/payable_service.dart';
import '../../services/client_service.dart';
import '../../services/mining_site_service.dart';
import '../../core/constants/app_colors.dart';

class PayableFormScreen extends StatefulWidget {
  final Payable? payable;

  const PayableFormScreen({Key? key, this.payable}) : super(key: key);

  @override
  State<PayableFormScreen> createState() => _PayableFormScreenState();
}

class _PayableFormScreenState extends State<PayableFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final PayableService _service = PayableService();
  final ClientService _clientService = ClientService();
  final MiningSiteService _siteService = MiningSiteService();

  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  int? _clientId;
  int? _miningSiteId;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  List<Map<String, dynamic>> _clients = [];
  List<Map<String, dynamic>> _miningSites = [];

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.payable?.totalAmount.toString() ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.payable?.description ?? '',
    );
    _clientId = widget.payable?.clientId;
    _miningSiteId = widget.payable?.miningSiteId;
    _selectedDate = widget.payable?.date ?? DateTime.now();
    _loadDropdownData();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadDropdownData() async {
    try {
      final clients = await _clientService.getClientsForDropdown();
      final sites = await _siteService.getMiningSites();
      setState(() {
        _clients = clients;
        _miningSites = sites;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_clientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a client')),
      );
      return;
    }

    if (_miningSiteId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a mining site')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final data = {
      'type': 'Advance Payment', // Always Advance Payment for payables
      'clientId': _clientId,
      'miningSiteId': _miningSiteId,
      'date': _selectedDate.toIso8601String().split('T')[0],
      'description': _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      'totalAmount': double.parse(_amountController.text),
    };

    try {
      if (widget.payable == null) {
        await _service.create(data);
      } else {
        await _service.update(widget.payable!.id, data);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.payable == null
                ? 'Payable created successfully'
                : 'Payable updated successfully'),
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

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.payable == null
            ? 'Add Payable (Advance Payment)'
            : 'Edit Payable'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Info card
                  Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue.shade700),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Record advance payment received from client',
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: _clientId,
                    decoration: const InputDecoration(
                      labelText: 'Client *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    items: _clients.map((client) {
                      return DropdownMenuItem<int>(
                        value: client['id'] as int,
                        child: Text((client['clientName'] as String?) ?? 'Unknown Client'),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _clientId = value),
                    validator: (value) {
                      if (value == null) return 'Please select a client';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: _miningSiteId,
                    decoration: const InputDecoration(
                      labelText: 'Mining Site *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.landscape),
                    ),
                    items: _miningSites.map((site) {
                      return DropdownMenuItem<int>(
                        value: site['id'] as int,
                        child: Text((site['name'] as String?) ?? 'Unknown Site'),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _miningSiteId = value),
                    validator: (value) {
                      if (value == null) return 'Please select a mining site';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Date field with consistent styling
                  InkWell(
                    onTap: _selectDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        _selectedDate.toString().split(' ')[0],
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _amountController,
                    decoration: const InputDecoration(
                      labelText: 'Total Amount *',
                      hintText: '0.00',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter amount';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      if (double.parse(value) <= 0) {
                        return 'Amount must be greater than 0';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Optional description',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textOnPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      widget.payable == null ? 'Create' : 'Update',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
