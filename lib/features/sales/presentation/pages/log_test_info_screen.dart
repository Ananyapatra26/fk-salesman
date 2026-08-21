import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fk_salesman/core/constants/app_colors.dart';
import 'package:fk_salesman/core/constants/app_text_styles.dart';
import 'package:provider/provider.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';
import '../../../dashboard/presentation/widgets/nozzle_card.dart';

class LogTestInfoScreen extends StatefulWidget {
  const LogTestInfoScreen({super.key});

  @override
  State<LogTestInfoScreen> createState() => _LogTestInfoScreenState();
}

class _LogTestInfoScreenState extends State<LogTestInfoScreen> {
  static const Color _indigo = Color(0xFF3949AB);
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().fetchLogTestNozzles();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DashboardProvider>();
    final nozzles = provider.testingNozzles;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: _indigo,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color:Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "LOG TEST INFO",
          style: AppTextStyles.labelBold.copyWith(
            color: Colors.white,
            letterSpacing: 2,
            fontSize: 14,

          ),
        ),
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () => provider.fetchLogTestNozzles(),
            color: AppColors.primary,
            child: nozzles.isEmpty && !provider.isLoading
                ? ListView(
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.local_gas_station_outlined,
                                size: 60, color: _indigo.withOpacity(0.2)),
                            const SizedBox(height: 16),
                            const Text(
                              "No active nozzles found.",
                              style: TextStyle(color: Colors.black54, fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: nozzles.length,
                    itemBuilder: (context, index) {
                      final nozzle = nozzles[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: SizedBox(
                          height: 180,
                          child: NozzleCard(
                            number: nozzle.number,
                            fuelType: nozzle.fuelType,
                            fuelTypeCode: nozzle.fuelTypeCode,
                            unitPrice: nozzle.unitPrice,
                            status: nozzle.status,
                            isSelected: false,
                            actionLabel: "START TESTING",
                            showActionButton: provider.totalTestingAllowed > 0,
                            onSelect: () {
                              context.push('/nozzle-testing', extra: nozzle.id);
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
          if (provider.isLoading)
            Container(
              color: Colors.white.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
