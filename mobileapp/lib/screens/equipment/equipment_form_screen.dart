import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/equipment.dart';
import '../../models/mining_site.dart';
import '../../services/equipment_service.dart';
import '../../services/mining_site_service.dart';
import '../../providers/site_context_provider.dart';

class EquipmentFormScreen extends StatefulWidget {
  final EquipmentModel? equipment;

  const EquipmentFormScreen({super.key, this.equipment});

  @override
  State<EquipmentFormScreen> createState() => _EquipmentFormScreenState();
}

class _EquipmentFormScreenState extends State<EquipmentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final EquipmentService _equipmentService = EquipmentService();
  final MiningSiteService _miningSiteService = MiningSiteService();

  late TextEditingController _nameController;
  late TextEditingController _typeController;
  late TextEditingController _modelController;
  late TextEditingController _serialNumberController;
  late TextEditingController _purchasePriceController;
  late TextEditingController _notesController;

  String _selectedStatus = 'Operational';
  int? _selectedSiteId;
  DateTime? _purchaseDate;

  final List<String> _statusOptions = [
    'Operational',
    'Maintenance',
    'Out of Service',
  ];

  List<MiningSite> _sites = [];
  bool _isLoading = false;
  bool _isLoadingData = true;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.equipment != null;
    _nameController = TextEditingController(text: widget.equipment?.name ?? '');
    _typeController = TextEditingController(text: widget.equipment?.type ?? '');
    _modelController = TextEditingController(text: widget.equipment?.model ?? '');
    _serialNumberController = TextEditingController(text: widget.equipment?.serialNumber ?? '');
    _purchasePriceController = TextEditingController(
      text: widget.equipment?.purchasePrice?.toStringAsFixed(2) ?? '',
    );
    _notesController = TextEditingController(text: widget.equipment?.notes ?? '');
    _selectedStatus = widget.equipment?.status ?? 'Operational';
    
    // Auto-populate siteId from context when creating new equipment
    if (widget.equipment == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final siteContext = Provider.of<SiteContextProvider>(context, listen: false);
        setState(() {
          _selectedSiteId = siteContext.selectedSiteId;
        });
      });
    } else {
      _selectedSiteId = widget.equipment?.siteId;
    }
    
    if (widget.equipment?.purchaseDate != null) {
      try {
        _purchaseDate = DateTime.parse(widget.equipment!.purchaseDate!);
      } catch (e) {
        _purchaseDate = null;
      }
    }
    _loadSites();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _modelController.dispose();
    _serialNumberController.dispose();
    _purchasePriceController.dispose();
    _notesController.dispose();
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

  Future<void> _selectPurchaseDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _purchaseDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _purchaseDate = picked);
    }
  }

  Future<void> _saveEquipment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final equipment = EquipmentModel(
      id: widget.equipment?.id,
      name: _nameController.text.trim(),
      type: _typeController.text.trim().isEmpty ? null : _typeController.text.trim(),
      model: _modelController.text.trim().isEmpty ? null : _modelController.text.trim(),
      serialNumber: _serialNumberController.text.trim().isEmpty
          ? null
          : _serialNumberController.text.trim(),
      purchaseDate: _purchaseDate?.toIso8601String(),
      purchasePrice: _purchasePriceController.text.trim().isEmpty
          ? null
          : double.tryParse(_purchasePriceController.text.trim()),
      status: _selectedStatus,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      siteId: _selectedSiteId,
    );

    try {
      if (_isEditing) {
        await _equipmentService.updateEquipment(equipment.id!, equipment);
      } else {
        await _equipmentService.createEquipment(equipment);
      }
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'Equipment updated successfully'
                  : 'Equipment created successfully',
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
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Equipment' : 'New Equipment'),
      ),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // Name Field
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Equipment Name',
                      hintText: 'Enter equipment name',
                      prefixIcon: const Icon(Icons.build),
                      suffixIcon: _nameController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _nameController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                      border: const OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter equipment name';
                      }
                      return null;
                    },
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 16),

                  // Type and Model in a row
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _typeController,
                          decoration: const InputDecoration(
                            labelText: 'Type (Optional)',
                            hintText: 'e.g., Excavator',
                            prefixIcon: Icon(Icons.category),
                            border: OutlineInputBorder(),
                          ),
                          textCapitalization: TextCapitalization.words,
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _modelController,
                          decoration: const InputDecoration(
                            labelText: 'Model (Optional)',
                            hintText: 'e.g., CAT 320',
                            prefixIcon: Icon(Icons.info),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Serial Number
                  TextFormField(
                    controller: _serialNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Serial Number (Optional)',
                      hintText: 'Enter serial number',
                      prefixIcon: Icon(Icons.tag),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 16),

                  // Status Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      prefixIcon: Icon(Icons.check_circle),
                      border: OutlineInputBorder(),
                    ),
                    items: _statusOptions.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedStatus = value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Mining Site Dropdown (Read-only - from context)
                  DropdownButtonFormField<int>(
                    value: _selectedSiteId,
                    decoration: const InputDecoration(
                      labelText: 'Assigned Site (Optional)',
                      hintText: 'Select a mining site',
                      prefixIcon: Icon(Icons.location_on),
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Color(0xFFF5F5F5),
                    ),
                    items: [
                      const DropdownMenuItem<int>(
                        value: null,
                        child: Text('No site assigned'),
                      ),
                      ..._sites.map((site) {
                        return DropdownMenuItem<int>(
                          value: site.id,
                          child: Text(site.name),
                        );
                      }),
                    ],
                    onChanged: null, // Read-only - site is selected from context
                    disabledHint: _selectedSiteId != null && _sites.isNotEmpty
                        ? Text(_sites.firstWhere((s) => s.id == _selectedSiteId, orElse: () => _sites.first).name)
                        : const Text('No site assigned'),
                  ),
                  const SizedBox(height: 16),

                  // Purchase Date
                  InkWell(
                    onTap: _selectPurchaseDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Purchase Date (Optional)',
                        prefixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        _purchaseDate != null
                            ? '${_purchaseDate!.year}-${_purchaseDate!.month.toString().padLeft(2, '0')}-${_purchaseDate!.day.toString().padLeft(2, '0')}'
                            : 'Select purchase date',
                        style: TextStyle(
                          color: _purchaseDate != null
                              ? Colors.black
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Purchase Price
                  TextFormField(
                    controller: _purchasePriceController,
                    decoration: const InputDecoration(
                      labelText: 'Purchase Price (Optional)',
                      hintText: '0.00',
                      prefixIcon: Icon(Icons.attach_money),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                    ],
                    validator: (value) {
                      if (value != null && value.trim().isNotEmpty) {
                        final price = double.tryParse(value.trim());
                        if (price == null || price < 0) {
                          return 'Please enter a valid price';
                        }
                      }
                      return null;
                    },
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 16),

                  // Notes
                  TextFormField(
                    controller: _notesController,
                    decoration: InputDecoration(
                      labelText: 'Notes (Optional)',
                      hintText: 'Enter any additional notes',
                      prefixIcon: const Icon(Icons.note),
                      alignLabelWithHint: true,
                      suffixIcon: _notesController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _notesController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                      border: const OutlineInputBorder(),
                      counterText: '${_notesController.text.length}/500',
                    ),
                    maxLength: 500,
                    maxLines: 4,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 24),

                  // Submit Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveEquipment,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_isEditing ? 'Update Equipment' : 'Create Equipment'),
                  ),
                ],
              ),
            ),
    );
  }
}
