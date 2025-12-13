import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/receivable.dart';
import '../../models/income.dart';
import '../../core/constants/app_colors.dart';
import '../../services/income_service.dart';
import '../income/income_detail_screen.dart';

class ReceivableDetailsScreen extends StatefulWidget {
  final Receivable receivable;

  const ReceivableDetailsScreen({Key? key, required this.receivable}) : super(key: key);

  @override
  State<ReceivableDetailsScreen> createState() => _ReceivableDetailsScreenState();
}

class _ReceivableDetailsScreenState extends State<ReceivableDetailsScreen> {
  final IncomeService _incomeService = IncomeService();
  bool _isLoadingIncome = false;

  Future<void> _navigateToRelatedIncome() async {
    setState(() => _isLoadingIncome = true);
    
    try {
      // Find income record with this receivableId
      final allIncome = await _incomeService.getAllIncome();
      final relatedIncome = allIncome.firstWhere(
        (income) => income.receivableId == widget.receivable.id,
        orElse: () => throw Exception('Income record not found'),
      );
      
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => IncomeDetailScreen(income: relatedIncome),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not find related income: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingIncome = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final dateFormat = DateFormat('MMM dd, yyyy');
    
    final totalPaid = widget.receivable.totalAmount - widget.receivable.remainingBalance;
    final usagePercentage = widget.receivable.totalAmount > 0 
        ? (totalPaid / widget.receivable.totalAmount * 100).toStringAsFixed(1)
        : '0.0';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Receivable Details'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.receipt_long, color: Colors.white, size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.receivable.client?['businessName'] ?? 'Unknown Client',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(widget.receivable.status),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      widget.receivable.status,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Summary Cards
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date and Description
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _buildInfoRow('Date', dateFormat.format(widget.receivable.date), Icons.calendar_today),
                          if (widget.receivable.description != null) ...[
                            const Divider(height: 24),
                            // Clickable description if it's from an income
                            if (widget.receivable.description!.contains('Outstanding from Truck'))
                              InkWell(
                                onTap: _isLoadingIncome ? null : _navigateToRelatedIncome,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.blue.shade200),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.description, size: 18, color: Colors.grey.shade600),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Description',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              widget.receivable.description!.split(' - Loading Date:')[0],
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey.shade800,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (_isLoadingIncome)
                                        const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                      else
                                        Icon(Icons.chevron_right, color: Colors.blue.shade700),
                                    ],
                                  ),
                                ),
                              )
                            else
                              _buildInfoRow('Description', widget.receivable.description!, Icons.notes),
                          ],
                          const Divider(height: 24),
                          _buildInfoRow('Mining Site', widget.receivable.siteName, Icons.location_on),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Financial Summary
                  Card(
                    color: Colors.orange.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Financial Summary',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildFinancialRow(
                            'Total Amount',
                            currencyFormat.format(widget.receivable.totalAmount),
                            Colors.orange.shade700,
                            isBold: true,
                          ),
                          const SizedBox(height: 8),
                          _buildFinancialRow(
                            'Amount Received',
                            currencyFormat.format(totalPaid),
                            Colors.green.shade700,
                          ),
                          const SizedBox(height: 8),
                          _buildFinancialRow(
                            'Remaining Balance',
                            currencyFormat.format(widget.receivable.remainingBalance),
                            Colors.red.shade700,
                            isBold: true,
                          ),
                          const SizedBox(height: 16),
                          // Progress Bar
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Collection Progress',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    '$usagePercentage%',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              LinearProgressIndicator(
                                value: widget.receivable.totalAmount > 0 
                                    ? totalPaid / widget.receivable.totalAmount 
                                    : 0,
                                backgroundColor: Colors.grey.shade300,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  widget.receivable.status == 'Collected'
                                      ? Colors.green
                                      : widget.receivable.status == 'Partially Collected'
                                          ? Colors.orange
                                          : Colors.red,
                                ),
                                minHeight: 8,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Partially Collected':
        return Colors.blue;
      case 'Collected':
        return Colors.green;
      case 'Overdue':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFinancialRow(String label, String value, Color color, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}
