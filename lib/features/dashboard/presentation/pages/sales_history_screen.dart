import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fk_salesman/core/constants/app_colors.dart';
import 'package:fk_salesman/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:fk_salesman/features/dashboard/domain/models/sales_history_model.dart';
import 'package:go_router/go_router.dart';

class SalesHistoryScreen extends StatefulWidget {
  const SalesHistoryScreen({super.key});

  @override
  State<SalesHistoryScreen> createState() => _SalesHistoryScreenState();
}

class _SalesHistoryScreenState extends State<SalesHistoryScreen> {
  String _selectedFilter = "All";
  final List<String> _filters = ["All", "Sales", "Testing", "MS", "HSD", "Today"];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().fetchSalesHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DashboardProvider>();
    final allRecords = provider.salesHistory;

    final records = allRecords.where((record) {
      if (_selectedFilter == "All") return true;
      if (_selectedFilter == "Sales") return record.salesType == "fuel";
      if (_selectedFilter == "Testing") return record.salesType == "test";
      if (_selectedFilter == "MS") return record.fuelTypeCode == "MS";
      if (_selectedFilter == "HSD") return record.fuelTypeCode == "HSD";
      if (_selectedFilter == "Today") {
        final now = DateTime.now();
        try {
          final dt = DateTime.parse(record.timestamp);
          return dt.year == now.year && dt.month == now.month && dt.day == now.day;
        } catch (_) {
          return false;
        }
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          "SALES HISTORY",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Header Summary Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 20),
            decoration: const BoxDecoration(
              color: AppColors.primary,
            ),
            child: Row(
              children: [
                _buildStatItem("Filtered", "${records.length}"),
                const SizedBox(width: 32),
                _buildStatItem("Filtered Qty", records.fold(0.0, (sum, item) => sum + item.qty).toStringAsFixed(2)),
              ],
            ),
          ),

          // YouTube Style Filters
          Container(
            color: AppColors.primary,
            child: Container(
              height: 60,
              decoration: const BoxDecoration(
                color: Color(0xFFF8F9FA),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _filters.length,
                itemBuilder: (context, index) {
                  final filter = _filters[index];
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                    child: FilterChip(
                      label: Text(
                        filter,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                          color: isSelected ? Colors.white : AppColors.textDark.withOpacity(0.6),
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      },
                      backgroundColor: Colors.white,
                      selectedColor: AppColors.primary,
                      checkmarkColor: Colors.white,
                      elevation: 1,
                      pressElevation: 3,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected ? AppColors.primary : Colors.black.withOpacity(0.05),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          Expanded(
            child: provider.isLoading && allRecords.isEmpty
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : records.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: () => provider.fetchSalesHistory(),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: records.length,
                          itemBuilder: (context, index) {
                            final record = records[index];
                            return _buildSaleCard(record);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_outlined, size: 60, color: AppColors.textDark.withOpacity(0.1)),
          const SizedBox(height: 16),
          Text(
            "No sales history found",
            style: TextStyle(color: AppColors.textDark.withOpacity(0.4), fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  String _getFuelCode(int id) {
    switch (id) {
      case 1:
        return "MS";
      case 2:
        return "HSD";
      case 3:
        return "XP/MS";
      default:
        return "FT-$id";
    }
  }

  Widget _buildSaleCard(SaleRecord record) {
    bool isTest = record.salesType.toLowerCase() == 'test';
    final typeColor = isTest ? Colors.blue : Colors.green;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Compact Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isTest ? Icons.biotech_rounded : Icons.local_gas_station_rounded,
                      color: typeColor.withOpacity(0.6),
                      size: 14,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Nozzle #${record.nozzleCode ?? record.salesmanNozzleId}",
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.textDark),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      record.formattedDate,
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black26),
                    ),
                  ],
                ),
                _buildStatusBadge(record.salesType.toUpperCase(), typeColor),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(height: 1, color: Color(0xFFF1F3F5)),
            const SizedBox(height: 12),
            
            // Amount & Qty in one row with minimal styling
            Row(
              children: [
                _buildCompactMetric("AMOUNT", "₹${record.amountPaid.toStringAsFixed(2)}", AppColors.primary),
                const SizedBox(width: 24),
                _buildCompactMetric("QTY", "${record.qty.toStringAsFixed(2)} L", Colors.blueAccent),
                const Spacer(),
                _buildCompactMetric("FUEL", record.fuelTypeCode ?? _getFuelCode(record.fuelTypeId), Colors.black54),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFF1F3F5)),
            const SizedBox(height: 10),
            
            // Other details in tight list
          //  _buildInfoRow(Icons.adjust_rounded, "Nozzle", "#${record.nozzleCode ?? record.salesmanNozzleId}"),
            _buildInfoRow(Icons.history_toggle_off_rounded, "Shift", record.workShiftName ?? "General"),
            _buildInfoRow(Icons.account_balance_wallet_rounded, "Payment", record.paymentMethodName ?? "N/A"),
            _buildInfoRow(Icons.schedule_rounded, "Created At", record.formattedCreatedAt),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 8,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildCompactMetric(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.black26, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 0.5),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: color),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 10, color: Colors.black12),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(color: Colors.black26, fontSize: 10, fontWeight: FontWeight.w800),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(color: AppColors.textDark, fontSize: 10, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
