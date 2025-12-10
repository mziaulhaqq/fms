import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../models/truck_delivery.dart';
import '../../services/truck_delivery_service.dart';

class TruckDeliveriesListScreen extends StatefulWidget {
  const TruckDeliveriesListScreen({super.key});

  @override
  State<TruckDeliveriesListScreen> createState() => _TruckDeliveriesListScreenState();
}

class _TruckDeliveriesListScreenState extends State<TruckDeliveriesListScreen> {
  final _deliveryService = TruckDeliveryService();
  List<TruckDelivery> _deliveries = [];
  List<TruckDelivery> _filteredDeliveries = [];
  bool _isLoading = false;
  String? _error;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDeliveries();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDeliveries() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final deliveries = await _deliveryService.getAllTruckDeliveries();
      setState(() {
        _deliveries = deliveries;
        _filteredDeliveries = deliveries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterDeliveries(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredDeliveries = _deliveries;
      } else {
        _filteredDeliveries = _deliveries.where((delivery) {
          return delivery.buyerName.toLowerCase().contains(query.toLowerCase()) ||
              delivery.vehicleNumber.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
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
          'Truck Deliveries',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.secondary, size: 28),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Coming soon!')),
              );
            },
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
                hintText: 'Search Deliveries',
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
              onChanged: _filterDeliveries,
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
                      : _filteredDeliveries.isEmpty
                          ? _buildEmptyWidget()
                          : _buildDeliveryList(),
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
              onPressed: _loadDeliveries,
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
          Icon(Icons.local_shipping_outlined, size: 64, color: Colors.grey.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            'No truck deliveries found',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to add a new delivery',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryList() {
    return RefreshIndicator(
      onRefresh: _loadDeliveries,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _filteredDeliveries.length,
        itemBuilder: (context, index) {
          final delivery = _filteredDeliveries[index];
          return _buildDeliveryCard(delivery);
        },
      ),
    );
  }

  Widget _buildDeliveryCard(TruckDelivery delivery) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.local_shipping,
                color: AppColors.secondary,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    delivery.buyerName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 12, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('MMM dd, yyyy').format(delivery.deliveryDate),
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.scale, size: 12, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        '${delivery.quantityTons} tons',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.attach_money, size: 12, color: Colors.grey.shade600),
                      Text(
                        '\$${delivery.totalPrice}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            if (delivery.status != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: delivery.status == 'completed'
                      ? AppColors.success.withOpacity(0.1)
                      : AppColors.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  delivery.status!,
                  style: TextStyle(
                    fontSize: 11,
                    color: delivery.status == 'completed'
                        ? AppColors.success
                        : AppColors.secondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
