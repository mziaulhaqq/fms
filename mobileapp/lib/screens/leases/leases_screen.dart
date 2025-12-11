import 'package:flutter/material.dart';
import '../../models/lease.dart';
import '../../services/lease_service.dart';
import 'lease_form_screen.dart';

class LeasesScreen extends StatefulWidget {
  const LeasesScreen({Key? key}) : super(key: key);

  @override
  State<LeasesScreen> createState() => _LeasesScreenState();
}

class _LeasesScreenState extends State<LeasesScreen> {
  final LeaseService _service = LeaseService();
  List<Lease> _leases = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLeases();
  }

  Future<void> _loadLeases() async {
    setState(() => _isLoading = true);
    try {
      final leases = await _service.getAll();
      setState(() {
        _leases = leases;
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
      _loadLeases();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lease deleted successfully')),
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
        title: const Text('Leases'),
        backgroundColor: Colors.blue,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LeaseFormScreen(),
            ),
          );
          if (result == true) _loadLeases();
        },
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _leases.isEmpty
              ? const Center(
                  child: Text('No leases found\nTap + to add one'),
                )
              : RefreshIndicator(
                  onRefresh: _loadLeases,
                  child: ListView.builder(
                    itemCount: _leases.length,
                    itemBuilder: (context, index) {
                      final lease = _leases[index];
                      final sitesCount =
                          lease.miningSites?.length ?? 0;
                      final partnersCount = lease.partners?.length ?? 0;
                      
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                lease.isActive ? Colors.green : Colors.grey,
                            child: const Icon(
                              Icons.landscape_outlined,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            lease.leaseName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (lease.location != null) Text(lease.location!),
                              Text(
                                '$sitesCount mining sites • $partnersCount partners',
                                style: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          isThreeLine: lease.location != null,
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
                                        LeaseFormScreen(lease: lease),
                                  ),
                                );
                                if (result == true) _loadLeases();
                              } else if (value == 'delete') {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Confirm Delete'),
                                    content: Text(
                                        'Are you sure you want to delete "${lease.leaseName}"?'),
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
                                if (confirm == true) _delete(lease.id);
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
