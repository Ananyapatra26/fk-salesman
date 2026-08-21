import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fk_salesman/core/constants/app_text_styles.dart';
import 'package:fk_salesman/core/constants/app_colors.dart';
import 'package:fk_salesman/core/widgets/glass_container.dart';
import 'package:fk_salesman/features/dashboard/presentation/providers/dashboard_provider.dart';

class SalesDetailsScreen extends StatefulWidget {
  final String nozzleCode;
  const SalesDetailsScreen({super.key, required this.nozzleCode});

  @override
  State<SalesDetailsScreen> createState() => _SalesDetailsScreenState();
}

class _SalesDetailsScreenState extends State<SalesDetailsScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final provider = context.read<DashboardProvider>();
    _amountController.text = provider.getAmount(widget.nozzleCode) ?? "";
    _quantityController.text = provider.getQuantity(widget.nozzleCode) ?? "";
  }

  @override
  void dispose() {
    _amountController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DashboardProvider>();
    // Find the nozzle by code in the full list or selected list
    final nozzle = provider.nozzles.firstWhere((n) => n.number == widget.nozzleCode);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1A1A1A),
                  Color(0xFF2D2D2D),
                  AppColors.primary,
                ],
                stops: [0.0, 0.6, 1.0],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    "Sales Information",
                    style: AppTextStyles.h2.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 24),
                  
                  // Nozzle Information Card
                  Text(
                    "Nozzle Info",
                    style: AppTextStyles.labelBold.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 12),
                  GlassContainer(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Nozzle ${nozzle.number}",
                              style: AppTextStyles.h3.copyWith(color: Colors.white),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              nozzle.fuelType,
                              style: AppTextStyles.caption.copyWith(color: Colors.white70),
                            ),
                          ],
                        ),
                        const Icon(Icons.local_gas_station, color: AppColors.primary, size: 32),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Sales Inputs Card
                  Text(
                    "Enter Sales Details",
                    style: AppTextStyles.labelBold.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 12),
                  GlassContainer(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withOpacity(0.2)),
                          ),
                          child: TextField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
                            decoration: const InputDecoration(
                              hintText: "0.00",
                              hintStyle: TextStyle(color: Colors.black26),
                              prefixText: "₹ ",
                              prefixStyle: TextStyle(color: Colors.black26, fontWeight: FontWeight.bold),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withOpacity(0.2)),
                          ),
                          child: TextField(
                            controller: _quantityController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
                            decoration: const InputDecoration(
                              hintText: "0.00",
                              hintStyle: TextStyle(color: Colors.black26),
                              suffixText: "L",
                              suffixStyle: TextStyle(color: Colors.black26),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        ElevatedButton(
                          onPressed: () {
                            if (_amountController.text.isNotEmpty && _quantityController.text.isNotEmpty) {
                              provider.setSalesInfo(widget.nozzleCode, _amountController.text, _quantityController.text);
                              
                              // Check if there are more nozzles that need sales info
                              final pendingNozzleCode = provider.selectedNozzleCodes.firstWhere(
                                (code) => !provider.isNozzleSalesComplete(code),
                                orElse: () => "",
                              );

                              if (pendingNozzleCode.isNotEmpty) {
                                // Go to next nozzle sales details
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SalesDetailsScreen(nozzleCode: pendingNozzleCode),
                                  ),
                                );
                              } else {
                                // All done, redirect home
                                Navigator.of(context).popUntil((route) => route.isFirst);
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.textDark,
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text("Submit"),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

