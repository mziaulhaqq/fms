import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../models/role.dart';
import '../../services/role_service.dart';
import '../../core/constants/app_colors.dart';

class AssignRoleScreen extends StatefulWidget {
  final User user;

  const AssignRoleScreen({super.key, required this.user});

  @override
  State<AssignRoleScreen> createState() => _AssignRoleScreenState();
}

class _AssignRoleScreenState extends State<AssignRoleScreen> {
  final _roleService = RoleService();
  List<Role> _availableRoles = [];
  List<UserAssignedRole> _assignedRoles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final roles = await _roleService.getRoles();
      final userRoles = await _roleService.getUserRoles(widget.user.id!);
      
      setState(() {
        _availableRoles = roles;
        _assignedRoles = userRoles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading roles: $e')),
        );
      }
    }
  }

  bool _isRoleAssigned(int roleId) {
    return _assignedRoles.any((assignment) => 
      assignment.roleId == roleId && assignment.status == 'active'
    );
  }

  UserAssignedRole? _getAssignment(int roleId) {
    try {
      return _assignedRoles.firstWhere((assignment) => 
        assignment.roleId == roleId && assignment.status == 'active'
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> _toggleRole(Role role) async {
    try {
      if (_isRoleAssigned(role.id)) {
        // Remove role
        final assignment = _getAssignment(role.id);
        if (assignment != null) {
          await _roleService.removeRoleFromUser(assignment.id);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${role.name} role removed')),
            );
          }
        }
      } else {
        // Assign role
        await _roleService.assignRoleToUser(
          userId: widget.user.id!,
          roleId: role.id,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${role.name} role assigned')),
          );
        }
      }
      _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assign Roles'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // User info header
                Container(
                  padding: const EdgeInsets.all(16),
                  color: AppColors.primary.withOpacity(0.1),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.primary,
                        radius: 30,
                        child: Text(
                          widget.user.username[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.user.fullName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '@${widget.user.username}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              widget.user.email,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                
                // Roles list
                Expanded(
                  child: _availableRoles.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.security,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No roles available',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _availableRoles.length,
                          padding: const EdgeInsets.all(16),
                          itemBuilder: (context, index) {
                            final role = _availableRoles[index];
                            final isAssigned = _isRoleAssigned(role.id);
                            
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: isAssigned
                                        ? AppColors.success.withOpacity(0.2)
                                        : Colors.grey.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    _getRoleIcon(role.name),
                                    color: isAssigned
                                        ? AppColors.success
                                        : Colors.grey,
                                  ),
                                ),
                                title: Text(
                                  role.name.toUpperCase(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: role.description != null
                                    ? Text(role.description!)
                                    : null,
                                trailing: Switch(
                                  value: isAssigned,
                                  onChanged: role.isActive
                                      ? (value) => _toggleRole(role)
                                      : null,
                                  activeColor: AppColors.success,
                                ),
                                onTap: role.isActive
                                    ? () => _toggleRole(role)
                                    : null,
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  IconData _getRoleIcon(String roleName) {
    switch (roleName.toLowerCase()) {
      case 'admin':
        return Icons.admin_panel_settings;
      case 'supervisor':
        return Icons.supervisor_account;
      case 'accountant':
        return Icons.account_balance;
      case 'manager':
        return Icons.business_center;
      case 'viewer':
        return Icons.visibility;
      default:
        return Icons.person;
    }
  }
}
