import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../models/production.dart';
import '../../services/production_service.dart';
import 'production_form_screen.dart';
import 'production_detail_screen.dart';

class ProductionListScreen extends StatefulWidget {
  const ProductionListScreen({super.key});

  @override
  State<ProductionListScreen> createState() => _ProductionListScreenState();
}

class _ProductionListScreenState extends State<ProductionListScreen> {
  final _productionService = ProductionService();
  List<Production> _production = [];
  List<Production> _filteredProduction = [];
  bool _isLoading = false;
  String? _error;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProduction();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProduction() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final production = await _productionService.getAllProduction();
      setState(() {
        _production = production;
        _filteredProduction = production;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterProduction(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredProduction = _production;
      } else {
        _filteredProduction = _production.where((prod) {
          return (prod.quality?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
              (prod.shift?.toLowerCase().contains(query.toLowerCase()) ?? false);
        }).toList();
      }
    });
  }

  Future<void> _navigateToDetail(Production production) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProductionDetailScreen(production: production)),
    );
    if (result == true) _loadProduction();
  }

  Future<void> _navigateToForm([Production? production]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProductionFormScreen(production: production)),
    );
    if (result == true) _loadProduction();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.secondary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Production Records',
          style: TextStyle(color: Colors.white, fontSize: 18),
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
          Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            color: AppColors.primary,
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search Production',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
                prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.5), size: 20),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: _filterProduction,
            ),
          ),
          
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(0),
                  topRight: Radius.circular(0),
                ),
              ),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? _buildErrorWidget()
                      : _filteredProduction.isEmpty
                          ? _buildEmptyWidget()
                          : _buildProductionList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              _error ?? 'An error occurred',
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadProduction,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              ),
              child: const Text('Retry', style: TextStyle(fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics_outlined, size: 64, color: Colors.grey.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            'No production records found',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to add a new production record',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildProductionList() {
    return RefreshIndicator(
      onRefresh: _loadProduction,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _filteredProduction.length,
        itemBuilder: (context, index) {
          final production = _filteredProduction[index];
          return _buildProductionCard(production);
        },
      ),
    );
  }

  Widget _buildProductionCard(Production production) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _navigateToDetail(production),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.analytics,
                  color: AppColors.info,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('MMM dd, yyyy').format(production.date),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.scale, size: 12, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          '${production.quantity} tons',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                        if (production.shift != null) ...[
                          const SizedBox(width: 12),
                          Icon(Icons.schedule, size: 12, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(
                            production.shift!,
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ],
                    ),
                    if (production.quality != null) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          production.quality!,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.success,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}
