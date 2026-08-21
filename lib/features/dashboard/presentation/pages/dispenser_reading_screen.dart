// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:fk_salesman/core/constants/app_text_styles.dart';
// import 'package:fk_salesman/core/constants/app_colors.dart';
// import 'package:fk_salesman/core/widgets/glass_container.dart';
// import 'package:fk_salesman/features/dashboard/presentation/providers/dashboard_provider.dart';
// import 'package:fk_salesman/features/dashboard/presentation/pages/sales_details_screen.dart';
//
// class DispenserReadingScreen extends StatefulWidget {
//   final int nozzleIndex;
//   const DispenserReadingScreen({super.key, required this.nozzleIndex});
//
//   @override
//   State<DispenserReadingScreen> createState() => _DispenserReadingScreenState();
// }
//
// class _DispenserReadingScreenState extends State<DispenserReadingScreen> {
//   final TextEditingController _readingController = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     final provider = context.read<DashboardProvider>();
//     _readingController.text = provider.getDispenserReading(widget.nozzleIndex) ?? "";
//   }
//
//   @override
//   void dispose() {
//     _readingController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final provider = context.watch<DashboardProvider>();
//     final nozzle = provider.nozzles[widget.nozzleIndex];
//
//     return Scaffold(
//       body: Stack(
//         children: [
//           // Background Gradient (Consistent with Theme)
//           Container(
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [
//                   Color(0xFF1A1A1A),
//                   Color(0xFF2D2D2D),
//                   AppColors.primary,
//                 ],
//                 stops: [0.0, 0.6, 1.0],
//               ),
//             ),
//           ),
//           SafeArea(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 24.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const SizedBox(height: 20),
//                   IconButton(
//                     onPressed: () => Navigator.pop(context),
//                     icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
//                   ),
//                   const SizedBox(height: 40),
//                   Text(
//                     "Dispenser Reading",
//                     style: AppTextStyles.h2.copyWith(color: Colors.white),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     "Enter reading for Nozzle ${nozzle.number} (${nozzle.fuelType})",
//                     style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
//                   ),
//                   const SizedBox(height: 40),
//                   GlassContainer(
//                     padding: const EdgeInsets.all(24),
//                     child: Column(
//                       children: [
//                         Container(
//                           decoration: BoxDecoration(
//                             color: Colors.white.withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(16),
//                             border: Border.all(color: Colors.white.withOpacity(0.2)),
//                           ),
//                           child: TextField(
//                             controller: _readingController,
//                             keyboardType: TextInputType.number,
//                             textAlign: TextAlign.center,
//                             style: const TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
//                             decoration: const InputDecoration(
//                               hintText: "0.00",
//                               hintStyle: TextStyle(color: Colors.black38),
//                               border: InputBorder.none,
//                               contentPadding: EdgeInsets.all(20),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 40),
//                         ElevatedButton(
//                           onPressed: () {
//                             if (_readingController.text.isNotEmpty) {
//                               provider.setDispenserReading(widget.nozzleIndex, _readingController.text);
//
//                               // Check if there are more nozzles that need readings
//                               final pendingNozzleIndex = provider.selectedNozzleIndices.firstWhere(
//                                 (idx) => !provider.isNozzleReadingComplete(idx),
//                                 orElse: () => -1,
//                               );
//
//                               if (pendingNozzleIndex != -1) {
//                                 // Go to next nozzle reading
//                                 Navigator.pushReplacement(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) => DispenserReadingScreen(nozzleIndex: pendingNozzleIndex),
//                                   ),
//                                 );
//                               } else {
//                                 // All readings done, go to sales details for the first nozzle
//                                 final firstNozzleIndex = provider.selectedNozzleIndices.first;
//                                 Navigator.pushReplacement(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) => SalesDetailsScreen(nozzleIndex: firstNozzleIndex),
//                                   ),
//                                 );
//                               }
//                             }
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: AppColors.primary,
//                             foregroundColor: AppColors.textDark,
//                             minimumSize: const Size(double.infinity, 56),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(16),
//                             ),
//                           ),
//                           child: Text(
//                             "Next",
//                             style: AppTextStyles.buttonText,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
