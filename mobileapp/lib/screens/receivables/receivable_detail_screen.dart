import 'package:flutter/material.dart';
import '../../models/receivable.dart';
import '../../services/receivable_service.dart';
import '../../core/constants/app_colors.dart';
import 'receivable_form_screen.dart';

class ReceivableDetailScreen extends StatefulWidget {
  final int receivableId;

  const ReceivableDetailScreen({Key? key, required this.receivableId})
      : super(key: key);

  @override
  State<ReceivableDetailScreen> createState() => _ReceivableDetailScreenState();
}

class _ReceivableDetailScreenState extends State<ReceivableDetailScreen> {
  final ReceivableService _service = ReceivableService();
  Receivable? _receivable;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReceivable();
  }

  Future<void> _loadReceivable() async {
    setState(() => _isLoading = true);
    try {
      final receivable = await _service.getById(widget.receivableId);
      setState(() {
        _receivable = receivable;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Partially Paid':
        return Colors.blue;
      case 'Fully Paid':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receivable Details'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        actions: [
          if (_receivable != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ReceivableFormScreen(receivable: _receivable),
                  ),
                );
                if (result == true) {
                  _loadReceivable();
                }
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _receivable == null
              ? const Center(child: Text('Receivable not found'))
              : RefreshIndicator(
                  onRefresh: _loadReceivable,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Status Card
                      Card(
                        color: _getStatusColor(_receivable!.status).withOpacity(0.1),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Icon(
                                _receivable!.isPending
                                    ? Icons.hourglass_empty
                                    : _receivable!.isFullyPaid
                                        ? Icons.check_circle
                                        : Icons.timelapse,
                                color: _getStatusColor(_receivable!.status),
                                size: 48,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _receivable!.status,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: _getStatusColor(_receivable!.status),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Amount Summary Card
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Amount Summary',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Divider(),
                              _buildInfoRow(
                                'Total Amount',
                                '\$${_receivable!.totalAmount.toStringAsFixed(2)}',
                                Colors.black,
                              ),
                              _buildInfoRow(
                                'Remaining Balance',
                                '\$${_receivable!.remainingBalance.toStringAsFixed(2)}',
                                Colors.red,
                              ),
                              _buildInfoRow(
                                'Paid Amount',
                                '\$${(_receivable!.totalAmount - _receivable!.remainingBalance).toStringAsFixed(2)}',
                                Colors.green,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Details Card
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Details',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Divider(),
                              _buildInfoRow(
                                'Client',
                                _receivable!.client?['businessName'] ?? 'Unknown',
                                Colors.black87,
                              ),
                              _buildInfoRow(
                                'Mining Site',
                                _receivable!.miningSite?['name'] ?? 'Unknown',
                                Colors.black87,
                              ),
                              _buildInfoRow(
                                'Date',
                                _receivable!.date.toString().split(' ')[0],
                                Colors.black87,
                              ),
                              if (_receivable!.description != null)
                                _buildInfoRow(
                                  'Description',
                                  _receivable!.description!,
                                  Colors.black87,
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Payment History Card (placeholder)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Payment History',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Divider(),
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Text(
                                    'Payment history will be displayed here',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
