import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../models/income.dart';
import '../../models/mining_site.dart';
import '../../services/income_service.dart';
import '../../services/mining_site_service.dart';

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

  late TextEditingController _truckNumberController;
  late TextEditingController _driverNameController;
  late TextEditingController _driverPhoneController;
  late TextEditingController _coalPriceController;
  late TextEditingController _companyCommissionController;

  int? _selectedSiteId;
  DateTime? _loadingDate;

  List<MiningSite> _sites = [];
  bool _isLoading = false;
  bool _isLoadingData = true;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
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
    _selectedSiteId = widget.income?.siteId;
    if (widget.income?.loadingDate != null) {
      try {
        _loadingDate = DateTime.parse(widget.income!.loadingDate);
      } catch (e) {
        _loadingDate = null;
      }
    }
    _loadSites();
  }

  @override
  void dispose() {
    _truckNumberController.dispose();
    _driverNameController.dispose();
    _driverPhoneController.dispose();
    _coalPriceController.dispose();
    _companyCommissionController.dispose();
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

    final income = Income(
      id: widget.income?.id,
      siteId: _selectedSiteId!,
      truckNumber: _truckNumberController.text.trim(),
      loadingDate: _loadingDate!.toIso8601String(),
      driverName: _driverNameController.text.trim(),
      driverPhone: _driverPhoneController.text.trim().isEmpty
          ? null
          : _driverPhoneController.text.trim(),
      coalPrice: double.parse(_coalPriceController.text.trim()),
      companyCommission: double.parse(_companyCommissionController.text.trim()),
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
                  // Mining Site Dropdown
                  DropdownButtonFormField<int>(
                    value: _selectedSiteId,
                    decoration: const InputDecoration(
                      labelText: 'Mining Site',
                      hintText: 'Select a mining site',
                      prefixIcon: Icon(Icons.location_on),
                      border: OutlineInputBorder(),
                    ),
                    items: _sites.map((site) {
                      return DropdownMenuItem<int>(
                        value: site.id,
                        child: Text(site.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedSiteId = value);
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a mining site';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

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
                    onChanged: (_) => setState(() {}),
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
