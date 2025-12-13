import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../models/income.dart';
import '../../services/income_service.dart';
import 'income_form_screen.dart';
import '../payables/payable_details_screen.dart';
import '../receivables/receivable_details_screen.dart';
import '../../models/payable.dart';
import '../../models/receivable.dart';

class IncomeDetailScreen extends StatefulWidget {
  final Income income;

  const IncomeDetailScreen({super.key, required this.income});

  @override
  State<IncomeDetailScreen> createState() => _IncomeDetailScreenState();
}

class _IncomeDetailScreenState extends State<IncomeDetailScreen> {
  final IncomeService _incomeService = IncomeService();
  late Income _income;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _income = widget.income;
  }

  Future<void> _deleteIncome() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_rounded, color: AppColors.error),
            SizedBox(width: 12),
            Text('Delete Income'),
          ],
        ),
        content: Text('Are you sure you want to delete income for truck "${_income.truckNumber}"?'),
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
        await _incomeService.deleteIncome(_income.id!);
        if (mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Income deleted successfully')),
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
        builder: (_) => IncomeFormScreen(income: _income),
      ),
    );
    if (result == true && mounted) {
      try {
        final updated = await _incomeService.getIncomeById(_income.id!);
        setState(() => _income = updated);
      } catch (e) {
        // Keep existing data
      }
    }
  }

  double _calculateTotal() {
    return _income.coalPrice - _income.companyCommission;
  }

  double _calculateTotalPaid() {
    final fromPayable = _income.amountFromLiability ?? 0.0;
    final cash = _income.amountCash ?? 0.0;
    return fromPayable + cash;
  }

  double _calculateOutstanding() {
    final totalPaid = _calculateTotalPaid();
    final outstanding = _income.coalPrice - totalPaid;
    return outstanding > 0 ? outstanding : 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final total = _calculateTotal();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Income Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _isLoading ? null : _navigateToEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _isLoading ? null : _deleteIncome,
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
                              color: AppColors.success.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.local_shipping,
                              size: 36,
                              color: AppColors.success,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Truck ${_income.truckNumber}',
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
                                    color: AppColors.success,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'Net Income: \$${total.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 14,
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

                  // Truck & Driver Information
                  const Text(
                    'Truck & Driver Information',
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
                            'Truck Number',
                            _income.truckNumber,
                            Icons.local_shipping,
                          ),
                          const Divider(height: 24),
                          _buildInfoRow(
                            'Driver Name',
                            _income.driverName,
                            Icons.person,
                          ),
                          if (_income.driverPhone != null) ...[
                            const Divider(height: 24),
                            _buildInfoRow(
                              'Driver Phone',
                              _income.driverPhone!,
                              Icons.phone,
                            ),
                          ],
                          const Divider(height: 24),
                          _buildInfoRow(
                            'Loading Date',
                            _formatDate(_income.loadingDate),
                            Icons.calendar_today,
                          ),
                          if (_income.siteName != null) ...[
                            const Divider(height: 24),
                            _buildInfoRow(
                              'Mining Site',
                              _income.siteName!,
                              Icons.location_on,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Financial Information
                  const Text(
                    'Financial Information',
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
                            'Coal Price',
                            '\$${_income.coalPrice.toStringAsFixed(2)}',
                            Icons.attach_money,
                          ),
                          const Divider(height: 24),
                          _buildInfoRow(
                            'Company Commission',
                            '\$${_income.companyCommission.toStringAsFixed(2)}',
                            Icons.remove_circle,
                          ),
                          const Divider(height: 24),
                          Row(
                            children: [
                              const Icon(
                                Icons.account_balance_wallet,
                                size: 18,
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
                                      '\$${total.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.success,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Payment Breakdown
                  const Text(
                    'Payment Breakdown',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Amount from Payable (Clickable)
                          if (_income.liabilityId != null && _income.amountFromLiability != null)
                            InkWell(
                              onTap: () {
                                if (_income.liability != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PayableDetailsScreen(
                                        payable: Payable.fromJson(_income.liability!),
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.orange.shade200),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.account_balance_wallet, 
                                      size: 20, color: Colors.orange.shade700),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Paid from Payable (Advance Payment)',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '\$${_income.amountFromLiability!.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.orange.shade700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(Icons.chevron_right, color: Colors.orange.shade700),
                                  ],
                                ),
                              ),
                            ),
                          
                          if (_income.liabilityId != null && _income.amountFromLiability != null)
                            const SizedBox(height: 12),

                          // Amount in Cash
                          if (_income.amountCash != null)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.green.shade200),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.payments, size: 20, color: Colors.green.shade700),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Paid in Cash',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '\$${_income.amountCash!.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          if (_income.amountCash != null)
                            const SizedBox(height: 12),

                          // Total Paid
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue.shade300, width: 2),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle, size: 20, color: Colors.blue.shade700),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Total Paid',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '\$${_calculateTotalPaid().toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Outstanding Amount / Receivable
                          if (_calculateOutstanding() > 0) ...[
                            const SizedBox(height: 12),
                            InkWell(
                              onTap: () {
                                if (_income.receivableId != null && _income.receivable != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ReceivableDetailsScreen(
                                        receivable: Receivable.fromJson(_income.receivable!),
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.red.shade200, width: 2),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.warning_amber, size: 20, color: Colors.red.shade700),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              const Text(
                                                'Outstanding Amount (Receivable)',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: AppColors.textSecondary,
                                                ),
                                              ),
                                              if (_income.receivableId != null)
                                                Container(
                                                  margin: const EdgeInsets.only(left: 8),
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: Colors.green,
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: const Text(
                                                    'Created',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '\$${_calculateOutstanding().toStringAsFixed(2)}',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red.shade700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (_income.receivableId != null)
                                      Icon(Icons.chevron_right, color: Colors.red.shade700),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Metadata
                  const Text(
                    'Record Information',
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
                            'Income ID',
                            _income.id?.toString() ?? 'N/A',
                            Icons.tag,
                          ),
                          if (_income.creator != null || _income.createdBy != null) ...[
                            const Divider(height: 24),
                            _buildInfoRow(
                              'Created By',
                              _income.creator?['fullName'] ?? 
                              _income.creator?['username'] ?? 
                              'User #${_income.createdBy}',
                              Icons.person_add,
                            ),
                          ],
                          if (_income.createdAt != null) ...[
                            const Divider(height: 24),
                            _buildInfoRow(
                              'Created At',
                              _formatDateTime(_income.createdAt!),
                              Icons.schedule,
                            ),
                          ],
                          if (_income.modifier != null || _income.modifiedBy != null) ...[
                            const Divider(height: 24),
                            _buildInfoRow(
                              'Modified By',
                              _income.modifier?['fullName'] ?? 
                              _income.modifier?['username'] ?? 
                              'User #${_income.modifiedBy}',
                              Icons.person_outline,
                            ),
                          ],
                          if (_income.updatedAt != null) ...[
                            const Divider(height: 24),
                            _buildInfoRow(
                              'Last Updated',
                              _formatDateTime(_income.updatedAt!),
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
