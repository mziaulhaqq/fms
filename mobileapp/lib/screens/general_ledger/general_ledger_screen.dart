import 'package:flutter/material.dart';
import '../../models/general_ledger.dart';
import '../../services/general_ledger_service.dart';
import '../../services/mining_site_service.dart';
import '../../services/account_type_service.dart';
import '../../core/constants/app_colors.dart';
import 'general_ledger_form_screen.dart';

class GeneralLedgerScreen extends StatefulWidget {
  const GeneralLedgerScreen({Key? key}) : super(key: key);

  @override
  State<GeneralLedgerScreen> createState() => _GeneralLedgerScreenState();
}

class _GeneralLedgerScreenState extends State<GeneralLedgerScreen> {
  final GeneralLedgerService _service = GeneralLedgerService();
  final MiningSiteService _siteService = MiningSiteService();
  final AccountTypeService _accountTypeService = AccountTypeService();
  
  List<GeneralLedger> _accounts = [];
  bool _isLoading = true;
  int? _selectedSiteId;
  int? _selectedAccountTypeId;
  List<Map<String, dynamic>> _miningSites = [];
  List<Map<String, dynamic>> _accountTypes = [];

  @override
  void initState() {
    super.initState();
    _loadDropdownData();
    _loadAccounts();
  }

  Future<void> _loadDropdownData() async {
    try {
      final sites = await _siteService.getMiningSites();
      final types = await _accountTypeService.getActive();
      setState(() {
        _miningSites = sites;
        _accountTypes = types.map((t) => {'id': t.id, 'name': t.name}).toList();
      });
    } catch (e) {
      // Handle error silently for dropdown data
    }
  }

  Future<void> _loadAccounts() async {
    setState(() => _isLoading = true);
    try {
      final accounts = await _service.getAll(
        miningSiteId: _selectedSiteId,
        accountTypeId: _selectedAccountTypeId,
      );
      setState(() {
        _accounts = accounts;
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
      _loadAccounts();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account deleted successfully')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('General Ledger'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const GeneralLedgerFormScreen(),
            ),
          );
          if (result == true) _loadAccounts();
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Filters
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade100,
            child: Column(
              children: [
                DropdownButtonFormField<int>(
                  value: _selectedSiteId,
                  decoration: const InputDecoration(
                    labelText: 'Filter by Mining Site',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: [
                    const DropdownMenuItem<int>(
                      value: null,
                      child: Text('All Sites'),
                    ),
                    ..._miningSites.map((site) {
                      return DropdownMenuItem<int>(
                        value: site['id'],
                        child: Text(site['mineNumber']),
                      );
                    }).toList(),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedSiteId = value);
                    _loadAccounts();
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  value: _selectedAccountTypeId,
                  decoration: const InputDecoration(
                    labelText: 'Filter by Account Type',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: [
                    const DropdownMenuItem<int>(
                      value: null,
                      child: Text('All Types'),
                    ),
                    ..._accountTypes.map((type) {
                      return DropdownMenuItem<int>(
                        value: type['id'],
                        child: Text(type['name']),
                      );
                    }).toList(),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedAccountTypeId = value);
                    _loadAccounts();
                  },
                ),
              ],
            ),
          ),
          // List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _accounts.isEmpty
                    ? const Center(
                        child: Text('No accounts found\nTap + to add one'),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadAccounts,
                        child: ListView.builder(
                          itemCount: _accounts.length,
                          itemBuilder: (context, index) {
                            final account = _accounts[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: account.isActive
                                      ? Colors.green
                                      : Colors.grey,
                                  child: Text(
                                    account.accountCode,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  account.accountName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Type: ${account.accountType?['name'] ?? 'N/A'}',
                                    ),
                                    Text(
                                      'Site: ${account.miningSite?['mineNumber'] ?? 'N/A'}',
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
                                              GeneralLedgerFormScreen(
                                                  account: account),
                                        ),
                                      );
                                      if (result == true) _loadAccounts();
                                    } else if (value == 'delete') {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Confirm Delete'),
                                          content: Text(
                                              'Are you sure you want to delete "${account.accountName}"?'),
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
                                      if (confirm == true) _delete(account.id);
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
