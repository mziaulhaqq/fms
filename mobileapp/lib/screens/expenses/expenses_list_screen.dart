import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../models/expense.dart';
import '../../services/expense_service.dart';
import 'expense_form_screen.dart';
import 'expense_detail_screen.dart';

class ExpensesListScreen extends StatefulWidget {
  const ExpensesListScreen({super.key});

  @override
  State<ExpensesListScreen> createState() => _ExpensesListScreenState();
}

class _ExpensesListScreenState extends State<ExpensesListScreen> {
  final ExpenseService _expenseService = ExpenseService();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  List<Expense> _expenses = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final expenses = await _expenseService.getExpenses();
      setState(() {
        _expenses = expenses;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onRefresh() async {
    await _loadExpenses();
    _refreshController.refreshCompleted();
  }

  Future<void> _deleteExpense(Expense expense) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_rounded, color: AppColors.error),
            SizedBox(width: 12),
            Text('Delete Expense'),
          ],
        ),
        content: Text(
            'Are you sure you want to delete this expense of \$${expense.amount.toStringAsFixed(2)}?'),
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
      try {
        await _expenseService.deleteExpense(expense.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Expense deleted successfully')),
          );
          _loadExpenses();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting expense: $e')),
          );
        }
      }
    }
  }

  void _navigateToForm([Expense? expense]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ExpenseFormScreen(expense: expense),
      ),
    );
    if (result == true) {
      _loadExpenses();
    }
  }

  void _navigateToDetail(Expense expense) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ExpenseDetailScreen(expense: expense),
      ),
    );
    if (result == true) {
      _loadExpenses();
    }
  }

  // Group expenses by date
  Map<String, List<Expense>> _groupExpensesByDate() {
    final Map<String, List<Expense>> grouped = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (var expense in _expenses) {
      final expenseDate = DateTime.parse(expense.expenseDate);
      final dateOnly = DateTime(
        expenseDate.year,
        expenseDate.month,
        expenseDate.day,
      );

      String dateKey;
      if (dateOnly == today) {
        dateKey = 'Today, ${DateFormat('MMM dd').format(expenseDate)}';
      } else if (dateOnly == yesterday) {
        dateKey = 'Yesterday, ${DateFormat('MMM dd').format(expenseDate)}';
      } else {
        dateKey = DateFormat('EEEE, MMM dd').format(expenseDate);
      }

      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(expense);
    }

    return grouped;
  }

  IconData _getCategoryIcon(String? categoryName) {
    if (categoryName == null) return Icons.category;
    
    final name = categoryName.toLowerCase();
    if (name.contains('fuel')) return Icons.local_gas_station;
    if (name.contains('food') || name.contains('meal')) return Icons.restaurant;
    if (name.contains('tool') || name.contains('equipment')) return Icons.build;
    if (name.contains('maintenance')) return Icons.handyman;
    if (name.contains('salary') || name.contains('wage')) return Icons.attach_money;
    if (name.contains('transport')) return Icons.local_shipping;
    
    return Icons.category;
  }

  Color _getCategoryColor(String? categoryName) {
    if (categoryName == null) return AppColors.primary;
    
    final name = categoryName.toLowerCase();
    if (name.contains('fuel')) return Colors.blue;
    if (name.contains('food') || name.contains('meal')) return Colors.orange;
    if (name.contains('tool') || name.contains('equipment')) return Colors.green;
    if (name.contains('maintenance')) return Colors.purple;
    if (name.contains('salary') || name.contains('wage')) return AppColors.success;
    if (name.contains('transport')) return Colors.teal;
    
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.secondary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Expense Management',
          style: TextStyle(color: Colors.white),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToForm(),
        backgroundColor: AppColors.secondary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'New Expense',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorWidget()
              : _expenses.isEmpty
                  ? _buildEmptyWidget()
                  : _buildExpensesList(),
    );
  }

  Widget _buildExpensesList() {
    final groupedExpenses = _groupExpensesByDate();
    
    return SmartRefresher(
      controller: _refreshController,
      onRefresh: _onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: groupedExpenses.length,
        itemBuilder: (context, index) {
          final dateKey = groupedExpenses.keys.elementAt(index);
          final expenses = groupedExpenses[dateKey]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date header
              Container(
                padding: const EdgeInsets.fromLTRB(14, 16, 14, 10),
                child: Text(
                  dateKey,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              
              // Expense items for this date
              ...expenses.map((expense) => _buildExpenseCard(expense)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildExpenseCard(Expense expense) {
    final categoryIcon = _getCategoryIcon(expense.categoryName);
    final categoryColor = _getCategoryColor(expense.categoryName);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => _navigateToDetail(expense),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Category icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: categoryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  categoryIcon,
                  color: categoryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              
              // Expense details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.categoryName ?? 'Uncategorized',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (expense.notes != null && expense.notes!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        expense.notes!,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              
              // Amount in red
              Text(
                '-\$${expense.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No expenses yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap the + button to add your first expense',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: 16),
          Text('Error: $_error'),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadExpenses,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }
}

