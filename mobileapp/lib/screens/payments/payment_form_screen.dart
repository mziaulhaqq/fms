import 'package:flutter/material.dart';
import '../../models/payable.dart';
import '../../models/receivable.dart';
import '../../services/payment_service.dart';
import '../../services/payable_service.dart';
import '../../services/receivable_service.dart';
import '../../services/client_service.dart';
import '../../services/mining_site_service.dart';
import '../../core/constants/app_colors.dart';

class PaymentFormScreen extends StatefulWidget {
  const PaymentFormScreen({Key? key}) : super(key: key);

  @override
  State<PaymentFormScreen> createState() => _PaymentFormScreenState();
}

class _PaymentFormScreenState extends State<PaymentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final PaymentService _paymentService = PaymentService();
  final PayableService _payableService = PayableService();
  final ReceivableService _receivableService = ReceivableService();
  final ClientService _clientService = ClientService();
  final MiningSiteService _siteService = MiningSiteService();

  late TextEditingController _amountController;
  late TextEditingController _receivedByController;
  late TextEditingController _notesController;

  String _paymentType = 'Payable Deduction';
  int? _clientId;
  int? _miningSiteId;
  int? _payableId;
  int? _receivableId;
  String? _paymentMethod;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  
  List<Map<String, dynamic>> _clients = [];
  List<Map<String, dynamic>> _miningSites = [];
  List<Payable> _activePayables = [];
  List<Receivable> _pendingReceivables = [];

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _receivedByController = TextEditingController();
    _notesController = TextEditingController();
    _loadDropdownData();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _receivedByController.dispose();
    _notesController.dispose();
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

  Future<void> _loadPayablesForClient() async {
    if (_clientId == null) return;
    
    try {
      final payables = await _payableService.getActiveByClient(_clientId!);
      setState(() {
        _activePayables = payables;
        _payableId = null; // Reset selection
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading payables: $e')),
        );
      }
    }
  }

  Future<void> _loadReceivablesForClient() async {
    if (_clientId == null) return;
    
    try {
      final receivables = await _receivableService.getPendingByClient(_clientId!);
      setState(() {
        _pendingReceivables = receivables;
        _receivableId = null; // Reset selection
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading receivables: $e')),
        );
      }
    }
  }

  void _onClientChanged(int? clientId) {
    setState(() {
      _clientId = clientId;
      _payableId = null;
      _receivableId = null;
      _activePayables = [];
      _pendingReceivables = [];
    });
    
    if (_paymentType == 'Payable Deduction') {
      _loadPayablesForClient();
    } else {
      _loadReceivablesForClient();
    }
  }

  void _onPaymentTypeChanged(String? type) {
    if (type == null) return;
    
    setState(() {
      _paymentType = type;
      _payableId = null;
      _receivableId = null;
      _activePayables = [];
      _pendingReceivables = [];
      _amountController.clear();
    });
    
    if (_clientId != null) {
      if (type == 'Payable Deduction') {
        _loadPayablesForClient();
      } else {
        _loadReceivablesForClient();
      }
    }
  }

  void _onPayableSelected(int? payableId) {
    setState(() => _payableId = payableId);
    
    if (payableId != null) {
      final payable = _activePayables.firstWhere((p) => p.id == payableId);
      _amountController.text = payable.remainingBalance.toStringAsFixed(2);
    } else {
      _amountController.clear();
    }
  }

  void _onReceivableSelected(int? receivableId) {
    setState(() => _receivableId = receivableId);
    
    if (receivableId != null) {
      final receivable = _pendingReceivables.firstWhere((r) => r.id == receivableId);
      _amountController.text = receivable.remainingBalance.toStringAsFixed(2);
    } else {
      _amountController.clear();
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

    if (_paymentType == 'Payable Deduction' && _payableId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a payable')),
      );
      return;
    }

    if (_paymentType == 'Receivable Payment' && _receivableId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a receivable')),
      );
      return;
    }

    // Validate amount
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    // Validate against remaining balance
    if (_paymentType == 'Payable Deduction') {
      final payable = _activePayables.firstWhere((p) => p.id == _payableId);
      if (amount > payable.remainingBalance) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Amount cannot exceed remaining balance: \$${payable.remainingBalance.toStringAsFixed(2)}',
            ),
          ),
        );
        return;
      }
    } else {
      final receivable = _pendingReceivables.firstWhere((r) => r.id == _receivableId);
      if (amount > receivable.remainingBalance) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Amount cannot exceed remaining balance: \$${receivable.remainingBalance.toStringAsFixed(2)}',
            ),
          ),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    final data = {
      'clientId': _clientId,
      'miningSiteId': _miningSiteId,
      'paymentType': _paymentType,
      'amount': amount,
      'paymentDate': _selectedDate.toIso8601String().split('T')[0],
      'paymentMethod': _paymentMethod,
      'receivedBy': _receivedByController.text.trim().isEmpty
          ? null
          : _receivedByController.text.trim(),
      'notes': _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      if (_paymentType == 'Payable Deduction') 'payableId': _payableId,
      if (_paymentType == 'Receivable Payment') 'receivableId': _receivableId,
    };

    try {
      await _paymentService.create(data);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment recorded successfully')),
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
        title: const Text('Record Payment'),
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
                  // Payment Type Selector
                  DropdownButtonFormField<String>(
                    value: _paymentType,
                    decoration: const InputDecoration(
                      labelText: 'Payment Type *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Payable Deduction',
                        child: Text('Payable Deduction'),
                      ),
                      DropdownMenuItem(
                        value: 'Receivable Payment',
                        child: Text('Receivable Payment'),
                      ),
                    ],
                    onChanged: _onPaymentTypeChanged,
                  ),
                  const SizedBox(height: 16),

                  // Info Card
                  Card(
                    color: _paymentType == 'Payable Deduction'
                        ? Colors.blue.shade50
                        : Colors.green.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: _paymentType == 'Payable Deduction'
                                ? Colors.blue.shade700
                                : Colors.green.shade700,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _paymentType == 'Payable Deduction'
                                  ? 'Deduct from client\'s advance payment'
                                  : 'Record payment received from client',
                              style: TextStyle(
                                color: _paymentType == 'Payable Deduction'
                                    ? Colors.blue.shade700
                                    : Colors.green.shade700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Client
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
                        child: Text((client['clientName'] as String?) ?? 'Unknown'),
                      );
                    }).toList(),
                    onChanged: _onClientChanged,
                    validator: (value) {
                      if (value == null) return 'Please select a client';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Mining Site
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
                        child: Text((site['name'] as String?) ?? 'Unknown'),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _miningSiteId = value),
                    validator: (value) {
                      if (value == null) return 'Please select a mining site';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Payable/Receivable Selector
                  if (_paymentType == 'Payable Deduction')
                    DropdownButtonFormField<int>(
                      value: _payableId,
                      decoration: const InputDecoration(
                        labelText: 'Select Payable *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.account_balance_wallet),
                      ),
                      items: _activePayables.map((payable) {
                        return DropdownMenuItem<int>(
                          value: payable.id,
                          child: Text(
                            '${payable.client?['businessName'] ?? 'Unknown'} - \$${payable.remainingBalance.toStringAsFixed(2)}',
                          ),
                        );
                      }).toList(),
                      onChanged: _onPayableSelected,
                      validator: (value) {
                        if (value == null) return 'Please select a payable';
                        return null;
                      },
                    )
                  else
                    DropdownButtonFormField<int>(
                      value: _receivableId,
                      decoration: const InputDecoration(
                        labelText: 'Select Receivable *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.account_balance),
                      ),
                      items: _pendingReceivables.map((receivable) {
                        return DropdownMenuItem<int>(
                          value: receivable.id,
                          child: Text(
                            '${receivable.client?['businessName'] ?? 'Unknown'} - \$${receivable.remainingBalance.toStringAsFixed(2)}',
                          ),
                        );
                      }).toList(),
                      onChanged: _onReceivableSelected,
                      validator: (value) {
                        if (value == null) return 'Please select a receivable';
                        return null;
                      },
                    ),
                  const SizedBox(height: 16),

                  // Amount
                  TextFormField(
                    controller: _amountController,
                    decoration: const InputDecoration(
                      labelText: 'Amount *',
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

                  // Date
                  InkWell(
                    onTap: _selectDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Payment Date *',
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

                  // Payment Method (for receivable payments)
                  if (_paymentType == 'Receivable Payment')
                    DropdownButtonFormField<String>(
                      value: _paymentMethod,
                      decoration: const InputDecoration(
                        labelText: 'Payment Method',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.payment),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                        DropdownMenuItem(value: 'Bank Transfer', child: Text('Bank Transfer')),
                        DropdownMenuItem(value: 'Check', child: Text('Check')),
                        DropdownMenuItem(value: 'Other', child: Text('Other')),
                      ],
                      onChanged: (value) => setState(() => _paymentMethod = value),
                    ),
                  if (_paymentType == 'Receivable Payment')
                    const SizedBox(height: 16),

                  // Received By (for receivable payments)
                  if (_paymentType == 'Receivable Payment')
                    TextFormField(
                      controller: _receivedByController,
                      decoration: const InputDecoration(
                        labelText: 'Received By',
                        hintText: 'Person who received payment',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                  if (_paymentType == 'Receivable Payment')
                    const SizedBox(height: 16),

                  // Notes
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes',
                      hintText: 'Optional notes',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.note),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),

                  // Submit Button
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textOnPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Record Payment',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
