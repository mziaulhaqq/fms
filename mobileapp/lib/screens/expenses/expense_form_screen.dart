import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../core/constants/app_colors.dart';
import '../../models/expense.dart';
import '../../models/mining_site.dart';
import '../../models/expense_category.dart';
import '../../services/expense_service.dart';
import '../../services/mining_site_service.dart';
import '../../services/expense_category_service.dart';
import '../../services/expense_type_service.dart';
import '../../providers/site_context_provider.dart';

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
  final ExpenseTypeService _expenseTypeService = ExpenseTypeService();

  late TextEditingController _amountController;
  late TextEditingController _notesController;
  
  DateTime _selectedDate = DateTime.now();
  int? _selectedSiteId;
  int? _selectedCategoryId;
  int? _selectedExpenseTypeId;
  List<XFile> _selectedImages = [];
  final ImagePicker _imagePicker = ImagePicker();
  
  List<MiningSite> _sites = [];
  List<ExpenseCategory> _categories = [];
  List<Map<String, dynamic>> _expenseTypes = [];
  bool _isLoading = false;
  bool _isLoadingData = true;
  bool get _isEditMode => widget.expense != null;

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
    
    _amountController = TextEditingController(
      text: widget.expense?.amount.toString() ?? '',
    );
    _notesController = TextEditingController(
      text: widget.expense?.notes ?? '',
    );
    
    if (_isEditMode) {
      _selectedSiteId = widget.expense!.siteId;
      _selectedCategoryId = widget.expense!.categoryId;
      _selectedExpenseTypeId = widget.expense!.expenseTypeId;
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
      final sites = await _siteService.getAllMiningSites();
      final categories = await _categoryService.getExpenseCategories();
      final types = await _expenseTypeService.getActive();
      setState(() {
        _sites = sites;
        _categories = categories;
        _expenseTypes = types.map((type) => {
          'id': type.id,
          'name': type.name,
        }).toList();
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

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() {
          _selectedImages.add(image);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error accessing camera: $e')),
        );
      }
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        imageQuality: 80,
      );
      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error accessing gallery: $e')),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColors.primary),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppColors.primary),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel, color: AppColors.textSecondary),
                title: const Text('Cancel'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
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
      // Get image file paths (no base64 conversion needed)
      List<String> imagePaths = _selectedImages.map((image) => image.path).toList();

      final expense = Expense(
        id: widget.expense?.id,
        siteId: _selectedSiteId!,
        categoryId: _selectedCategoryId,
        expenseTypeId: _selectedExpenseTypeId,
        expenseDate: _selectedDate.toIso8601String().split('T')[0],
        amount: double.parse(_amountController.text.trim()),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        evidencePhotos: null, // Will be set by the server
      );

      if (_isEditMode) {
        await _expenseService.updateExpense(expense.id!, expense, imagePaths);
      } else {
        await _expenseService.createExpense(expense, imagePaths);
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.secondary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEditMode ? 'Edit Expense' : 'New Expense',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20.0),
                children: [
                  // EXPENSE DETAILS Section
                  const Text(
                    'EXPENSE DETAILS',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        // Category Dropdown
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: DropdownButtonFormField<int>(
                            value: _selectedCategoryId,
                            decoration: const InputDecoration(
                              labelText: 'Category',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                        
                        const Divider(height: 1),
                        
                        // Expense Type Dropdown
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: _isLoadingData
                              ? const Center(child: CircularProgressIndicator())
                              : DropdownButtonFormField<int>(
                                  value: _selectedExpenseTypeId,
                                  decoration: const InputDecoration(
                                    labelText: 'Expense Type',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  ),
                                  items: [
                                    const DropdownMenuItem<int>(
                                      value: null,
                                      child: Text('No Type', style: TextStyle(color: AppColors.textSecondary)),
                                    ),
                                    ..._expenseTypes.map((type) {
                                      return DropdownMenuItem<int>(
                                        value: type['id'] as int,
                                        child: Text(type['name'] as String),
                                      );
                                    }).toList(),
                                  ],
                                  onChanged: _isLoading ? null : (value) {
                                    setState(() => _selectedExpenseTypeId = value);
                                  },
                                ),
                        ),
                        
                        const Divider(height: 1),
                        
                        // Amount Field
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: TextFormField(
                            controller: _amountController,
                            decoration: const InputDecoration(
                              labelText: 'Amount',
                              prefixText: '\$ ',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                        
                        const Divider(height: 1),
                        
                        // Date Picker
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: InkWell(
                            onTap: _isLoading ? null : _selectDate,
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Date',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    DateFormat('MMM dd, yyyy').format(_selectedDate),
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const Icon(Icons.calendar_today, size: 20, color: AppColors.textSecondary),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),

                  // ADDITIONAL INFORMATION Section
                  const Text(
                    'ADDITIONAL INFORMATION',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        // Mining Site Dropdown
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: DropdownButtonFormField<int>(
                            value: _selectedSiteId,
                            decoration: const InputDecoration(
                              labelText: 'Project/Site',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                        
                        const Divider(height: 1),
                        
                        // Description/Notes Field
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: TextFormField(
                            controller: _notesController,
                            decoration: const InputDecoration(
                              labelText: 'Description',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              hintText: 'Add description (optional)',
                            ),
                            maxLines: 3,
                            enabled: !_isLoading,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),

                  // RECEIPTS Section
                  const Text(
                    'RECEIPTS',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Display selected images
                        if (_selectedImages.isNotEmpty)
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: List.generate(
                              _selectedImages.length,
                              (index) => Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      File(_selectedImages[index].path),
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () => _removeImage(index),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.error,
                                          shape: BoxShape.circle,
                                        ),
                                        padding: const EdgeInsets.all(4),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        
                        if (_selectedImages.isNotEmpty)
                          const SizedBox(height: 16),
                        
                        // Add receipt button
                        InkWell(
                          onTap: _isLoading ? null : _showImageSourceDialog,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.textSecondary.withOpacity(0.2),
                                style: BorderStyle.solid,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.cloud_upload_outlined,
                                  size: 40,
                                  color: AppColors.textSecondary.withOpacity(0.5),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Add Receipt',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _selectedImages.isEmpty 
                                      ? 'No receipt added yet' 
                                      : '${_selectedImages.length} receipt(s) added',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveExpense,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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
                          : Text(
                              _isEditMode ? 'Update Expense' : 'Save Expense',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
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
