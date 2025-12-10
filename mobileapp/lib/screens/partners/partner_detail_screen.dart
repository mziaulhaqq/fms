import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../models/partner.dart';
import '../../services/partner_service.dart';
import 'partner_form_screen.dart';

class PartnerDetailScreen extends StatelessWidget {
  final Partner partner;

  const PartnerDetailScreen({super.key, required this.partner});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Partner Details', style: TextStyle(fontSize: 18)),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, size: 22),
            onPressed: () => _editPartner(context),
            tooltip: 'Edit',
          ),
          IconButton(
            icon: const Icon(Icons.delete, size: 22),
            onPressed: () => _deletePartner(context),
            tooltip: 'Delete',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
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
                      backgroundColor: AppColors.success,
                      child: Text(
                        partner.name.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            partner.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: partner.isActive
                                  ? AppColors.success.withOpacity(0.1)
                                  : AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              partner.isActive ? 'Active' : 'Inactive',
                              style: TextStyle(
                                color: partner.isActive
                                    ? AppColors.success
                                    : AppColors.error,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
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

            // Contact Information
            _buildSectionTitle('Contact Information'),
            _buildInfoCard([
              _buildInfoRow('CNIC', partner.cnic),
              if (partner.phone != null)
                _buildInfoRow('Phone', partner.phone!),
              if (partner.email != null)
                _buildInfoRow('Email', partner.email!),
              if (partner.address != null)
                _buildInfoRow('Address', partner.address!),
            ]),
            const SizedBox(height: 20),

            // Partnership Details
            _buildSectionTitle('Partnership Details'),
            _buildInfoCard([
              if (partner.sharePercentage != null)
                _buildInfoRow('Share Percentage', '${partner.sharePercentage}%'),
              if (partner.lease != null)
                _buildInfoRow('Lease', partner.lease!),
              if (partner.mineNumber != null)
                _buildInfoRow('Mine Number', partner.mineNumber.toString()),
            ]),
            const SizedBox(height: 20),

            // System Information
            _buildSectionTitle('System Information'),
            _buildInfoCard([
              _buildInfoRow('Created At', _formatDate(partner.createdAt)),
              _buildInfoRow('Updated At', _formatDate(partner.updatedAt)),
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

  Future<void> _editPartner(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PartnerFormScreen(partner: partner),
      ),
    );
    if (result == true && context.mounted) {
      Navigator.pop(context, true);
    }
  }

  Future<void> _deletePartner(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Partner', style: TextStyle(fontSize: 16)),
        content: Text(
          'Are you sure you want to delete ${partner.name}?',
          style: const TextStyle(fontSize: 14),
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
        await PartnerService().deletePartner(partner.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Partner deleted successfully', style: TextStyle(fontSize: 13)),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete partner: $e', style: const TextStyle(fontSize: 13)),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }
}
