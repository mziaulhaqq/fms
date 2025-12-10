import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import '../clients/clients_list_screen.dart';
import '../expense_categories/expense_categories_list_screen.dart';
import '../expenses/expenses_list_screen.dart';
import '../mining_sites/mining_sites_list_screen.dart';
import '../equipment/equipment_list_screen.dart';
import '../income/income_list_screen.dart';
import '../workers/workers_list_screen.dart';
import '../partners/partners_list_screen.dart';
import '../production/production_list_screen.dart';
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
  String? _userEmail;
  bool _isAdmin = false;
  bool _isLoadingRoles = true;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
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
            // Mining Sites - Admin only
            if (_isAdmin)
              ListTile(
                leading: const Icon(Icons.location_on, color: AppColors.primary),
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
            ListTile(
              leading: const Icon(Icons.local_shipping, color: AppColors.primary),
              title: const Text('Truck Deliveries'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TruckDeliveriesListScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.analytics, color: AppColors.primary),
              title: const Text('Production'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProductionListScreen(),
                  ),
                );
              },
            ),
            // Profit Distributions - Admin only
            if (_isAdmin)
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
            // Users - Admin only
            if (_isAdmin)
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
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: const Text('Logout'),
              onTap: _handleLogout,
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh dashboard data
          setState(() {});
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              
              // Metric Cards
              _buildMetricCard(
                'Total Expenses',
                '\$0.00',
                'MTD: \$0.00',
                'Today: \$0.00',
                Icons.trending_down,
                AppColors.error,
              ),
              const SizedBox(height: 10),
              _buildMetricCard(
                'Total Income',
                '\$0.00',
                'MTD: \$0.00',
                'Today: \$0.00',
                Icons.trending_up,
                AppColors.success,
              ),
              const SizedBox(height: 10),
              _buildMetricCard(
                'Total Production',
                '0 tons',
                'MTD: 0 tons',
                'Today: 0 tons',
                Icons.business_center,
                AppColors.secondary,
              ),
              
              const SizedBox(height: 24),
              
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
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ProductionListScreen(),
                      ),
                    ),
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

  Widget _buildMetricCard(
    String title,
    String value,
    String mtd,
    String today,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  mtd,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Text(
                today,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
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
}
