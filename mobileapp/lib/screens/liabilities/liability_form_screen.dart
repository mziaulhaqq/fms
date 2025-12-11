import 'package:flutter/material.dart';
import '../../models/liability.dart';
import '../../services/liability_service.dart';
import '../../services/client_service.dart';
import '../../services/mining_site_service.dart';

class LiabilityFormScreen extends StatefulWidget {
  final Liability? liability;

  const LiabilityFormScreen({Key? key, this.liability}) : super(key: key);

  @override
  State<LiabilityFormScreen> createState() => _LiabilityFormScreenState();
}

class _LiabilityFormScreenState extends State<LiabilityFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final LiabilityService _service = LiabilityService();
  final ClientService _clientService = ClientService();
  final MiningSiteService _siteService = MiningSiteService();

  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  String _type = 'Loan';
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
      text: widget.liability?.totalAmount.toString() ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.liability?.description ?? '',
    );
    _type = widget.liability?.type ?? 'Loan';
    _clientId = widget.liability?.clientId;
    _miningSiteId = widget.liability?.miningSiteId;
    _selectedDate = widget.liability?.date ?? DateTime.now();
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
      'type': _type,
      'clientId': _clientId,
      'miningSiteId': _miningSiteId,
      'date': _selectedDate.toIso8601String().split('T')[0],
      'description': _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      'totalAmount': double.parse(_amountController.text),
    };

    try {
      if (widget.liability == null) {
        await _service.create(data);
      } else {
        await _service.update(widget.liability!.id, data);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.liability == null
                ? 'Liability created successfully'
                : 'Liability updated successfully'),
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
        title: Text(widget.liability == null
            ? 'Add Liability'
            : 'Edit Liability'),
        backgroundColor: Colors.blue,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  DropdownButtonFormField<String>(
                    value: _type,
                    decoration: const InputDecoration(
                      labelText: 'Liability Type *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Loan', child: Text('Loan')),
                      DropdownMenuItem(
                        value: 'Advanced Payment',
                        child: Text('Advanced Payment'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) setState(() => _type = value);
                    },
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
                        value: client['id'],
                        child: Text(client['name']),
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
                        value: site['id'],
                        child: Text(site['mineNumber']),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _miningSiteId = value),
                    validator: (value) {
                      if (value == null) return 'Please select a mining site';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Date *'),
                    subtitle: Text(
                      _selectedDate.toString().split(' ')[0],
                      style: const TextStyle(fontSize: 16),
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: _selectDate,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                      side: const BorderSide(color: Colors.grey),
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
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      widget.liability == null ? 'Create' : 'Update',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
