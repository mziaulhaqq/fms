import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../models/expense.dart';
import '../../models/mining_site.dart';
import '../../models/expense_category.dart';
import '../../services/expense_service.dart';
import '../../services/mining_site_service.dart';
import '../../services/expense_category_service.dart';

class ExpenseFormScreen extends StatefulWidget {
  final Expense? expense;

  const ExpenseFormScreen({super.key, this.expense});

  @override
  State<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends State<ExpenseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ExpenseService _expenseService = ExpenseService();
  final MiningSiteService _siteService = MiningSiteService();
  final ExpenseCategoryService _categoryService = ExpenseCategoryService();

  late TextEditingController _amountController;
  late TextEditingController _notesController;
  
  DateTime _selectedDate = DateTime.now();
  int? _selectedSiteId;
  int? _selectedCategoryId;
  
  List<MiningSite> _sites = [];
  List<ExpenseCategory> _categories = [];
  bool _isLoading = false;
  bool _isLoadingData = true;
  bool get _isEditMode => widget.expense != null;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.expense?.amount.toString() ?? '',
    );
    _notesController = TextEditingController(
      text: widget.expense?.notes ?? '',
    );
    
    if (_isEditMode) {
      _selectedSiteId = widget.expense!.siteId;
      _selectedCategoryId = widget.expense!.categoryId;
      try {
        _selectedDate = DateTime.parse(widget.expense!.expenseDate);
      } catch (e) {
        _selectedDate = DateTime.now();
      }
    }
    
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final sites = await _siteService.getMiningSites();
      final categories = await _categoryService.getExpenseCategories();
      setState(() {
        _sites = sites;
        _categories = categories;
        _isLoadingData = false;
      });
    } catch (e) {
      setState(() => _isLoadingData = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSiteId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a mining site')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final expense = Expense(
        id: widget.expense?.id,
        siteId: _selectedSiteId!,
        categoryId: _selectedCategoryId,
        expenseDate: _selectedDate.toIso8601String().split('T')[0],
        amount: double.parse(_amountController.text.trim()),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      if (_isEditMode) {
        await _expenseService.updateExpense(expense.id!, expense);
      } else {
        await _expenseService.createExpense(expense);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditMode
                ? 'Expense updated successfully'
                : 'Expense created successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving expense: $e'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Expense' : 'New Expense'),
      ),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // Header
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.receipt_long,
                              size: 32,
                              color: AppColors.error,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _isEditMode ? 'Edit Expense' : 'New Expense',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  _isEditMode ? 'Update expense details' : 'Record a new expense',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Mining Site Dropdown
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: DropdownButtonFormField<int>(
                        value: _selectedSiteId,
                        decoration: const InputDecoration(
                          labelText: 'Mining Site *',
                          prefixIcon: Icon(Icons.location_on, color: AppColors.secondary),
                          border: OutlineInputBorder(),
                        ),
                        items: _sites.map((site) {
                          return DropdownMenuItem(
                            value: site.id,
                            child: Text(site.name),
                          );
                        }).toList(),
                        onChanged: _isLoading ? null : (value) {
                          setState(() => _selectedSiteId = value);
                        },
                        validator: (value) => value == null ? 'Please select a site' : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Category Dropdown
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: DropdownButtonFormField<int>(
                        value: _selectedCategoryId,
                        decoration: const InputDecoration(
                          labelText: 'Category (Optional)',
                          prefixIcon: Icon(Icons.category, color: AppColors.secondary),
                          border: OutlineInputBorder(),
                        ),
                        items: _categories.map((category) {
                          return DropdownMenuItem(
                            value: category.id,
                            child: Text(category.name),
                          );
                        }).toList(),
                        onChanged: _isLoading ? null : (value) {
                          setState(() => _selectedCategoryId = value);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Date Picker
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: InkWell(
                        onTap: _isLoading ? null : _selectDate,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Expense Date *',
                            prefixIcon: Icon(Icons.calendar_today, color: AppColors.secondary),
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            DateFormat('MMM dd, yyyy').format(_selectedDate),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Amount Field
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextFormField(
                        controller: _amountController,
                        decoration: const InputDecoration(
                          labelText: 'Amount *',
                          prefixIcon: Icon(Icons.attach_money, color: AppColors.secondary),
                          border: OutlineInputBorder(),
                          hintText: '0.00',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Amount is required';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          if (double.parse(value) <= 0) {
                            return 'Amount must be greater than 0';
                          }
                          return null;
                        },
                        enabled: !_isLoading,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Notes Field
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: 'Notes (Optional)',
                          prefixIcon: Icon(Icons.note, color: AppColors.secondary),
                          border: OutlineInputBorder(),
                          hintText: 'Add any additional notes',
                        ),
                        maxLines: 3,
                        enabled: !_isLoading,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isLoading ? null : () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveExpense,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: AppColors.error,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Text(_isEditMode ? 'Update' : 'Create'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
