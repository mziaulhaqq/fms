import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/worker.dart';
import '../../services/worker_service.dart';
import 'worker_form_screen.dart';
import 'worker_detail_screen.dart';

class WorkersListScreen extends StatefulWidget {
  const WorkersListScreen({super.key});

  @override
  State<WorkersListScreen> createState() => _WorkersListScreenState();
}

class _WorkersListScreenState extends State<WorkersListScreen> {
  final _workerService = WorkerService();
  List<Worker> _workers = [];
  List<Worker> _filteredWorkers = [];
  bool _isLoading = false;
  String? _error;
  final TextEditingController _searchController = TextEditingController();
  bool _showActiveOnly = true;

  @override
  void initState() {
    super.initState();
    _loadWorkers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadWorkers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final workers = await _workerService.getAllWorkers();
      setState(() {
        _workers = workers;
        _filterWorkers();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterWorkers() {
    setState(() {
      _filteredWorkers = _workers.where((worker) {
        final matchesSearch = _searchController.text.isEmpty ||
            worker.fullName.toLowerCase().contains(_searchController.text.toLowerCase()) ||
            (worker.role?.toLowerCase().contains(_searchController.text.toLowerCase()) ?? false);
        
        final matchesStatus = !_showActiveOnly || worker.isActive;
        
        return matchesSearch && matchesStatus;
      }).toList();
    });
  }

  Future<void> _navigateToDetail(Worker worker) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => WorkerDetailScreen(worker: worker)),
    );
    if (result == true) _loadWorkers();
  }

  Future<void> _navigateToForm([Worker? worker]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => WorkerFormScreen(worker: worker)),
    );
    if (result == true) _loadWorkers();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return AppColors.success;
      case 'inactive':
        return Colors.grey;
      default:
        return Colors.grey;
    }
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
          'Worker Management',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.secondary, size: 28),
            onPressed: () => _navigateToForm(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search Workers',
                prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) => _filterWorkers(),
            ),
          ),
          
          // Active/Inactive Tabs
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _showActiveOnly = true;
                        _filterWorkers();
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _showActiveOnly ? AppColors.primary : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                      child: Text(
                        'Active',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: _showActiveOnly ? FontWeight.bold : FontWeight.normal,
                          color: _showActiveOnly ? AppColors.primary : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _showActiveOnly = false;
                        _filterWorkers();
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: !_showActiveOnly ? AppColors.primary : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                      child: Text(
                        'Inactive',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: !_showActiveOnly ? FontWeight.bold : FontWeight.normal,
                          color: !_showActiveOnly ? AppColors.primary : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Worker List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? _buildErrorWidget()
                    : _filteredWorkers.isEmpty
                        ? _buildEmptyWidget()
                        : _buildWorkerList(),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkerList() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _filteredWorkers.length,
      itemBuilder: (context, index) {
        final worker = _filteredWorkers[index];
        // Get first 2 letters for avatar with null safety
        String initials = 'W';
        if (worker.fullName.isNotEmpty) {
          initials = worker.fullName.length >= 2
              ? worker.fullName.substring(0, 2).toUpperCase()
              : worker.fullName.substring(0, 1).toUpperCase();
        }
        
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _navigateToDetail(worker),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  // Profile Photo/Avatar
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    backgroundImage: worker.photoUrl != null 
                        ? NetworkImage(worker.photoUrl!)
                        : null,
                    child: worker.photoUrl == null
                        ? Text(
                            initials,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  
                  // Worker Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          worker.fullName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (worker.role != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            worker.role!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                        const SizedBox(height: 4),
                        // Status Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _getStatusColor(worker.status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _getStatusColor(worker.status).withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            worker.status,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: _getStatusColor(worker.status),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Chevron
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            _showActiveOnly ? 'No active workers' : 'No inactive workers',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap the + button to add a worker',
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
            onPressed: _loadWorkers,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
