import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/receivable.dart';
import '../../services/receivable_service.dart';
import '../../services/client_service.dart';
import '../../services/mining_site_service.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/site_context_provider.dart';

class ReceivableFormScreen extends StatefulWidget {
  final Receivable? receivable;

  const ReceivableFormScreen({Key? key, this.receivable}) : super(key: key);

  @override
  State<ReceivableFormScreen> createState() => _ReceivableFormScreenState();
}

class _ReceivableFormScreenState extends State<ReceivableFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ReceivableService _service = ReceivableService();
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
      text: widget.receivable?.totalAmount.toString() ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.receivable?.description ?? '',
    );
    _clientId = widget.receivable?.clientId;
    _miningSiteId = widget.receivable?.miningSiteId;
    _selectedDate = widget.receivable?.date ?? DateTime.now();
    _loadDropdownData();
    
    // Auto-populate mining site from context if creating new receivable
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final siteContext = Provider.of<SiteContextProvider>(context, listen: false);
      if (widget.receivable == null && siteContext.selectedSiteId != null) {
        setState(() {
          _miningSiteId = siteContext.selectedSiteId;
        });
      }
    });
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
      'clientId': _clientId,
      'miningSiteId': _miningSiteId,
      'date': _selectedDate.toIso8601String().split('T')[0],
      'description': _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      'totalAmount': double.parse(_amountController.text),
    };

    try {
      if (widget.receivable == null) {
        await _service.create(data);
      } else {
        await _service.update(widget.receivable!.id, data);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.receivable == null
                ? 'Receivable created successfully'
                : 'Receivable updated successfully'),
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
        title: Text(widget.receivable == null
            ? 'Add Receivable (Client Debt)'
            : 'Edit Receivable'),
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
                    color: Colors.green.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.green.shade700),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Record money that client owes to you',
                              style: TextStyle(
                                color: Colors.green.shade700,
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
                  // Mining Site Dropdown (Read-only - from context)
                  DropdownButtonFormField<int>(
                    value: _miningSiteId,
                    decoration: const InputDecoration(
                      labelText: 'Mining Site *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.landscape),
                      filled: true,
                      fillColor: Color(0xFFF5F5F5),
                    ),
                    items: _miningSites.map((site) {
                      return DropdownMenuItem<int>(
                        value: site['id'] as int,
                        child: Text((site['name'] as String?) ?? 'Unknown Site'),
                      );
                    }).toList(),
                    onChanged: null, // Read-only - site is selected from context
                    disabledHint: _miningSiteId != null && _miningSites.isNotEmpty
                        ? Text(_miningSites.firstWhere((s) => s['id'] == _miningSiteId)['name'] as String)
                        : const Text('No site selected'),
                    validator: (value) {
                      if (value == null) return 'Please select a mining site';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
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
                      hintText: 'e.g., 100 tons coal delivery',
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
                      widget.receivable == null ? 'Create' : 'Update',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
