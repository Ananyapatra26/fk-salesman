import 'package:flutter/material.dart';
import 'package:fk_salesman/core/constants/app_text_styles.dart';
import 'package:fk_salesman/core/constants/app_colors.dart';
import '../../domain/models/nozzle_response_model.dart';


class NozzleCard extends StatelessWidget {
  final String number;
  final String fuelType;
  final String fuelTypeCode;
  final double unitPrice;
  final bool isSelected;
  final VoidCallback onSelect;
  final VoidCallback? onDeselect;
  final VoidCallback? onTesting;
  final Salesman? salesman;
  final bool showSalesman;
  final String status;
  final bool showStatus;
  final String? actionLabel;
  final bool showActionButton;

  const NozzleCard({
    super.key,
    required this.number,
    required this.fuelType,
    required this.fuelTypeCode,
    required this.unitPrice,
    required this.isSelected,
    required this.onSelect,
    this.onDeselect,
    this.onTesting,
    this.status = 'active',
    this.showStatus = false,
    this.actionLabel,
    this.salesman,
    this.showSalesman = false,
    this.showActionButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.accent, AppColors.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "NOZZLE",
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white70,
                        fontSize: 9,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      number,
                      style: AppTextStyles.h3.copyWith(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [

                    Icon(
                      fuelTypeCode == "MS"
                          ? Icons.local_gas_station
                          : Icons.ev_station,
                      color: Colors.white,
                      size: 24,
                    ),
                    if (onDeselect != null) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: onDeselect,
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.redAccent, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                    if (showStatus) ...[
                      _buildStatusTag(),
                      const SizedBox(width: 8),
                    ],
                  ],
                ),
              ],
            ),

            const SizedBox(height: 8),

            /// Fuel info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fuelTypeCode.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        fuelType,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      "PRICE/LTR",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      "₹${unitPrice.toStringAsFixed(2)}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            if (showSalesman) ...[
              const Divider(color: Colors.white24, height: 16),

              /// Salesman Info
              if (salesman != null)
                Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.white24,
                      backgroundImage: salesman!.photo != null ? NetworkImage(salesman!.photo!) : null,
                      child: salesman!.photo == null 
                          ? const Icon(Icons.person, size: 16, color: Colors.white) 
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            salesman!.name,
                            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            salesman!.mobile,
                            style: const TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              else
                const Row(
                  children: [
                    Icon(Icons.person_off_outlined, size: 16, color: Colors.white54),
                    SizedBox(width: 8),
                    Text(
                      "Salesman not assigned",
                      style: TextStyle(color: Colors.white54, fontSize: 12, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
            ],

            const Spacer(),

            /// ACTION BUTTONS
            if (showActionButton && (!showSalesman || salesman == null))
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 38,
                      child: TextButton(
                        onPressed: onSelect,
                        style: ButtonStyle(
                          backgroundColor:
                              WidgetStateProperty.resolveWith<Color>((states) {
                            if (states.contains(WidgetState.pressed)) {
                              return Colors.white30;
                            }
                            return isSelected
                                ? Colors.white
                                : Colors.white.withOpacity(0.15);
                          }),
                          overlayColor:
                              WidgetStateProperty.all(Colors.white10),
                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: isSelected
                                    ? Colors.transparent
                                    : Colors.white24,
                              ),
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.currency_rupee,
                                color: isSelected ? AppColors.primary : Colors.white, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              actionLabel ?? (isSelected ? "Selected" : "Sales"),
                              style: TextStyle(
                                color: isSelected ? AppColors.primary : Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (onTesting != null) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: SizedBox(
                        height: 38,
                        child: TextButton(
                          onPressed: onTesting,
                          style: ButtonStyle(
                            backgroundColor:
                                WidgetStateProperty.resolveWith<Color>((states) {
                              if (states.contains(WidgetState.pressed)) {
                                return Colors.white24;
                              }
                              return Colors.white.withOpacity(0.1);
                            }),
                            overlayColor: WidgetStateProperty.all(
                                Colors.white10),
                            shape: WidgetStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(color: Colors.white24),
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.settings,
                                  color: Colors.white,
                                  size: 14),
                              const SizedBox(width: 4),
                              const Text(
                                "Testing",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              )
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTag() {
    Color bgColor;
    Color textColor;
    String label = status.toUpperCase();

    switch (status.toLowerCase()) {
      case 'active':
        bgColor = Colors.green[600]!;
        textColor = Colors.white;
        break;
      case 'in-active':
      case 'inactive':
        bgColor = Colors.grey[800]!;
        textColor = Colors.white;
        label = "IN-ACTIVE";
        break;
      case 'pending':
        bgColor = Colors.amber;
        textColor = Colors.black87;
        break;
      default:
        bgColor = Colors.white24;
        textColor = Colors.white;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 9,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}