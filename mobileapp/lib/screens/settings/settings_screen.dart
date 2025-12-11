import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Management'),
        backgroundColor: Colors.blue,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Type Management'),
          _buildSettingTile(
            context,
            icon: Icons.people_outline,
            title: 'Client Types',
            subtitle: 'Manage client types (Coal Agent, Bhatta, Factory)',
            onTap: () => Navigator.pushNamed(context, '/client-types'),
          ),
          _buildSettingTile(
            context,
            icon: Icons.category_outlined,
            title: 'Expense Types',
            subtitle: 'Manage expense types (Worker, Vendor)',
            onTap: () => Navigator.pushNamed(context, '/expense-types'),
          ),
          _buildSettingTile(
            context,
            icon: Icons.account_balance_outlined,
            title: 'Account Types',
            subtitle: 'Manage account types (Asset, Liability, Revenue, etc.)',
            onTap: () => Navigator.pushNamed(context, '/account-types'),
          ),
          const Divider(height: 32),
          
          _buildSectionHeader('Financial Management'),
          _buildSettingTile(
            context,
            icon: Icons.book_outlined,
            title: 'General Ledger',
            subtitle: 'Manage chart of accounts per mining site',
            onTap: () => Navigator.pushNamed(context, '/general-ledger'),
          ),
          _buildSettingTile(
            context,
            icon: Icons.money_off_outlined,
            title: 'Liabilities',
            subtitle: 'Manage loans and advanced payments',
            onTap: () => Navigator.pushNamed(context, '/liabilities'),
          ),
          const Divider(height: 32),
          
          _buildSectionHeader('Lease Management'),
          _buildSettingTile(
            context,
            icon: Icons.landscape_outlined,
            title: 'Leases',
            subtitle: 'Manage coal mine leases',
            onTap: () => Navigator.pushNamed(context, '/leases'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue, size: 32),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
