import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:fk_salesman/core/constants/app_colors.dart';
import 'package:fk_salesman/core/widgets/glass_container.dart';
import 'package:fk_salesman/core/widgets/app_alert.dart';
import 'package:fk_salesman/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:fk_salesman/features/dashboard/presentation/widgets/nozzle_card.dart';
import 'package:fk_salesman/core/constants/app_text_styles.dart';


class AddNozzlesScreen extends StatefulWidget {
  const AddNozzlesScreen({super.key});

  @override
  State<AddNozzlesScreen> createState() => _AddNozzlesScreenState();
}

class _AddNozzlesScreenState extends State<AddNozzlesScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<DashboardProvider>();
      provider.fetchSelectedNozzles(); // Sync selected nozzles first
      provider.fetchNozzles();
    });
  }



  void _showLoadingPopup(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        content: GlassContainer(
          padding: const EdgeInsets.all(32),
          blur: 30,
          opacity: 0.2,
          borderRadius: 24,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 3,
              ),
              const SizedBox(height: 24),
              Text(
                message.toUpperCase(),
                style: AppTextStyles.labelBold.copyWith(
                  color: AppColors.primary,
                  letterSpacing: 2,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please wait...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textDark.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DashboardProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textDark, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          "Add Active Nozzles",
          style: TextStyle(color: AppColors.textDark, fontSize: 18),
        ),
      ),
      body: Stack(
        children: [
          // Background (Removed)
          const SizedBox.shrink(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(
                        Icons.local_gas_station,
                        color: AppColors.primary,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "All Active Nozzles",
                        style: TextStyle(
                          color: AppColors.textDark,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      if (!provider.isLoading)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "${provider.mySelectedNozzles.length}/4 Selected",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  /// Loading
                  if (provider.isLoading)
                    const Expanded(
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  /// Error
                  else if (provider.error != null && provider.nozzles.isEmpty)
                    Expanded(
                      child: Center(
                        child: Text(
                          provider.error!,
                          style: const TextStyle(color: AppColors.textDark),
                        ),
                      ),
                    )
                  /// Nozzle List
                  else
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () => provider.fetchNozzles(),
                        color: AppColors.primary,
                        backgroundColor: AppColors.white,
                        child: GridView.builder(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 1,
                            mainAxisSpacing: 16,
                            mainAxisExtent: 190,
                          ),
                          itemCount: provider.nozzles.length,
                          itemBuilder: (context, index) {
                            final nozzle = provider.nozzles[index];
                            final isAlreadyAdded = provider.mySelectedNozzles.any((n) => n.id == nozzle.id);
                            void handleSelect() async {
                              if (isAlreadyAdded) {
                                AppAlert.showInfo(
                                  context,
                                  message: 'This nozzle is already in your dashboard.',
                                );
                                return;
                              }

                              final navigator = Navigator.of(context);
                              final router = GoRouter.of(context);
                              _showLoadingPopup(context, 'Selecting Nozzle');

                              final success = await provider.selectNozzle(nozzle.id);

                              if (!mounted) return;
                              navigator.pop(); // close dialog safely using captured navigator

                              if (success) {
                                await AppAlert.showSuccess(
                                  context,
                                  message: 'You have selected the nozzle successfully.',
                                );
                                if (mounted) router.go('/dashboard');
                              } else {
                                await AppAlert.showError(
                                  context,
                                  message: provider.error ?? 'Maximum 1 nozzle can be chosen.',
                                );
                                if (mounted) router.go('/dashboard');
                              }
                            }

                            return GestureDetector(
                           //   onTap: () => _handleCardTap(nozzle.id),
                              child: NozzleCard(
                                number: nozzle.number,
                                fuelType: nozzle.fuelType,
                                fuelTypeCode: nozzle.fuelTypeCode,
                                unitPrice: nozzle.unitPrice,
                                  status: nozzle.status,
                                  isSelected: isAlreadyAdded,
                                  actionLabel: isAlreadyAdded ? "Selected" : "Select",
                                  salesman: nozzle.salesman,
                                  showSalesman: true,
                                  onSelect: handleSelect,
                                ),
                            );
                          },
                        ),
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
