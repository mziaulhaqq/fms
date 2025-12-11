import 'package:flutter/material.dart';
import '../../models/general_ledger.dart';
import '../../services/general_ledger_service.dart';
import '../../services/mining_site_service.dart';
import '../../services/account_type_service.dart';

class GeneralLedgerFormScreen extends StatefulWidget {
  final GeneralLedger? account;

  const GeneralLedgerFormScreen({Key? key, this.account}) : super(key: key);

  @override
  State<GeneralLedgerFormScreen> createState() =>
      _GeneralLedgerFormScreenState();
}

class _GeneralLedgerFormScreenState extends State<GeneralLedgerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final GeneralLedgerService _service = GeneralLedgerService();
  final MiningSiteService _siteService = MiningSiteService();
  final AccountTypeService _accountTypeService = AccountTypeService();

  late TextEditingController _accountCodeController;
  late TextEditingController _accountNameController;
  int? _accountTypeId;
  int? _miningSiteId;
  bool _isActive = true;
  bool _isSubmitting = false;
  List<Map<String, dynamic>> _miningSites = [];
  List<Map<String, dynamic>> _accountTypes = [];

  @override
  void initState() {
    super.initState();
    _accountCodeController =
        TextEditingController(text: widget.account?.accountCode ?? '');
    _accountNameController =
        TextEditingController(text: widget.account?.accountName ?? '');
    _accountTypeId = widget.account?.accountTypeId;
    _miningSiteId = widget.account?.miningSiteId;
    _isActive = widget.account?.isActive ?? true;
    _loadDropdownData();
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final data = {
        'accountCode': _accountCodeController.text.trim(),
        'accountName': _accountNameController.text.trim(),
        'accountTypeId': _accountTypeId,
        'miningSiteId': _miningSiteId,
        'isActive': _isActive,
      };

      if (widget.account != null) {
        await _service.update(widget.account!.id, data);
      } else {
        await _service.create(data);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _accountCodeController.dispose();
    _accountNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.account != null ? 'Edit Account' : 'New Account'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
      ),
      body: _isSubmitting
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _accountCodeController,
                      decoration: const InputDecoration(
                        labelText: 'Account Code *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.qr_code),
                      ),
                      textCapitalization: TextCapitalization.characters,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Account code is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _accountNameController,
                      decoration: const InputDecoration(
                        labelText: 'Account Name *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.account_balance),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Account name is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: _accountTypeId,
                      decoration: const InputDecoration(
                        labelText: 'Account Type *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: _accountTypes.map((type) {
                        return DropdownMenuItem<int>(
                          value: type['id'],
                          child: Text(type['name']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _accountTypeId = value);
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select an account type';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: _miningSiteId,
                      decoration: const InputDecoration(
                        labelText: 'Mining Site *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      items: _miningSites.map((site) {
                        return DropdownMenuItem<int>(
                          value: site['id'],
                          child: Text(site['mineNumber']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _miningSiteId = value);
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a mining site';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Active'),
                      value: _isActive,
                      onChanged: (value) {
                        setState(() => _isActive = value);
                      },
                      secondary: Icon(
                        _isActive ? Icons.check_circle : Icons.cancel,
                        color: _isActive ? Colors.green : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textOnPrimary,
                      ),
                      child: Text(
                        widget.account != null ? 'Update Account' : 'Create Account',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
