import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/app_colors.dart';
import '../../services/auth_service.dart';
import '../../services/expense_service.dart';
import '../../services/income_service.dart';
// TODO: Add production service when endpoint is created
// import '../../services/production_service.dart';
import '../auth/login_screen.dart';
import '../clients/clients_list_screen.dart';
import '../expense_categories/expense_categories_list_screen.dart';
import '../expenses/expenses_list_screen.dart';
import '../mining_sites/mining_sites_list_screen.dart';
import '../equipment/equipment_list_screen.dart';
import '../income/income_list_screen.dart';
import '../workers/workers_list_screen.dart';
import '../partners/partners_list_screen.dart';
// TODO: Create production_list_screen.dart
// import '../production/production_list_screen.dart';
import '../truck_deliveries/truck_deliveries_list_screen.dart';
import '../profit_distributions/profit_distributions_list_screen.dart';
import '../users/users_list_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _authService = AuthService();
  final _expenseService = ExpenseService();
  final _incomeService = IncomeService();
  // TODO: Add production service when endpoint is created
  // final _productionService = ProductionService();
  
  String? _userEmail;
  bool _isAdmin = false;
  bool _isLoadingRoles = true;
  bool _isLoadingMetrics = false;
  
  // Date filter
  String _selectedPeriod = 'Today'; // Today, Week, Month, Max
  
  // Metrics
  double _totalExpenses = 0.0;
  double _totalIncome = 0.0;
  double _totalProduction = 0.0;
  
  // Chart data
  List<BarChartGroupData> _chartData = [];

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadMetrics();
  }

  Future<void> _loadUserInfo() async {
    final email = await _authService.getCurrentUserEmail();
    final isAdmin = await _authService.isAdmin();
    setState(() {
      _userEmail = email;
      _isAdmin = isAdmin;
      _isLoadingRoles = false;
    });
  }
  
  Future<void> _loadMetrics() async {
    setState(() => _isLoadingMetrics = true);
    
    try {
      final now = DateTime.now();
      DateTime startDate;
      
      switch (_selectedPeriod) {
        case 'Today':
          startDate = DateTime(now.year, now.month, now.day);
          break;
        case 'Week':
          startDate = now.subtract(Duration(days: now.weekday - 1));
          startDate = DateTime(startDate.year, startDate.month, startDate.day);
          break;
        case 'Month':
          startDate = DateTime(now.year, now.month, 1);
          break;
        case 'Year':
          startDate = DateTime(now.year, 1, 1);
          break;
        case 'Max':
          startDate = DateTime(2000, 1, 1); // All-time
          break;
        default:
          startDate = DateTime(now.year, now.month, now.day);
      }
      
      // Load expenses
      final expenses = await _expenseService.getExpenses();
      final filteredExpenses = expenses.where((expense) {
        final expenseDate = DateTime.parse(expense.expenseDate);
        return expenseDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
               expenseDate.isBefore(now.add(const Duration(days: 1)));
      }).toList();
      
      // Load income
      final income = await _incomeService.getAllIncome();
      print('📊 Total income records: ${income.length}');
      if (income.isNotEmpty) {
        print('📊 First income: ${income.first.loadingDate}, amount: ${income.first.netAmount}');
      }
      final filteredIncome = income.where((inc) {
        final incomeDate = DateTime.parse(inc.loadingDate);
        return incomeDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
               incomeDate.isBefore(now.add(const Duration(days: 1)));
      }).toList();
      print('📊 Filtered income records: ${filteredIncome.length} (from $startDate to $now)');
      
      // TODO: Load production when endpoint is created
      // final production = await _productionService.getProduction();
      // final filteredProduction = production.where((prod) {
      //   return prod.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
      //          prod.date.isBefore(now.add(const Duration(days: 1)));
      // }).toList();
      final filteredProduction = []; // Empty list for now
      
      setState(() {
        _totalExpenses = filteredExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
        _totalIncome = filteredIncome.fold(0.0, (sum, inc) => sum + (inc.netAmount ?? 0.0));
        _totalProduction = 0.0; // Set to 0 for now
        
        print('📊 TOTALS - Expenses: $_totalExpenses, Income: $_totalIncome, Production: $_totalProduction');
        
        // Generate chart data
        _chartData = _generateChartData(
          filteredExpenses,
          filteredIncome,
          filteredProduction,
          startDate,
          now,
        );
        
        _isLoadingMetrics = false;
      });
    } catch (e) {
      print('Error loading metrics: $e'); // Debug print
      setState(() => _isLoadingMetrics = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading metrics: $e')),
        );
      }
    }
  }
  
  List<BarChartGroupData> _generateChartData(
    List expenses,
    List income,
    List production,
    DateTime startDate,
    DateTime endDate,
  ) {
    List<BarChartGroupData> chartGroups = [];
    
    if (_selectedPeriod == 'Today') {
      // Show last 7 days
      for (int i = 6; i >= 0; i--) {
        final date = endDate.subtract(Duration(days: i));
        final dayStart = DateTime(date.year, date.month, date.day);
        final dayEnd = dayStart.add(const Duration(days: 1));
        
        final dayExpenses = expenses.where((e) {
          final eDate = DateTime.parse(e.expenseDate);
          return eDate.isAfter(dayStart.subtract(const Duration(seconds: 1))) &&
                 eDate.isBefore(dayEnd);
        }).fold(0.0, (sum, e) => sum + e.amount);
        
        final dayIncome = income.where((inc) {
          final iDate = DateTime.parse(inc.loadingDate);
          return iDate.isAfter(dayStart.subtract(const Duration(seconds: 1))) &&
                 iDate.isBefore(dayEnd);
        }).fold(0.0, (sum, inc) => sum + (inc.netAmount ?? 0.0));
        
        chartGroups.add(
          BarChartGroupData(
            x: 6 - i,
            barRods: [
              BarChartRodData(
                toY: dayExpenses,
                color: AppColors.error,
                width: 8,
              ),
              BarChartRodData(
                toY: dayIncome,
                color: AppColors.success,
                width: 8,
              ),
            ],
          ),
        );
      }
    } else if (_selectedPeriod == 'Week') {
      // Show last 4 weeks
      for (int i = 3; i >= 0; i--) {
        final weekEnd = endDate.subtract(Duration(days: i * 7));
        final weekStart = weekEnd.subtract(const Duration(days: 7));
        
        final weekExpenses = expenses.where((e) {
          final eDate = DateTime.parse(e.expenseDate);
          return eDate.isAfter(weekStart.subtract(const Duration(seconds: 1))) &&
                 eDate.isBefore(weekEnd.add(const Duration(seconds: 1)));
        }).fold(0.0, (sum, e) => sum + e.amount);
        
        final weekIncome = income.where((inc) {
          final iDate = DateTime.parse(inc.loadingDate);
          return iDate.isAfter(weekStart.subtract(const Duration(seconds: 1))) &&
                 iDate.isBefore(weekEnd.add(const Duration(seconds: 1)));
        }).fold(0.0, (sum, inc) => sum + (inc.netAmount ?? 0.0));
        
        chartGroups.add(
          BarChartGroupData(
            x: 3 - i,
            barRods: [
              BarChartRodData(
                toY: weekExpenses,
                color: AppColors.error,
                width: 12,
              ),
              BarChartRodData(
                toY: weekIncome,
                color: AppColors.success,
                width: 12,
              ),
            ],
          ),
        );
      }
    } else if (_selectedPeriod == 'Month') {
      // Show last 6 months
      for (int i = 5; i >= 0; i--) {
        final monthDate = DateTime(endDate.year, endDate.month - i, 1);
        final monthEnd = DateTime(monthDate.year, monthDate.month + 1, 1);
        
        final monthExpenses = expenses.where((e) {
          final eDate = DateTime.parse(e.expenseDate);
          return eDate.isAfter(monthDate.subtract(const Duration(seconds: 1))) &&
                 eDate.isBefore(monthEnd);
        }).fold(0.0, (sum, e) => sum + e.amount);
        
        final monthIncome = income.where((inc) {
          final iDate = DateTime.parse(inc.loadingDate);
          return iDate.isAfter(monthDate.subtract(const Duration(seconds: 1))) &&
                 iDate.isBefore(monthEnd);
        }).fold(0.0, (sum, inc) => sum + (inc.netAmount ?? 0.0));
        
        chartGroups.add(
          BarChartGroupData(
            x: 5 - i,
            barRods: [
              BarChartRodData(
                toY: monthExpenses,
                color: AppColors.error,
                width: 16,
              ),
              BarChartRodData(
                toY: monthIncome,
                color: AppColors.success,
                width: 16,
              ),
            ],
          ),
        );
      }
    } else if (_selectedPeriod == 'Year') {
      // Show last 12 months
      for (int i = 11; i >= 0; i--) {
        final monthDate = DateTime(endDate.year, endDate.month - i, 1);
        final monthEnd = DateTime(monthDate.year, monthDate.month + 1, 1);
        
        final monthExpenses = expenses.where((e) {
          final eDate = DateTime.parse(e.expenseDate);
          return eDate.isAfter(monthDate.subtract(const Duration(seconds: 1))) &&
                 eDate.isBefore(monthEnd);
        }).fold(0.0, (sum, e) => sum + e.amount);
        
        final monthIncome = income.where((inc) {
          final iDate = DateTime.parse(inc.loadingDate);
          return iDate.isAfter(monthDate.subtract(const Duration(seconds: 1))) &&
                 iDate.isBefore(monthEnd);
        }).fold(0.0, (sum, inc) => sum + (inc.netAmount ?? 0.0));
        
        chartGroups.add(
          BarChartGroupData(
            x: 11 - i,
            barRods: [
              BarChartRodData(
                toY: monthExpenses,
                color: AppColors.error,
                width: 12,
              ),
              BarChartRodData(
                toY: monthIncome,
                color: AppColors.success,
                width: 12,
              ),
            ],
          ),
        );
      }
    } else if (_selectedPeriod == 'Max') {
      // Show yearly data for all years with data
      final years = <int>{};
      for (var e in expenses) {
        years.add(DateTime.parse(e.expenseDate).year);
      }
      for (var inc in income) {
        years.add(DateTime.parse(inc.loadingDate).year);
      }
      
      final sortedYears = years.toList()..sort();
      final recentYears = sortedYears.length > 5 
          ? sortedYears.sublist(sortedYears.length - 5)
          : sortedYears;
      
      for (int i = 0; i < recentYears.length; i++) {
        final year = recentYears[i];
        final yearStart = DateTime(year, 1, 1);
        final yearEnd = DateTime(year + 1, 1, 1);
        
        final yearExpenses = expenses.where((e) {
          final eDate = DateTime.parse(e.expenseDate);
          return eDate.isAfter(yearStart.subtract(const Duration(seconds: 1))) &&
                 eDate.isBefore(yearEnd);
        }).fold(0.0, (sum, e) => sum + e.amount);
        
        final yearIncome = income.where((inc) {
          final iDate = DateTime.parse(inc.loadingDate);
          return iDate.isAfter(yearStart.subtract(const Duration(seconds: 1))) &&
                 iDate.isBefore(yearEnd);
        }).fold(0.0, (sum, inc) => sum + (inc.netAmount ?? 0.0));
        
        chartGroups.add(
          BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: yearExpenses,
                color: AppColors.error,
                width: 20,
              ),
              BarChartRodData(
                toY: yearIncome,
                color: AppColors.success,
                width: 20,
              ),
            ],
          ),
        );
      }
    }
    
    return chartGroups;
  }

  Future<void> _handleLogout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                color: AppColors.primary,
              ),
              accountName: const Text(
                'Admin User',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              accountEmail: Text(_userEmail ?? ''),
              currentAccountPicture: CircleAvatar(
                backgroundColor: AppColors.secondary,
                child: Text(
                  _userEmail?.substring(0, 1).toUpperCase() ?? 'A',
                  style: const TextStyle(
                    fontSize: 32,
                    color: AppColors.textOnPrimary,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard, color: AppColors.primary),
              title: const Text('Dashboard'),
              onTap: () => Navigator.pop(context),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.business, color: AppColors.primary),
              title: const Text('Clients'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ClientsListScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.category, color: AppColors.primary),
              title: const Text('Expense Categories'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ExpenseCategoriesListScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.money_off, color: AppColors.primary),
              title: const Text('Expenses'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ExpensesListScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.build, color: AppColors.primary),
              title: const Text('Equipment'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const EquipmentListScreen(),
                  ),
                );
              },
            ),
            // Income - Admin only
            if (_isAdmin)
              ListTile(
                leading: const Icon(Icons.account_balance_wallet, color: AppColors.primary),
                title: const Text('Income'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const IncomeListScreen(),
                    ),
                  );
                },
              ),
            ListTile(
              leading: const Icon(Icons.handshake, color: AppColors.primary),
              title: const Text('Partners'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PartnersListScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.people, color: AppColors.primary),
              title: const Text('Workers'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const WorkersListScreen(),
                  ),
                );
              },
            ),
            const Divider(),
            // Financial Management Section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'FINANCIAL MANAGEMENT',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.account_balance, color: AppColors.success),
              title: const Text('General Ledger'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/general-ledger');
              },
            ),
            ListTile(
              leading: const Icon(Icons.credit_card, color: AppColors.warning),
              title: const Text('Liabilities'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/liabilities');
              },
            ),
            const Divider(),
            // Lease Management Section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'LEASE MANAGEMENT',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.description, color: AppColors.info),
              title: const Text('Leases'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/leases');
              },
            ),
            if (_isAdmin)
              ListTile(
                leading: const Icon(Icons.location_on, color: AppColors.info),
                title: const Text('Mining Sites'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MiningSitesListScreen(),
                    ),
                  );
                },
              ),
            const Divider(),
            // Configuration Section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'CONFIGURATION',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.category_outlined, color: AppColors.secondary),
              title: const Text('Client Types'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/client-types');
              },
            ),
            ListTile(
              leading: const Icon(Icons.monetization_on_outlined, color: AppColors.accent),
              title: const Text('Expense Types'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/expense-types');
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_tree_outlined, color: AppColors.primaryLight),
              title: const Text('Account Types'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/account-types');
              },
            ),
            const Divider(),
            // Admin Section
            if (_isAdmin) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'ADMINISTRATION',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.pie_chart, color: AppColors.primary),
                title: const Text('Profit Distributions'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProfitDistributionsListScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.admin_panel_settings, color: AppColors.primary),
                title: const Text('Users'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const UsersListScreen(),
                    ),
                  );
                },
              ),
              const Divider(),
            ],
            ListTile(
              leading: const Icon(Icons.settings, color: AppColors.primary),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/settings');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: const Text('Logout'),
              onTap: _handleLogout,
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadMetrics,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Period Selector
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildPeriodChip('Today'),
                    const SizedBox(width: 8),
                    _buildPeriodChip('Week'),
                    const SizedBox(width: 8),
                    _buildPeriodChip('Month'),
                    const SizedBox(width: 8),
                    _buildPeriodChip('Year'),
                    const SizedBox(width: 8),
                    _buildPeriodChip('Max'),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const SizedBox(height: 20),
              
              // Key Metrics Section
              const Text(
                'Key Metrics',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              
              // Loading or Metric Cards
              if (_isLoadingMetrics)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else
                Column(
                  children: [
                    _buildMetricCard(
                      'Expenses',
                      'Rs. ${_totalExpenses.toStringAsFixed(0)}',
                      Icons.trending_down,
                      AppColors.error,
                    ),
                    const SizedBox(height: 8),
                    _buildMetricCard(
                      'Income',
                      'Rs. ${_totalIncome.toStringAsFixed(0)}',
                      Icons.trending_up,
                      AppColors.success,
                    ),
                    const SizedBox(height: 8),
                    _buildMetricCard(
                      'Production',
                      'Coming Soon',
                      Icons.business_center,
                      AppColors.textSecondary,
                    ),
                    const SizedBox(height: 8),
                    _buildMetricCard(
                      'Net Profit',
                      'Rs. ${(_totalIncome - _totalExpenses).toStringAsFixed(0)}',
                      Icons.account_balance_wallet,
                      _totalIncome - _totalExpenses >= 0 ? AppColors.success : AppColors.error,
                    ),
                  ],
                ),
              
              const SizedBox(height: 24),
              
              // Bar Chart Section
              if (!_isLoadingMetrics && _chartData.isNotEmpty) ...[
                const Text(
                  'Trends',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 250,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Legend
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildLegendItem('Expenses', AppColors.error),
                          const SizedBox(width: 20),
                          _buildLegendItem('Income', AppColors.success),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Chart
                      Expanded(
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: _getMaxY(),
                            barTouchData: BarTouchData(
                              enabled: true,
                              touchTooltipData: BarTouchTooltipData(
                                getTooltipColor: (_) => Colors.black87,
                                tooltipPadding: const EdgeInsets.all(8),
                                tooltipMargin: 8,
                                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                  String label = rodIndex == 0 ? 'Expenses' : 'Income';
                                  return BarTooltipItem(
                                    '$label\nRs. ${rod.toY.toStringAsFixed(0)}',
                                    const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  );
                                },
                              ),
                            ),
                            titlesData: FlTitlesData(
                              show: true,
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        _getBottomTitle(value.toInt()),
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    );
                                  },
                                  reservedSize: 30,
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 45,
                                  getTitlesWidget: (value, meta) {
                                    if (value == 0) return const Text('0');
                                    return Text(
                                      _formatCurrency(value),
                                      style: const TextStyle(fontSize: 10),
                                    );
                                  },
                                ),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            barGroups: _chartData,
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              horizontalInterval: _getMaxY() / 5,
                              getDrawingHorizontalLine: (value) {
                                return FlLine(
                                  color: Colors.grey.withOpacity(0.2),
                                  strokeWidth: 1,
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
              
              // Quick Access Section
              const Text(
                'Quick Access',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              
              // 3x3 Grid
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
                children: [
                  _buildQuickAccessButton(
                    'Expense\nCategories',
                    Icons.category,
                    AppColors.primary,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ExpenseCategoriesListScreen(),
                      ),
                    ),
                  ),
                  _buildQuickAccessButton(
                    'Log\nExpense',
                    Icons.receipt_long,
                    AppColors.error,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ExpensesListScreen(),
                      ),
                    ),
                  ),
                  _buildQuickAccessButton(
                    'Income\nRecords',
                    Icons.attach_money,
                    AppColors.success,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const IncomeListScreen(),
                      ),
                    ),
                  ),
                  _buildQuickAccessButton(
                    'Equipment',
                    Icons.build,
                    Colors.orange,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EquipmentListScreen(),
                      ),
                    ),
                  ),
                  _buildQuickAccessButton(
                    'Production\nData',
                    Icons.analytics,
                    AppColors.info,
                    () {
                      // TODO: Create ProductionListScreen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Production screen coming soon')),
                      );
                    },
                  ),
                  _buildQuickAccessButton(
                    'Clients',
                    Icons.business,
                    AppColors.secondary,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ClientsListScreen(),
                      ),
                    ),
                  ),
                  _buildQuickAccessButton(
                    'Partners',
                    Icons.handshake,
                    AppColors.success,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PartnersListScreen(),
                      ),
                    ),
                  ),
                  _buildQuickAccessButton(
                    'Workers',
                    Icons.people,
                    Colors.purple,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const WorkersListScreen(),
                      ),
                    ),
                  ),
                  _buildQuickAccessButton(
                    'Truck\nDeliveries',
                    Icons.local_shipping,
                    Colors.deepOrange,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TruckDeliveriesListScreen(),
                      ),
                    ),
                  ),
                  _buildQuickAccessButton(
                    'Users\nManagement',
                    Icons.admin_panel_settings,
                    Colors.indigo,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const UsersListScreen(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodChip(String period) {
    final isSelected = _selectedPeriod == period;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedPeriod = period);
        _loadMetrics();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.textSecondary.withOpacity(0.3),
          ),
        ),
        child: Text(
          period,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
  
  double _getMaxY() {
    if (_chartData.isEmpty) return 100;
    
    double max = 0;
    for (var group in _chartData) {
      for (var rod in group.barRods) {
        if (rod.toY > max) max = rod.toY;
      }
    }
    
    // Add 20% padding to max value
    return max * 1.2 > 0 ? max * 1.2 : 100;
  }
  
  String _getBottomTitle(int index) {
    final now = DateTime.now();
    
    if (_selectedPeriod == 'Today') {
      // Last 7 days - show day names
      final date = now.subtract(Duration(days: 6 - index));
      final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
      return days[date.weekday % 7];
    } else if (_selectedPeriod == 'Week') {
      // Last 4 weeks
      return 'W${index + 1}';
    } else if (_selectedPeriod == 'Month') {
      // Last 6 months - show month names
      final monthDate = DateTime(now.year, now.month - (5 - index), 1);
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return months[monthDate.month - 1];
    } else if (_selectedPeriod == 'Year') {
      // Last 12 months - show month names
      final monthDate = DateTime(now.year, now.month - (11 - index), 1);
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return months[monthDate.month - 1];
    } else if (_selectedPeriod == 'Max') {
      // Years
      final years = <int>{};
      // This will be populated from actual data
      return '${2020 + index}'; // Placeholder
    }
    
    return '';
  }
  
  String _formatCurrency(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }
}
