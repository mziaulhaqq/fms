import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../models/equipment.dart';
import '../../services/equipment_service.dart';
import 'equipment_form_screen.dart';

class EquipmentDetailScreen extends StatefulWidget {
  final EquipmentModel equipment;

  const EquipmentDetailScreen({super.key, required this.equipment});

  @override
  State<EquipmentDetailScreen> createState() => _EquipmentDetailScreenState();
}

class _EquipmentDetailScreenState extends State<EquipmentDetailScreen> {
  final EquipmentService _equipmentService = EquipmentService();
  late EquipmentModel _equipment;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _equipment = widget.equipment;
  }

  Future<void> _deleteEquipment() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_rounded, color: AppColors.error),
            SizedBox(width: 12),
            Text('Delete Equipment'),
          ],
        ),
        content: Text('Are you sure you want to delete "${_equipment.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        await _equipmentService.deleteEquipment(_equipment.id!);
        if (mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Equipment deleted successfully')),
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
  }

  Future<void> _navigateToEdit() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EquipmentFormScreen(equipment: _equipment),
      ),
    );
    if (result == true && mounted) {
      try {
        final updated = await _equipmentService.getEquipmentById(_equipment.id!);
        setState(() => _equipment = updated);
      } catch (e) {
        // Keep existing data
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'operational':
        return AppColors.success;
      case 'maintenance':
        return AppColors.warning;
      case 'out of service':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getEquipmentIcon(String? type) {
    if (type == null) return Icons.build;
    switch (type.toLowerCase()) {
      case 'excavator':
        return Icons.construction;
      case 'truck':
        return Icons.local_shipping;
      case 'drill':
        return Icons.handyman;
      default:
        return Icons.build;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Equipment Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _isLoading ? null : _navigateToEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _isLoading ? null : _deleteEquipment,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _getEquipmentIcon(_equipment.type),
                              size: 36,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _equipment.name,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(_equipment.status),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    _equipment.status,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
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
                  const SizedBox(height: 20),

                  // Equipment Information
                  const Text(
                    'Equipment Information',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          if (_equipment.type != null)
                            _buildInfoRow(
                              'Type',
                              _equipment.type!,
                              Icons.category,
                            ),
                          if (_equipment.model != null) ...[
                            const Divider(height: 24),
                            _buildInfoRow(
                              'Model',
                              _equipment.model!,
                              Icons.info,
                            ),
                          ],
                          if (_equipment.serialNumber != null) ...[
                            const Divider(height: 24),
                            _buildInfoRow(
                              'Serial Number',
                              _equipment.serialNumber!,
                              Icons.tag,
                            ),
                          ],
                          if (_equipment.siteName != null) ...[
                            const Divider(height: 24),
                            _buildInfoRow(
                              'Assigned Site',
                              _equipment.siteName!,
                              Icons.location_on,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Purchase Information
                  if (_equipment.purchaseDate != null || _equipment.purchasePrice != null) ...[
                    const Text(
                      'Purchase Information',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            if (_equipment.purchaseDate != null)
                              _buildInfoRow(
                                'Purchase Date',
                                _formatDate(_equipment.purchaseDate!),
                                Icons.calendar_today,
                              ),
                            if (_equipment.purchasePrice != null) ...[
                              if (_equipment.purchaseDate != null) const Divider(height: 24),
                              _buildInfoRow(
                                'Purchase Price',
                                '\$${_equipment.purchasePrice!.toStringAsFixed(2)}',
                                Icons.attach_money,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Notes
                  if (_equipment.notes != null && _equipment.notes!.isNotEmpty) ...[
                    const Text(
                      'Notes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.note,
                              size: 20,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _equipment.notes!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Metadata
                  const Text(
                    'Additional Information',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _buildInfoRow(
                            'Equipment ID',
                            _equipment.id?.toString() ?? 'N/A',
                            Icons.fingerprint,
                          ),
                          if (_equipment.createdAt != null) ...[
                            const Divider(height: 24),
                            _buildInfoRow(
                              'Created At',
                              _formatDateTime(_equipment.createdAt!),
                              Icons.schedule,
                            ),
                          ],
                          if (_equipment.updatedAt != null) ...[
                            const Divider(height: 24),
                            _buildInfoRow(
                              'Updated At',
                              _formatDateTime(_equipment.updatedAt!),
                              Icons.update,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMMM dd, yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  String _formatDateTime(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM dd, yyyy HH:mm').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}
