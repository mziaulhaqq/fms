import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../models/production.dart';
import '../../services/production_service.dart';
import 'production_form_screen.dart';

class ProductionDetailScreen extends StatelessWidget {
  final Production production;

  const ProductionDetailScreen({super.key, required this.production});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Production Details', style: TextStyle(fontSize: 18)),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, size: 22),
            onPressed: () => _editProduction(context),
            tooltip: 'Edit',
          ),
          IconButton(
            icon: const Icon(Icons.delete, size: 22),
            onPressed: () => _deleteProduction(context),
            tooltip: 'Delete',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.info,
                      child: const Icon(
                        Icons.analytics,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('MMM dd, yyyy').format(production.date),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${production.quantity} tons',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
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

            _buildSectionTitle('Production Details'),
            _buildInfoCard([
              _buildInfoRow('Quantity', '${production.quantity} tons'),
              if (production.quality != null)
                _buildInfoRow('Quality', production.quality!),
              if (production.shift != null)
                _buildInfoRow('Shift', production.shift!),
              _buildInfoRow('Date', DateFormat('MMM dd, yyyy').format(production.date)),
            ]),
            const SizedBox(height: 20),

            if (production.notes != null) ...[
              _buildSectionTitle('Notes'),
              _buildInfoCard([
                _buildInfoRow('Notes', production.notes!),
              ]),
              const SizedBox(height: 20),
            ],

            _buildSectionTitle('System Information'),
            _buildInfoCard([
              _buildInfoRow('Created At', _formatDate(production.createdAt)),
              _buildInfoRow('Updated At', _formatDate(production.updatedAt)),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy hh:mm a').format(date);
  }

  Future<void> _editProduction(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductionFormScreen(production: production),
      ),
    );
    if (result == true && context.mounted) {
      Navigator.pop(context, true);
    }
  }

  Future<void> _deleteProduction(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Production Record', style: TextStyle(fontSize: 16)),
        content: const Text(
          'Are you sure you want to delete this production record?',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(fontSize: 14)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete', style: TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await ProductionService().deleteProduction(production.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Production record deleted successfully', style: TextStyle(fontSize: 13)),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete production record: $e', style: const TextStyle(fontSize: 13)),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }
}
