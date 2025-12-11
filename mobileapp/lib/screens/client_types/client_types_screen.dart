import 'package:flutter/material.dart';
import '../../models/client_type.dart';
import '../../services/client_type_service.dart';
import 'client_type_form_screen.dart';

class ClientTypesScreen extends StatefulWidget {
  const ClientTypesScreen({Key? key}) : super(key: key);

  @override
  State<ClientTypesScreen> createState() => _ClientTypesScreenState();
}

class _ClientTypesScreenState extends State<ClientTypesScreen> {
  final ClientTypeService _service = ClientTypeService();
  List<ClientType> _clientTypes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClientTypes();
  }

  Future<void> _loadClientTypes() async {
    setState(() => _isLoading = true);
    try {
      final types = await _service.getAll();
      setState(() {
        _clientTypes = types;
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
      _loadClientTypes();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Client type deleted successfully')),
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
        title: const Text('Client Types'),
        backgroundColor: Colors.blue,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ClientTypeFormScreen(),
            ),
          );
          if (result == true) _loadClientTypes();
        },
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _clientTypes.isEmpty
              ? const Center(
                  child: Text('No client types found\nTap + to add one'),
                )
              : RefreshIndicator(
                  onRefresh: _loadClientTypes,
                  child: ListView.builder(
                    itemCount: _clientTypes.length,
                    itemBuilder: (context, index) {
                      final type = _clientTypes[index];
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
                              Icons.people_outline,
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
                                        ClientTypeFormScreen(clientType: type),
                                  ),
                                );
                                if (result == true) _loadClientTypes();
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
