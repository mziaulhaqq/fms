import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/payable.dart';
import '../../models/income.dart';
import '../../services/income_service.dart';
import '../../core/constants/app_colors.dart';
import '../income/income_detail_screen.dart';

class PayableDetailsScreen extends StatefulWidget {
  final Payable payable;

  const PayableDetailsScreen({Key? key, required this.payable}) : super(key: key);

  @override
  State<PayableDetailsScreen> createState() => _PayableDetailsScreenState();
}

class _PayableDetailsScreenState extends State<PayableDetailsScreen> {
  final IncomeService _incomeService = IncomeService();
  List<Income> _relatedIncomes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRelatedIncomes();
  }

  Future<void> _loadRelatedIncomes() async {
    setState(() => _isLoading = true);
    try {
      // Get all incomes and filter by liabilityId matching this payable
      final allIncomes = await _incomeService.getAllIncome();
      final filtered = allIncomes.where((income) {
        return income.liabilityId == widget.payable.id;
      }).toList();
      
      // Sort by date descending (newest first)
      filtered.sort((a, b) => b.loadingDate.compareTo(a.loadingDate));
      
      setState(() {
        _relatedIncomes = filtered;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading payment history: $e')),
        );
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Active':
        return Colors.green;
      case 'Partially Used':
        return Colors.orange;
      case 'Fully Used':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final dateFormat = DateFormat('MMM dd, yyyy');
    
    final totalUsed = widget.payable.totalAmount - widget.payable.remainingBalance;
    final usagePercentage = (totalUsed / widget.payable.totalAmount * 100).toStringAsFixed(1);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payable Details'),
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
                      const Icon(Icons.account_balance_wallet, color: Colors.white, size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.payable.client?['businessName'] ?? 'Unknown Client',
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
                      color: _getStatusColor(widget.payable.status),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      widget.payable.status,
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
                  // Type and Date
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _buildInfoRow('Type', widget.payable.type, Icons.category),
                          const Divider(height: 24),
                          _buildInfoRow('Date', dateFormat.format(widget.payable.date), Icons.calendar_today),
                          if (widget.payable.description != null) ...[
                            const Divider(height: 24),
                            _buildInfoRow('Description', widget.payable.description!, Icons.notes),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Financial Summary
                  Card(
                    color: Colors.blue.shade50,
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
                            currencyFormat.format(widget.payable.totalAmount),
                            Colors.blue.shade700,
                            isBold: true,
                          ),
                          const SizedBox(height: 8),
                          _buildFinancialRow(
                            'Amount Used',
                            currencyFormat.format(totalUsed),
                            Colors.orange.shade700,
                          ),
                          const SizedBox(height: 8),
                          _buildFinancialRow(
                            'Remaining Balance',
                            currencyFormat.format(widget.payable.remainingBalance),
                            Colors.green.shade700,
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
                                    'Usage',
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
                                value: totalUsed / widget.payable.totalAmount,
                                backgroundColor: Colors.grey.shade300,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  widget.payable.status == 'Fully Used'
                                      ? Colors.grey
                                      : widget.payable.status == 'Partially Used'
                                          ? Colors.orange
                                          : Colors.green,
                                ),
                                minHeight: 8,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Payment History Section
                  Row(
                    children: [
                      const Icon(Icons.history, color: AppColors.primary),
                      const SizedBox(width: 8),
                      const Text(
                        'Payment History',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (!_isLoading)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_relatedIncomes.length}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Payment History List
                  if (_isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (_relatedIncomes.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey.shade400),
                              const SizedBox(height: 12),
                              Text(
                                'No payments made yet',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _relatedIncomes.length,
                      itemBuilder: (context, index) {
                        final income = _relatedIncomes[index];
                        // Parse the loading date string to DateTime for formatting
                        DateTime? loadingDate;
                        try {
                          loadingDate = DateTime.parse(income.loadingDate);
                        } catch (e) {
                          loadingDate = null;
                        }
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => IncomeDetailScreen(income: income),
                                ),
                              );
                            },
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.green.shade100,
                                child: Icon(Icons.payment, color: Colors.green.shade700),
                              ),
                              title: Text(
                                'Invoice #${income.id}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Date: ${loadingDate != null ? dateFormat.format(loadingDate) : income.loadingDate}'),
                                  Text('Client: ${income.client?['businessName'] ?? 'N/A'}'),
                                  Text(
                                    'Amount Deducted: ${currencyFormat.format(income.amountFromLiability ?? 0)}',
                                    style: TextStyle(
                                      color: Colors.orange.shade700,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              isThreeLine: true,
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    currencyFormat.format(income.coalPrice),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    'Truck: ${income.truckNumber}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Icon(Icons.chevron_right, size: 16, color: Colors.grey.shade600),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                ],
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
