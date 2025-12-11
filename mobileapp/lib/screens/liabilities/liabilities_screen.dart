import 'package:flutter/material.dart';
import '../../models/liability.dart';
import '../../services/liability_service.dart';
import '../../core/constants/app_colors.dart';
import 'liability_form_screen.dart';

class LiabilitiesScreen extends StatefulWidget {
  const LiabilitiesScreen({Key? key}) : super(key: key);

  @override
  State<LiabilitiesScreen> createState() => _LiabilitiesScreenState();
}

class _LiabilitiesScreenState extends State<LiabilitiesScreen>
    with SingleTickerProviderStateMixin {
  final LiabilityService _service = LiabilityService();
  late TabController _tabController;
  List<Liability> _liabilities = [];
  bool _isLoading = true;
  String _currentType = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadLiabilities();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _currentType = _tabController.index == 0
            ? 'All'
            : _tabController.index == 1
                ? 'Loan'
                : 'Advanced Payment';
      });
      _loadLiabilities();
    }
  }

  Future<void> _loadLiabilities() async {
    setState(() => _isLoading = true);
    try {
      List<Liability> liabilities;
      if (_currentType == 'All') {
        liabilities = await _service.getAll();
      } else {
        liabilities = await _service.getAll(type: _currentType);
      }
      setState(() {
        _liabilities = liabilities;
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

  Future<void> _delete(int id) async {
    try {
      await _service.delete(id);
      _loadLiabilities();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Liability deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting: $e')),
        );
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Active':
        return Colors.green;
      case 'Partially Settled':
        return Colors.orange;
      case 'Fully Settled':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liabilities'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.textOnPrimary,
          unselectedLabelColor: AppColors.textLight,
          indicatorColor: AppColors.secondary,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Loans'),
            Tab(text: 'Advanced Payments'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LiabilityFormScreen(),
            ),
          );
          if (result == true) _loadLiabilities();
        },
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _liabilities.isEmpty
              ? Center(
                  child: Text(
                    _currentType == 'All'
                        ? 'No liabilities found\nTap + to add one'
                        : 'No ${_currentType.toLowerCase()}s found\nTap + to add one',
                    textAlign: TextAlign.center,
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadLiabilities,
                  child: ListView.builder(
                    itemCount: _liabilities.length,
                    itemBuilder: (context, index) {
                      final liability = _liabilities[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: liability.isLoan
                                ? Colors.red.shade100
                                : Colors.blue.shade100,
                            child: Icon(
                              liability.isLoan
                                  ? Icons.trending_up
                                  : Icons.trending_down,
                              color: liability.isLoan ? Colors.red : Colors.blue,
                            ),
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  liability.client?['name'] ?? 'Unknown Client',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(liability.status),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  liability.status,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Type: ${liability.type}'),
                              Text(
                                'Total: \$${liability.totalAmount.toStringAsFixed(2)} | Remaining: \$${liability.remainingBalance.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Date: ${liability.date.toString().split(' ')[0]}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          isThreeLine: true,
                          trailing: PopupMenuButton(
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit),
                                    SizedBox(width: 8),
                                    Text('Edit'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Delete',
                                        style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),
                            ],
                            onSelected: (value) async {
                              if (value == 'edit') {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        LiabilityFormScreen(liability: liability),
                                  ),
                                );
                                if (result == true) _loadLiabilities();
                              } else if (value == 'delete') {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Confirm Delete'),
                                    content: const Text(
                                        'Are you sure you want to delete this liability?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.red,
                                        ),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) _delete(liability.id);
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
