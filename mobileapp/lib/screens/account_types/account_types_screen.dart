import 'package:flutter/material.dart';
import '../../models/account_type.dart';
import '../../services/account_type_service.dart';
import 'account_type_form_screen.dart';

class AccountTypesScreen extends StatefulWidget {
  const AccountTypesScreen({Key? key}) : super(key: key);

  @override
  State<AccountTypesScreen> createState() => _AccountTypesScreenState();
}

class _AccountTypesScreenState extends State<AccountTypesScreen> {
  final AccountTypeService _service = AccountTypeService();
  List<AccountType> _accountTypes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAccountTypes();
  }

  Future<void> _loadAccountTypes() async {
    setState(() => _isLoading = true);
    try {
      final types = await _service.getAll();
      setState(() {
        _accountTypes = types;
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
      _loadAccountTypes();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account type deleted successfully')),
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
        title: const Text('Account Types'),
        backgroundColor: Colors.blue,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AccountTypeFormScreen(),
            ),
          );
          if (result == true) _loadAccountTypes();
        },
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _accountTypes.isEmpty
              ? const Center(
                  child: Text('No account types found\nTap + to add one'),
                )
              : RefreshIndicator(
                  onRefresh: _loadAccountTypes,
                  child: ListView.builder(
                    itemCount: _accountTypes.length,
                    itemBuilder: (context, index) {
                      final type = _accountTypes[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                type.isActive ? Colors.green : Colors.grey,
                            child: const Icon(
                              Icons.account_balance_outlined,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            type.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: type.description != null
                              ? Text(type.description!)
                              : null,
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
                                        AccountTypeFormScreen(accountType: type),
                                  ),
                                );
                                if (result == true) _loadAccountTypes();
                              } else if (value == 'delete') {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Confirm Delete'),
                                    content: Text(
                                        'Are you sure you want to delete "${type.name}"?'),
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
                                if (confirm == true) _delete(type.id);
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
