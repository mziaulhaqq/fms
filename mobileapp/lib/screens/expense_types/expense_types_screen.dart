import 'package:flutter/material.dart';
import '../../models/expense_type.dart';
import '../../services/expense_type_service.dart';
import 'expense_type_form_screen.dart';

class ExpenseTypesScreen extends StatefulWidget {
  const ExpenseTypesScreen({Key? key}) : super(key: key);

  @override
  State<ExpenseTypesScreen> createState() => _ExpenseTypesScreenState();
}

class _ExpenseTypesScreenState extends State<ExpenseTypesScreen> {
  final ExpenseTypeService _service = ExpenseTypeService();
  List<ExpenseType> _expenseTypes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExpenseTypes();
  }

  Future<void> _loadExpenseTypes() async {
    setState(() => _isLoading = true);
    try {
      final types = await _service.getAll();
      setState(() {
        _expenseTypes = types;
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
      _loadExpenseTypes();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expense type deleted successfully')),
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
        title: const Text('Expense Types'),
        backgroundColor: Colors.blue,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ExpenseTypeFormScreen(),
            ),
          );
          if (result == true) _loadExpenseTypes();
        },
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _expenseTypes.isEmpty
              ? const Center(
                  child: Text('No expense types found\nTap + to add one'),
                )
              : RefreshIndicator(
                  onRefresh: _loadExpenseTypes,
                  child: ListView.builder(
                    itemCount: _expenseTypes.length,
                    itemBuilder: (context, index) {
                      final type = _expenseTypes[index];
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
                              Icons.category_outlined,
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
                                        ExpenseTypeFormScreen(expenseType: type),
                                  ),
                                );
                                if (result == true) _loadExpenseTypes();
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
