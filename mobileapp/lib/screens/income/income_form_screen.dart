import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/income.dart';
import '../../models/mining_site.dart';
import '../../models/client.dart';
import '../../models/payable.dart';
import '../../services/income_service.dart';
import '../../services/mining_site_service.dart';
import '../../services/client_service.dart';
import '../../services/payable_service.dart';
import '../../providers/site_context_provider.dart';

class IncomeFormScreen extends StatefulWidget {
  final Income? income;

  const IncomeFormScreen({super.key, this.income});

  @override
  State<IncomeFormScreen> createState() => _IncomeFormScreenState();
}

class _IncomeFormScreenState extends State<IncomeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final IncomeService _incomeService = IncomeService();
  final MiningSiteService _miningSiteService = MiningSiteService();
  final ClientService _clientService = ClientService();
  final PayableService _payableService = PayableService();

  late TextEditingController _truckNumberController;
  late TextEditingController _driverNameController;
  late TextEditingController _driverPhoneController;
  late TextEditingController _coalPriceController;
  late TextEditingController _companyCommissionController;
  late TextEditingController _amountFromPayableController;
  late TextEditingController _amountCashController;

  int? _selectedSiteId;
  int? _selectedClientId;
  int? _selectedPayableId;
  DateTime? _loadingDate;
  double? _selectedPayableBalance;

  List<MiningSite> _sites = [];
  List<Client> _clients = [];
  List<Payable> _payables = [];
  bool _isLoading = false;
  bool _isLoadingData = true;
  bool _isLoadingPayables = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    
    // Get site context
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final siteContext = Provider.of<SiteContextProvider>(context, listen: false);
      if (siteContext.selectedSiteId != null && _selectedSiteId == null) {
        setState(() {
          _selectedSiteId = siteContext.selectedSiteId;
        });
      }
    });
    
    _isEditing = widget.income != null;
    _truckNumberController = TextEditingController(text: widget.income?.truckNumber ?? '');
    _driverNameController = TextEditingController(text: widget.income?.driverName ?? '');
    _driverPhoneController = TextEditingController(text: widget.income?.driverPhone ?? '');
    _coalPriceController = TextEditingController(
      text: widget.income?.coalPrice.toStringAsFixed(2) ?? '',
    );
    _companyCommissionController = TextEditingController(
      text: widget.income?.companyCommission.toStringAsFixed(2) ?? '',
    );
    _amountFromPayableController = TextEditingController(
      text: widget.income?.amountFromLiability?.toStringAsFixed(2) ?? '',
    );
    _amountCashController = TextEditingController(
      text: widget.income?.amountCash?.toStringAsFixed(2) ?? '',
    );
    _selectedSiteId = widget.income?.siteId;
    _selectedClientId = widget.income?.clientId;
    _selectedPayableId = widget.income?.liabilityId;
    if (widget.income?.loadingDate != null) {
      try {
        _loadingDate = DateTime.parse(widget.income!.loadingDate);
      } catch (e) {
        _loadingDate = null;
      }
    }
    _loadInitialData();
  }

  @override
  void dispose() {
    _truckNumberController.dispose();
    _driverNameController.dispose();
    _driverPhoneController.dispose();
    _coalPriceController.dispose();
    _companyCommissionController.dispose();
    _amountFromPayableController.dispose();
    _amountCashController.dispose();
    super.dispose();
  }

  Future<void> _loadSites() async {
    try {
      final sites = await _miningSiteService.getAllMiningSites();
      setState(() {
        _sites = sites.where((s) => s.isActive).toList();
        _isLoadingData = false;
      });
    } catch (e) {
      setState(() => _isLoadingData = false);
    }
  }

  Future<void> _loadClients() async {
    try {
      final clients = await _clientService.getAllClients();
      setState(() {
        _clients = clients;
      });
    } catch (e) {
      // Handle error silently or show message
      print('Error loading clients: $e');
    }
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      _loadSites(),
      _loadClients(),
    ]);
    
    // If editing and has client, load payables
    if (_selectedClientId != null) {
      await _loadPayablesForClient(_selectedClientId!);
    }
  }

  Future<void> _loadPayablesForClient(int clientId) async {
    setState(() => _isLoadingPayables = true);
    try {
      final payables = await _payableService.getActiveByClient(clientId);
      setState(() {
        _payables = payables;
        _isLoadingPayables = false;
      });
    } catch (e) {
      setState(() => _isLoadingPayables = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading payables: $e')),
        );
      }
    }
  }

  void _onClientChanged(int? clientId) {
    setState(() {
      _selectedClientId = clientId;
      _selectedPayableId = null; // Reset payable selection
      _selectedPayableBalance = null;
      _payables = [];
      _amountFromPayableController.clear();
      _amountCashController.clear();
    });
    
    if (clientId != null) {
      _loadPayablesForClient(clientId);
    }
  }

  void _onPayableChanged(int? payableId) {
    setState(() {
      _selectedPayableId = payableId;
      if (payableId != null) {
        final payable = _payables.firstWhere((l) => l.id == payableId);
        _selectedPayableBalance = payable.remainingBalance;
        _calculatePaymentBreakdown();
      } else {
        _selectedPayableBalance = null;
        _amountFromPayableController.clear();
        _amountCashController.clear();
      }
    });
  }

  void _calculatePaymentBreakdown() {
    if (_selectedPayableBalance == null) return;
    
    final coalPrice = double.tryParse(_coalPriceController.text.trim()) ?? 0;
    
    if (coalPrice <= _selectedPayableBalance!) {
      // Full amount can be deducted from payable
      _amountFromPayableController.text = coalPrice.toStringAsFixed(2);
      _amountCashController.text = '0.00';
    } else {
      // Partial from liability, rest in cash
      _amountFromPayableController.text = _selectedPayableBalance!.toStringAsFixed(2);
      _amountCashController.text = (coalPrice - _selectedPayableBalance!).toStringAsFixed(2);
    }
  }

  Future<void> _selectLoadingDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _loadingDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _loadingDate = picked);
    }
  }

  double _calculateNetIncome() {
    final coalPrice = double.tryParse(_coalPriceController.text.trim()) ?? 0;
    final commission = double.tryParse(_companyCommissionController.text.trim()) ?? 0;
    return coalPrice - commission;
  }

  Future<void> _saveIncome() async {
    if (!_formKey.currentState!.validate()) return;

    if (_loadingDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a loading date')),
      );
      return;
    }

    if (_selectedSiteId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a mining site')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Parse payment amounts
    final amountFromLiability = _amountFromPayableController.text.trim().isEmpty
        ? null
        : double.tryParse(_amountFromPayableController.text.trim());
    final amountCash = _amountCashController.text.trim().isEmpty
        ? null
        : double.tryParse(_amountCashController.text.trim());

    final income = Income(
      id: widget.income?.id,
      siteId: _selectedSiteId!,
      clientId: _selectedClientId,
      truckNumber: _truckNumberController.text.trim(),
      loadingDate: _loadingDate!.toIso8601String(),
      driverName: _driverNameController.text.trim(),
      driverPhone: _driverPhoneController.text.trim().isEmpty
          ? null
          : _driverPhoneController.text.trim(),
      coalPrice: double.parse(_coalPriceController.text.trim()),
      companyCommission: double.parse(_companyCommissionController.text.trim()),
      liabilityId: _selectedPayableId,
      amountFromLiability: amountFromLiability,
      amountCash: amountCash,
    );

    try {
      if (_isEditing) {
        await _incomeService.updateIncome(income.id!, income);
      } else {
        await _incomeService.createIncome(income);
      }
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'Income updated successfully'
                  : 'Income created successfully',
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
    final netIncome = _calculateNetIncome();

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Income' : 'New Income'),
      ),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // Mining Site Dropdown (Read-only - from context)
                  DropdownButtonFormField<int>(
                    value: _selectedSiteId,
                    decoration: const InputDecoration(
                      labelText: 'Mining Site',
                      hintText: 'Select a mining site',
                      prefixIcon: Icon(Icons.location_on),
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Color(0xFFF5F5F5),
                    ),
                    items: _sites.map((site) {
                      return DropdownMenuItem<int>(
                        value: site.id,
                        child: Text(site.name),
                      );
                    }).toList(),
                    onChanged: null, // Read-only - site is selected from context
                    disabledHint: _selectedSiteId != null
                        ? Text(_sites.firstWhere((s) => s.id == _selectedSiteId).name)
                        : const Text('No site selected'),
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a mining site';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Client Dropdown
                  DropdownButtonFormField<int>(
                    value: _selectedClientId,
                    decoration: const InputDecoration(
                      labelText: 'Client (Optional)',
                      hintText: 'Select a client',
                      prefixIcon: Icon(Icons.business),
                      border: OutlineInputBorder(),
                    ),
                    items: _clients.map((client) {
                      return DropdownMenuItem<int>(
                        value: client.id,
                        child: Text(client.businessName),
                      );
                    }).toList(),
                    onChanged: _onClientChanged,
                  ),
                  const SizedBox(height: 16),

                  // Payable Dropdown (only show if client is selected)
                  if (_selectedClientId != null) ...[
                    if (_isLoadingPayables)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (_payables.isEmpty)
                      Card(
                        color: Colors.blue.shade50,
                        child: const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.blue),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'No active payables found for this client',
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      DropdownButtonFormField<int>(
                        value: _selectedPayableId,
                        decoration: const InputDecoration(
                          labelText: 'Payable (Optional)',
                          hintText: 'Select payable to deduct',
                          prefixIcon: Icon(Icons.account_balance_wallet),
                          border: OutlineInputBorder(),
                        ),
                        items: _payables.map((payable) {
                          final statusBadge = payable.status == 'Partially Used' 
                              ? '⚠️ Partial' 
                              : '✓ Active';
                          final statusColor = payable.status == 'Partially Used' 
                              ? Colors.orange.shade700 
                              : Colors.green.shade700;
                          return DropdownMenuItem<int>(
                            value: payable.id,
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: '$statusBadge - ${payable.type}\n',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: statusColor,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Balance: \$${payable.remainingBalance.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: _onPayableChanged,
                      ),
                    const SizedBox(height: 16),

                    // Payment Breakdown - Show if payable is selected
                    if (_selectedPayableId != null) ...[
                      Card(
                        color: Colors.purple.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.payment, color: Colors.purple.shade700),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Payment Breakdown',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.purple.shade700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              
                              // Payable Balance Info
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.purple.shade200),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.account_balance_wallet, size: 20, color: Colors.purple.shade600),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Available in Payable:',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      '\$${_selectedPayableBalance?.toStringAsFixed(2) ?? '0.00'}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.purple.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Amount from Payable
                              TextFormField(
                                controller: _amountFromPayableController,
                                decoration: InputDecoration(
                                  labelText: 'Amount from Payable',
                                  hintText: '0.00',
                                  prefixIcon: const Icon(Icons.remove_circle),
                                  border: const OutlineInputBorder(),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                onChanged: (value) {
                                  // Only auto-calculate cash if it's currently empty or zero
                                  final currentCash = _amountCashController.text.trim();
                                  if (currentCash.isEmpty || currentCash == '0.00' || currentCash == '0') {
                                    final coalPrice = double.tryParse(_coalPriceController.text.trim()) ?? 0;
                                    final fromLiability = double.tryParse(value.trim()) ?? 0;
                                    final cashAmount = coalPrice - fromLiability;
                                    _amountCashController.text = cashAmount > 0 ? cashAmount.toStringAsFixed(2) : '0.00';
                                  }
                                  setState(() {});
                                },
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter amount from payable';
                                  }
                                  final amount = double.tryParse(value.trim());
                                  if (amount == null || amount < 0) {
                                    return 'Please enter a valid amount';
                                  }
                                  if (amount > (_selectedPayableBalance ?? 0)) {
                                    return 'Amount exceeds available balance';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),

                              // Amount in Cash
                              TextFormField(
                                controller: _amountCashController,
                                decoration: InputDecoration(
                                  labelText: 'Amount in Cash',
                                  hintText: '0.00',
                                  prefixIcon: const Icon(Icons.attach_money),
                                  border: const OutlineInputBorder(),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                onChanged: (value) {
                                  // Only auto-calculate payable amount if it's currently empty or zero
                                  final currentFromPayable = _amountFromPayableController.text.trim();
                                  if (currentFromPayable.isEmpty || currentFromPayable == '0.00' || currentFromPayable == '0') {
                                    final coalPrice = double.tryParse(_coalPriceController.text.trim()) ?? 0;
                                    final cash = double.tryParse(value.trim()) ?? 0;
                                    
                                    if (coalPrice > 0) {
                                      final fromLiability = coalPrice - cash;
                                      if (fromLiability > 0 && fromLiability <= (_selectedPayableBalance ?? 0)) {
                                        _amountFromPayableController.text = fromLiability.toStringAsFixed(2);
                                      } else if (fromLiability <= 0) {
                                        _amountFromPayableController.text = '0.00';
                                      }
                                    }
                                  }
                                  setState(() {});
                                },
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter cash amount';
                                  }
                                  final amount = double.tryParse(value.trim());
                                  if (amount == null || amount < 0) {
                                    return 'Please enter a valid amount';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),

                              // Total verification
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.green.shade200),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.check_circle, size: 20, color: Colors.green.shade700),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Total Payment: \$${((double.tryParse(_amountFromPayableController.text.trim()) ?? 0) + (double.tryParse(_amountCashController.text.trim()) ?? 0)).toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green.shade700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ],

                  // Truck Number
                  TextFormField(
                    controller: _truckNumberController,
                    decoration: InputDecoration(
                      labelText: 'Truck Number',
                      hintText: 'Enter truck number',
                      prefixIcon: const Icon(Icons.local_shipping),
                      suffixIcon: _truckNumberController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _truckNumberController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter truck number';
                      }
                      return null;
                    },
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 16),

                  // Loading Date
                  InkWell(
                    onTap: _selectLoadingDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Loading Date',
                        prefixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        _loadingDate != null
                            ? '${_loadingDate!.year}-${_loadingDate!.month.toString().padLeft(2, '0')}-${_loadingDate!.day.toString().padLeft(2, '0')}'
                            : 'Select loading date',
                        style: TextStyle(
                          color: _loadingDate != null
                              ? Colors.black
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Driver Information Section
                  const Text(
                    'Driver Information',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Driver Name
                  TextFormField(
                    controller: _driverNameController,
                    decoration: InputDecoration(
                      labelText: 'Driver Name',
                      hintText: 'Enter driver name',
                      prefixIcon: const Icon(Icons.person),
                      suffixIcon: _driverNameController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _driverNameController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                      border: const OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter driver name';
                      }
                      return null;
                    },
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 16),

                  // Driver Phone
                  TextFormField(
                    controller: _driverPhoneController,
                    decoration: InputDecoration(
                      labelText: 'Driver Phone (Optional)',
                      hintText: 'Enter driver phone number',
                      prefixIcon: const Icon(Icons.phone),
                      suffixIcon: _driverPhoneController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _driverPhoneController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 24),

                  // Financial Information Section
                  const Text(
                    'Financial Information',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Coal Price
                  TextFormField(
                    controller: _coalPriceController,
                    decoration: const InputDecoration(
                      labelText: 'Coal Price',
                      hintText: '0.00',
                      prefixIcon: Icon(Icons.attach_money),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                    ],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter coal price';
                      }
                      final price = double.tryParse(value.trim());
                      if (price == null || price <= 0) {
                        return 'Please enter a valid price';
                      }
                      return null;
                    },
                    onChanged: (_) {
                      // Recalculate payment breakdown if liability is selected
                      if (_selectedPayableId != null) {
                        _calculatePaymentBreakdown();
                      }
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 16),

                  // Company Commission
                  TextFormField(
                    controller: _companyCommissionController,
                    decoration: const InputDecoration(
                      labelText: 'Company Commission',
                      hintText: '0.00',
                      prefixIcon: Icon(Icons.remove_circle),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                    ],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter company commission';
                      }
                      final commission = double.tryParse(value.trim());
                      if (commission == null || commission < 0) {
                        return 'Please enter a valid commission';
                      }
                      return null;
                    },
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 16),

                  // Net Income Display
                  if (_coalPriceController.text.isNotEmpty &&
                      _companyCommissionController.text.isNotEmpty) ...[
                    Card(
                      color: AppColors.success.withOpacity(0.1),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.account_balance_wallet,
                              color: AppColors.success,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Net Income',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '\$${netIncome.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.success,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (netIncome > 0)
                              const Icon(
                                Icons.trending_up,
                                color: AppColors.success,
                                size: 32,
                              )
                            else if (netIncome < 0)
                              const Icon(
                                Icons.trending_down,
                                color: AppColors.error,
                                size: 32,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),

                  // Submit Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveIncome,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_isEditing ? 'Update Income' : 'Create Income'),
                  ),
                ],
              ),
            ),
    );
  }
}
