import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../core/constants/app_colors.dart';
import '../../models/equipment.dart';
import '../../services/equipment_service.dart';
import 'equipment_detail_screen.dart';
import 'equipment_form_screen.dart';

class EquipmentListScreen extends StatefulWidget {
  const EquipmentListScreen({super.key});

  @override
  State<EquipmentListScreen> createState() => _EquipmentListScreenState();
}

class _EquipmentListScreenState extends State<EquipmentListScreen> {
  final EquipmentService _equipmentService = EquipmentService();
  final RefreshController _refreshController = RefreshController();
  List<EquipmentModel> _equipment = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadEquipment();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _loadEquipment() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final equipment = await _equipmentService.getAllEquipment();
      setState(() {
        _equipment = equipment;
        _isLoading = false;
      });
      _refreshController.refreshCompleted();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      _refreshController.refreshFailed();
    }
  }

  Future<void> _navigateToDetail(EquipmentModel equipment) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EquipmentDetailScreen(equipment: equipment),
      ),
    );
    if (result == true) _loadEquipment();
  }

  Future<void> _navigateToForm([EquipmentModel? equipment]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EquipmentFormScreen(equipment: equipment),
      ),
    );
    if (result == true) _loadEquipment();
  }

  Future<void> _deleteEquipment(EquipmentModel equipment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_rounded, color: AppColors.error),
            SizedBox(width: 12),
            Text('Delete Equipment'),
          ],
        ),
        content: Text('Are you sure you want to delete "${equipment.name}"?'),
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
        await _equipmentService.deleteEquipment(equipment.id!);
        _loadEquipment();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Equipment deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'operational':
        return AppColors.success;
      case 'maintenance':
        return AppColors.warning;
      case 'out of service':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getEquipmentIcon(String? type) {
    if (type == null) return Icons.build;
    switch (type.toLowerCase()) {
      case 'excavator':
        return Icons.construction;
      case 'truck':
        return Icons.local_shipping;
      case 'drill':
        return Icons.handyman;
      default:
        return Icons.build;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Equipment'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToForm(),
        icon: const Icon(Icons.add),
        label: const Text('Add Equipment'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                      const SizedBox(height: 16),
                      Text('Error: $_error'),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _loadEquipment,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _equipment.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.build_circle_outlined,
                            size: 64,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No equipment yet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Tap the + button to add equipment',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    )
                  : SmartRefresher(
                      controller: _refreshController,
                      onRefresh: _loadEquipment,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _equipment.length,
                        itemBuilder: (context, index) {
                          final item = _equipment[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: InkWell(
                              onTap: () => _navigateToDetail(item),
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        _getEquipmentIcon(item.type),
                                        size: 24,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  item.name,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: _getStatusColor(item.status),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  item.status,
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          if (item.type != null) ...[
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.category,
                                                  size: 14,
                                                  color: AppColors.textSecondary,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  item.type!,
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    color: AppColors.textSecondary,
                                                  ),
                                                ),
                                                if (item.model != null) ...[
                                                  const Text(
                                                    ' • ',
                                                    style: TextStyle(
                                                      color: AppColors.textSecondary,
                                                    ),
                                                  ),
                                                  Text(
                                                    item.model!,
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      color: AppColors.textSecondary,
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                          ],
                                          if (item.siteName != null) ...[
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.location_on,
                                                  size: 14,
                                                  color: AppColors.textSecondary,
                                                ),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    item.siteName!,
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      color: AppColors.textSecondary,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                          if (item.serialNumber != null) ...[
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.tag,
                                                  size: 14,
                                                  color: AppColors.textSecondary,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'SN: ${item.serialNumber}',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: AppColors.textSecondary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    PopupMenuButton<String>(
                                      onSelected: (value) {
                                        if (value == 'view') {
                                          _navigateToDetail(item);
                                        } else if (value == 'edit') {
                                          _navigateToForm(item);
                                        } else if (value == 'delete') {
                                          _deleteEquipment(item);
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'view',
                                          child: Row(
                                            children: [
                                              Icon(Icons.visibility, size: 18),
                                              SizedBox(width: 12),
                                              Text('View Details'),
                                            ],
                                          ),
                                        ),
                                        const PopupMenuItem(
                                          value: 'edit',
                                          child: Row(
                                            children: [
                                              Icon(Icons.edit, size: 18),
                                              SizedBox(width: 12),
                                              Text('Edit'),
                                            ],
                                          ),
                                        ),
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              Icon(Icons.delete, size: 18, color: AppColors.error),
                                              SizedBox(width: 12),
                                              Text(
                                                'Delete',
                                                style: TextStyle(color: AppColors.error),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
