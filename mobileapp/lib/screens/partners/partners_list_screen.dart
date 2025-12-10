import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/partner.dart';
import '../../services/partner_service.dart';
import 'partner_form_screen.dart';
import 'partner_detail_screen.dart';

class PartnersListScreen extends StatefulWidget {
  const PartnersListScreen({super.key});

  @override
  State<PartnersListScreen> createState() => _PartnersListScreenState();
}

class _PartnersListScreenState extends State<PartnersListScreen> {
  final _partnerService = PartnerService();
  List<Partner> _partners = [];
  List<Partner> _filteredPartners = [];
  bool _isLoading = false;
  String? _error;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPartners();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPartners() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final partners = await _partnerService.getAllPartners();
      setState(() {
        _partners = partners;
        _filteredPartners = partners;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterPartners(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredPartners = _partners;
      } else {
        _filteredPartners = _partners.where((partner) {
          return partner.name.toLowerCase().contains(query.toLowerCase()) ||
              (partner.cnic.toLowerCase().contains(query.toLowerCase()));
        }).toList();
      }
    });
  }

  Future<void> _navigateToDetail(Partner partner) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PartnerDetailScreen(partner: partner)),
    );
    if (result == true) _loadPartners();
  }

  Future<void> _navigateToForm([Partner? partner]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PartnerFormScreen(partner: partner)),
    );
    if (result == true) _loadPartners();
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
          'Partner Management',
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
          // Search Bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            color: AppColors.primary,
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search Partners',
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
              onChanged: _filterPartners,
            ),
          ),
          
          // Partner List
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
                      : _filteredPartners.isEmpty
                          ? _buildEmptyWidget()
                          : _buildPartnerList(),
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
              onPressed: _loadPartners,
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
          Icon(Icons.handshake_outlined, size: 64, color: Colors.grey.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            'No partners found',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to add a new partner',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildPartnerList() {
    return RefreshIndicator(
      onRefresh: _loadPartners,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _filteredPartners.length,
        itemBuilder: (context, index) {
          final partner = _filteredPartners[index];
          return _buildPartnerCard(partner);
        },
      ),
    );
  }

  Widget _buildPartnerCard(Partner partner) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _navigateToDetail(partner),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Partner Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.handshake,
                  color: AppColors.success,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              
              // Partner Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            partner.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!partner.isActive)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Inactive',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.credit_card, size: 12, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          partner.cnic,
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                    if (partner.sharePercentage != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.pie_chart, size: 12, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(
                            'Share: ${partner.sharePercentage}%',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              
              // Arrow Icon
              Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}
