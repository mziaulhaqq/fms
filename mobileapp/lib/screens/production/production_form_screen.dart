import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/production.dart';
import '../../models/mining_site.dart';
import '../../services/production_service.dart';
import '../../services/mining_site_service.dart';

class ProductionFormScreen extends StatefulWidget {
  final Production? production;

  const ProductionFormScreen({super.key, this.production});

  @override
  State<ProductionFormScreen> createState() => _ProductionFormScreenState();
}

class _ProductionFormScreenState extends State<ProductionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _productionService = ProductionService();
  final _miningSiteService = MiningSiteService();
  bool _isLoading = false;
  List<MiningSite> _miningSites = [];

  late TextEditingController _quantityController;
  late TextEditingController _qualityController;
  late TextEditingController _notesController;
  DateTime _selectedDate = DateTime.now();
  String? _selectedShift;
  int? _selectedSiteId;

  final List<String> _shifts = ['Morning', 'Evening', 'Night'];

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(
      text: widget.production?.quantity.toString() ?? '',
    );
    _qualityController = TextEditingController(text: widget.production?.quality ?? '');
    _notesController = TextEditingController(text: widget.production?.notes ?? '');
    _selectedDate = widget.production?.date ?? DateTime.now();
    _selectedShift = widget.production?.shift;
    _selectedSiteId = widget.production?.siteId;
    _loadMiningSites();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _qualityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadMiningSites() async {
    try {
      final sites = await _miningSiteService.getAllMiningSites();
      setState(() => _miningSites = sites);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load mining sites: $e', style: const TextStyle(fontSize: 13)),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final production = Production(
          id: widget.production?.id ?? 0,
          date: _selectedDate,
          quantity: double.parse(_quantityController.text),
          quality: _qualityController.text.isEmpty ? null : _qualityController.text,
          shift: _selectedShift,
          notes: _notesController.text.isEmpty ? null : _notesController.text,
          siteId: _selectedSiteId,
          createdAt: widget.production?.createdAt ?? DateTime.now(),
          updatedAt: DateTime.now(),
        );

        if (widget.production?.id != null) {
          await _productionService.updateProduction(widget.production!.id, production);
        } else {
          await _productionService.createProduction(production);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.production != null
                    ? 'Production record updated successfully'
                    : 'Production record created successfully',
                style: const TextStyle(fontSize: 13),
              ),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e', style: const TextStyle(fontSize: 13)),
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
        title: Text(
          widget.production != null ? 'Edit Production' : 'New Production',
          style: const TextStyle(fontSize: 18),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(14),
          children: [
            // Date Picker
            InkWell(
              onTap: () => _selectDate(context),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Date *',
                  labelStyle: const TextStyle(fontSize: 13),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  filled: true,
                  fillColor: AppColors.surface,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  suffixIcon: const Icon(Icons.calendar_today, size: 18),
                ),
                child: Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Quantity
            TextFormField(
              controller: _quantityController,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                labelText: 'Quantity (tons) *',
                labelStyle: const TextStyle(fontSize: 13),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Quantity is required';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),

            // Quality
            TextFormField(
              controller: _qualityController,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                labelText: 'Quality',
                labelStyle: const TextStyle(fontSize: 13),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: 14),

            // Shift Dropdown
            DropdownButtonFormField<String>(
              value: _selectedShift,
              style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText: 'Shift',
                labelStyle: const TextStyle(fontSize: 13),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('Select Shift', style: TextStyle(fontSize: 14)),
                ),
                ..._shifts.map((shift) => DropdownMenuItem<String>(
                      value: shift,
                      child: Text(shift, style: const TextStyle(fontSize: 14)),
                    )),
              ],
              onChanged: (value) => setState(() => _selectedShift = value),
            ),
            const SizedBox(height: 14),

            // Mining Site Dropdown
            DropdownButtonFormField<int>(
              value: _selectedSiteId,
              style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText: 'Mining Site',
                labelStyle: const TextStyle(fontSize: 13),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              items: [
                const DropdownMenuItem<int>(
                  value: null,
                  child: Text('Select Mining Site', style: TextStyle(fontSize: 14)),
                ),
                ..._miningSites.map((site) => DropdownMenuItem<int>(
                      value: site.id,
                      child: Text(site.name, style: const TextStyle(fontSize: 14)),
                    )),
              ],
              onChanged: (value) => setState(() => _selectedSiteId = value),
            ),
            const SizedBox(height: 14),

            // Notes
            TextFormField(
              controller: _notesController,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                labelText: 'Notes',
                labelStyle: const TextStyle(fontSize: 13),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),

            // Submit Button
            ElevatedButton(
              onPressed: _isLoading ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.textOnPrimary,
                        ),
                      ),
                    )
                  : Text(
                      widget.production != null ? 'Update Production' : 'Create Production',
                      style: const TextStyle(
                        fontSize: 15,
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
