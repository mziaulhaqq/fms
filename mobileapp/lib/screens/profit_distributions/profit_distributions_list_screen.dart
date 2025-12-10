import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../models/profit_distribution.dart';
import '../../services/profit_distribution_service.dart';

class ProfitDistributionsListScreen extends StatefulWidget {
  const ProfitDistributionsListScreen({super.key});

  @override
  State<ProfitDistributionsListScreen> createState() => _ProfitDistributionsListScreenState();
}

class _ProfitDistributionsListScreenState extends State<ProfitDistributionsListScreen> {
  final _distributionService = ProfitDistributionService();
  List<ProfitDistribution> _distributions = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDistributions();
  }

  Future<void> _loadDistributions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final distributions = await _distributionService.getAllProfitDistributions();
      setState(() {
        _distributions = distributions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.secondary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Profit Distributions',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.secondary, size: 28),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Coming soon!')),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(0),
            topRight: Radius.circular(0),
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _buildErrorWidget()
                : _distributions.isEmpty
                    ? _buildEmptyWidget()
                    : _buildDistributionList(),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              _error ?? 'An error occurred',
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadDistributions,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              ),
              child: const Text('Retry', style: TextStyle(fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.pie_chart_outline, size: 64, color: Colors.grey.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            'No profit distributions found',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to add a new distribution',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildDistributionList() {
    return RefreshIndicator(
      onRefresh: _loadDistributions,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _distributions.length,
        itemBuilder: (context, index) {
          final distribution = _distributions[index];
          return _buildDistributionCard(distribution);
        },
      ),
    );
  }

  Widget _buildDistributionCard(ProfitDistribution distribution) {
    Color statusColor;
    switch (distribution.status) {
      case 'approved':
        statusColor = AppColors.success;
        break;
      case 'rejected':
        statusColor = AppColors.error;
        break;
      default:
        statusColor = AppColors.secondary;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${DateFormat('MMM dd').format(distribution.periodStart)} - ${DateFormat('MMM dd, yyyy').format(distribution.periodEnd)}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    distribution.status,
                    style: TextStyle(
                      fontSize: 11,
                      color: statusColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInfoChip(
                    'Revenue',
                    '\$${distribution.totalRevenue.toStringAsFixed(2)}',
                    AppColors.success,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInfoChip(
                    'Expenses',
                    '\$${distribution.totalExpenses.toStringAsFixed(2)}',
                    AppColors.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildInfoChip(
              'Net Profit',
              '\$${distribution.totalProfit.toStringAsFixed(2)}',
              AppColors.info,
              fullWidth: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, String value, Color color, {bool fullWidth = false}) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: fullWidth ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
