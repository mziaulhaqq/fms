import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../models/worker.dart';
import '../../services/worker_service.dart';

class WorkerFormScreen extends StatefulWidget {
  final Worker? worker;

  const WorkerFormScreen({super.key, this.worker});

  @override
  State<WorkerFormScreen> createState() => _WorkerFormScreenState();
}

class _WorkerFormScreenState extends State<WorkerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final WorkerService _workerService = WorkerService();

  late TextEditingController _fullNameController;
  late TextEditingController _employeeIdController;
  late TextEditingController _roleController;
  late TextEditingController _teamController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  
  DateTime _selectedHireDate = DateTime.now();
  String _selectedStatus = 'active';
  bool _isActive = true;
  int? _selectedSupervisorId;
  List<Worker> _allWorkers = [];
  
  bool _isLoading = false;
  bool get _isEditMode => widget.worker != null;

  final List<String> _statusOptions = ['active', 'inactive'];

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.worker?.fullName ?? '');
    _employeeIdController = TextEditingController(text: widget.worker?.employeeId ?? '');
    _roleController = TextEditingController(text: widget.worker?.role ?? '');
    _teamController = TextEditingController(text: widget.worker?.team ?? '');
    _phoneController = TextEditingController(text: widget.worker?.phone ?? '');
    _emailController = TextEditingController(text: widget.worker?.email ?? '');
    
    if (_isEditMode) {
      _selectedStatus = widget.worker!.status;
      _isActive = widget.worker!.isActive;
      _selectedSupervisorId = widget.worker!.supervisorId;
      if (widget.worker!.hireDate != null) {
        try {
          _selectedHireDate = DateTime.parse(widget.worker!.hireDate!);
        } catch (e) {
          _selectedHireDate = DateTime.now();
        }
      }
    }
    
    _loadWorkers();
  }

  Future<void> _loadWorkers() async {
    try {
      final workers = await _workerService.getAllWorkers();
      setState(() {
        // Exclude current worker from supervisor list when editing
        _allWorkers = _isEditMode 
            ? workers.where((w) => w.id != widget.worker!.id).toList()
            : workers;
      });
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedHireDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedHireDate = picked);
    }
  }

  Future<void> _saveWorker() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final worker = Worker(
        id: widget.worker?.id,
        fullName: _fullNameController.text.trim(),
        employeeId: _employeeIdController.text.trim().isEmpty 
            ? null 
            : _employeeIdController.text.trim(),
        role: _roleController.text.trim().isEmpty 
            ? null 
            : _roleController.text.trim(),
        team: _teamController.text.trim().isEmpty 
            ? null 
            : _teamController.text.trim(),
        phone: _phoneController.text.trim().isEmpty 
            ? null 
            : _phoneController.text.trim(),
        email: _emailController.text.trim().isEmpty 
            ? null 
            : _emailController.text.trim(),
        status: _selectedStatus,
        isActive: _isActive,
        hireDate: _selectedHireDate.toIso8601String().split('T')[0],
        supervisorId: _selectedSupervisorId,
      );

      if (_isEditMode) {
        await _workerService.updateWorker(worker.id!, worker);
      } else {
        await _workerService.createWorker(worker);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditMode
                ? 'Worker updated successfully'
                : 'Worker created successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving worker: $e'),
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
          _isEditMode ? 'Edit Worker' : 'New Worker',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            // PERSONAL INFORMATION Section
            const Text(
              'PERSONAL INFORMATION',
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
                  // Full Name
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextFormField(
                      controller: _fullNameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name *',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Full name is required';
                        }
                        return null;
                      },
                      enabled: !_isLoading,
                    ),
                  ),
                  
                  const Divider(height: 1),
                  
                  // Employee ID
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextFormField(
                      controller: _employeeIdController,
                      decoration: const InputDecoration(
                        labelText: 'Employee ID',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      enabled: !_isLoading,
                    ),
                  ),
                  
                  const Divider(height: 1),
                  
                  // Email
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      enabled: !_isLoading,
                    ),
                  ),
                  
                  const Divider(height: 1),
                  
                  // Phone
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      keyboardType: TextInputType.phone,
                      enabled: !_isLoading,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),

            // JOB DETAILS Section
            const Text(
              'JOB DETAILS',
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
                  // Role
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextFormField(
                      controller: _roleController,
                      decoration: const InputDecoration(
                        labelText: 'Role',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      enabled: !_isLoading,
                    ),
                  ),
                  
                  const Divider(height: 1),
                  
                  // Team
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextFormField(
                      controller: _teamController,
                      decoration: const InputDecoration(
                        labelText: 'Team',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      enabled: !_isLoading,
                    ),
                  ),
                  
                  const Divider(height: 1),
                  
                  // Supervised By Dropdown
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: DropdownButtonFormField<int>(
                      value: _selectedSupervisorId,
                      decoration: const InputDecoration(
                        labelText: 'Supervised By',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      hint: const Text('Select Supervisor'),
                      items: [
                        const DropdownMenuItem<int>(
                          value: null,
                          child: Text('None'),
                        ),
                        ..._allWorkers.map((worker) {
                          return DropdownMenuItem<int>(
                            value: worker.id,
                            child: Text(worker.fullName),
                          );
                        }).toList(),
                      ],
                      onChanged: _isLoading ? null : (value) {
                        setState(() => _selectedSupervisorId = value);
                      },
                    ),
                  ),
                  
                  const Divider(height: 1),
                  
                  // Status Dropdown
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: DropdownButtonFormField<String>(
                      value: _selectedStatus,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      items: _statusOptions.map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        );
                      }).toList(),
                      onChanged: _isLoading ? null : (value) {
                        setState(() => _selectedStatus = value!);
                      },
                    ),
                  ),
                  
                  const Divider(height: 1),
                  
                  // Hire Date Picker
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: InkWell(
                      onTap: _isLoading ? null : _selectDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Hire Date',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat('MMM dd, yyyy').format(_selectedHireDate),
                              style: const TextStyle(fontSize: 16),
                            ),
                            const Icon(Icons.calendar_today, size: 20, color: AppColors.textSecondary),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  const Divider(height: 1),
                  
                  // Active Toggle
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Active Status',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Switch(
                          value: _isActive,
                          onChanged: _isLoading ? null : (value) {
                            setState(() => _isActive = value);
                          },
                          activeColor: AppColors.success,
                        ),
                      ],
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
                onPressed: _isLoading ? null : _saveWorker,
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
                        _isEditMode ? 'Update Worker' : 'Save Worker',
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
    _fullNameController.dispose();
    _employeeIdController.dispose();
    _roleController.dispose();
    _teamController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
