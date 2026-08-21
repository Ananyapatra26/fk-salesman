import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:fk_salesman/core/constants/app_colors.dart';
import 'package:fk_salesman/core/constants/app_text_styles.dart';
import '../providers/calculated_sales_provider.dart';
import '../../domain/models/calculated_sales_model.dart';

class CalculatedDetailsScreen extends StatefulWidget {
  const CalculatedDetailsScreen({super.key});

  @override
  State<CalculatedDetailsScreen> createState() => _CalculatedDetailsScreenState();
}

class _CalculatedDetailsScreenState extends State<CalculatedDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CalculatedSalesProvider>().fetchCalculatedSales();
    });
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            "Are you sure?",
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark),
          ),
          content: const Text(
            "Do you want to confirm these calculated details?",
            style: TextStyle(color: Colors.black54),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("No", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                context.pop(); // Go back to previous screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CalculatedSalesProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Calculated Details",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Header Accent
          Container(
            height: 20,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
          ),

          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : provider.error != null
                    ? _buildErrorState(provider.error!)
                    : provider.data == null
                        ? const Center(child: Text("No calculated details found"))
                        : _buildContent(provider.data!),
          ),

          // Bottom Section: Grand Total + Confirm Button
          if (provider.data != null && !provider.isLoading)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Smaller, fixed Grand Total Summary
                    _buildTotalCard(provider.data!.total),
                    
                    const SizedBox(height: 16),
                    
                    // Confirm Button
                    // SizedBox(
                    //   width: double.infinity,
                    //   height: 56,
                    //   child: ElevatedButton(
                    //     onPressed: () => _showConfirmationDialog(),
                    //     style: ElevatedButton.styleFrom(
                    //       backgroundColor: AppColors.primary,
                    //       foregroundColor: Colors.white,
                    //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    //       elevation: 4,
                    //       shadowColor: AppColors.primary.withOpacity(0.4),
                    //     ),
                    //     child: const Text(
                    //       "Confirm",
                    //       style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(
              "Error Fetching Data",
              style: AppTextStyles.h3.copyWith(color: Colors.redAccent),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.read<CalculatedSalesProvider>().fetchCalculatedSales(),
              child: const Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(CalculatedSalesData data) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      children: [
        // Nozzles Summary
        ...data.nozzles.map((nozzle) => _buildNozzleCard(nozzle)),
        
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildNozzleCard(NozzleCalculation nozzle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.black.withOpacity(0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.blueGrey[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.local_gas_station, color: Colors.blueGrey, size: 18),
                const SizedBox(width: 10),
                Text(
                  nozzle.nozzleName,
                  style: AppTextStyles.labelBold.copyWith(fontSize: 15, color: Colors.blueGrey[800]),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "Nozzle ${nozzle.nozzleCode}",
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          // Payment Methods
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              children: [
                ...nozzle.paymentMethodSales.map((sale) => _buildPaymentRow(sale.methodName, sale.salesAmount)),
                
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Divider(height: 1),
                ),
                
                _buildPaymentRow("Total", nozzle.totalSalesAmount, isTotal: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalCard(NozzleTotal total) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Simplified Grand Total (No Header)
          ...total.paymentMethodSales.map((sale) => _buildPaymentRow(sale.methodName, sale.salesAmount, onDark: true)),
          
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Divider(height: 1, color: Colors.white24),
          ),
          
          _buildPaymentRow("Grand Total", total.totalSalesAmount, isTotal: true, onDark: true),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(String label, double amount, {bool isTotal = false, bool onDark = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal 
               ? AppTextStyles.labelBold.copyWith(fontSize: 14, color: onDark ? Colors.white : AppColors.textDark)
               : AppTextStyles.bodyMedium.copyWith(fontSize: 12, color: onDark ? Colors.white.withOpacity(0.8) : Colors.black87, fontWeight: FontWeight.w600),
          ),
          Text(
            "₹${amount.toStringAsFixed(2)}",
            style: isTotal 
               ? AppTextStyles.h3.copyWith(fontSize: 16, color: onDark ? Colors.white : AppColors.primary)
               : AppTextStyles.labelBold.copyWith(fontSize: 13, color: onDark ? Colors.white : AppColors.textDark),
          ),
        ],
      ),
    );
  }
}
