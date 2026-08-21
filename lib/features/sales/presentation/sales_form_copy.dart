// import 'package:flutter/material.dart';
// import 'package:fk_salesman/core/constants/app_colors.dart';
// import 'package:fk_salesman/core/constants/app_text_styles.dart';
// import 'package:fk_salesman/core/widgets/glass_container.dart';
// import 'package:flutter/services.dart';
//
// import '../dashboard/data/services/nozzle_service.dart';
// import 'data/models/nozzle_detail_response_model.dart';
// import 'data/models/payment_method_model.dart';
// import '../dashboard/domain/models/nozzle_model.dart';
// import 'data/models/sales_entry_model.dart';
// import 'data/services/sales_service.dart';
//
// class SalesFormPage extends StatefulWidget {
//   final List<Nozzle> selectedNozzles;
//   final int? initialIndex;
//   const SalesFormPage({
//     super.key,
//     required this.selectedNozzles,
//     this.initialIndex,
//   });
//
//   @override
//   State<SalesFormPage> createState() => _SalesFormPageState();
// }
//
// class _SalesFormPageState extends State<SalesFormPage>
//     with TickerProviderStateMixin {
//   // SalesFormPage keeps indigo theme regardless of global primary color
//   static const Color _indigo = Color(0xFF3949AB);
//
//   final SalesService _salesService = SalesService();
//   final NozzleService _nozzleService = NozzleService();
//   bool _isLoading = false;
//   bool _isFetchingDetails = false;
//
//   late AnimationController _entranceController;
//   late Animation<double> _fadeAnimation;
//   late Animation<Offset> _slideAnimation;
//
//   late AnimationController _buttonController;
//   late Animation<double> _buttonScaleAnimation;
//
//   bool isLtrSelected = false;
//   final TextEditingController _amountController = TextEditingController();
//   final TextEditingController _collectingController = TextEditingController();
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _mobileController = TextEditingController();
//
//   PaymentMethod? selectedPaymentMethod;
//   List<PaymentMethod> _paymentMethods = [];
//   NozzleDetailData? _currentNozzleDetails;
//
//   int _currentNozzleIndex = 0;
//
//   double _calculatedLiters = 0.0;
//   double _calculatedAmount = 0.0;
//
//   @override
//   void initState() {
//     super.initState();
//
//     if (widget.initialIndex != null &&
//         widget.initialIndex! >= 0 &&
//         widget.initialIndex! < widget.selectedNozzles.length) {
//       _currentNozzleIndex = widget.initialIndex!;
//     }
//
//     _entranceController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 800),
//     );
//
//     _fadeAnimation = CurvedAnimation(
//       parent: _entranceController,
//       curve: Curves.easeOut,
//     );
//
//     _slideAnimation =
//         Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(
//           CurvedAnimation(parent: _entranceController, curve: Curves.easeOut),
//         );
//
//     _buttonController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 100),
//     );
//
//     _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
//       CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut),
//     );
//
//     _entranceController.forward();
//     _fetchNozzleDetails();
//   }
//
//   Future<void> _fetchNozzleDetails() async {
//     setState(() => _isFetchingDetails = true);
//     try {
//       final nozzle = widget.selectedNozzles[_currentNozzleIndex];
//       final response = await _nozzleService.getNozzleDetails(nozzle.id);
//
//       if (mounted) {
//         setState(() {
//           _currentNozzleDetails = response.data;
//           _paymentMethods = response.data.availablePaymentMethods;
//           if (_paymentMethods.isNotEmpty) {
//             selectedPaymentMethod = _paymentMethods.first;
//           }
//           _isFetchingDetails = false;
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() => _isFetchingDetails = false);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error fetching nozzle details: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }
//
//   @override
//   void dispose() {
//     _entranceController.dispose();
//     _buttonController.dispose();
//     _amountController.dispose();
//     _collectingController.dispose();
//     _nameController.dispose();
//     _mobileController.dispose();
//     super.dispose();
//   }
//
//   void _handleButtonPress() async {
//     await _buttonController.forward();
//     await _buttonController.reverse();
//   }
//
//   void _calculateValues(String value) {
//     if (value.isEmpty) {
//       setState(() {
//         _calculatedLiters = 0.0;
//         _calculatedAmount = 0.0;
//         _collectingController.text = '';
//       });
//       return;
//     }
//
//     double input = double.tryParse(value) ?? 0.0;
//     double pricePerLiter =
//         widget.selectedNozzles[_currentNozzleIndex].unitPrice;
//
//     setState(() {
//       if (isLtrSelected) {
//         _calculatedLiters = input;
//         _calculatedAmount = input * pricePerLiter;
//       } else {
//         _calculatedAmount = input;
//         _calculatedLiters = input / pricePerLiter;
//       }
//       _collectingController.text = _calculatedAmount.toStringAsFixed(2);
//     });
//   }
//
//   Future<void> _saveEntry() async {
//     if (_calculatedAmount <= 0) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please enter a valid amount or liters'),backgroundColor: Colors.red,),
//       );
//       return;
//     }
//
//     setState(() => _isLoading = true);
//     _handleButtonPress();
//
//     try {
//       final currentNozzle = widget.selectedNozzles[_currentNozzleIndex];
//       final model = SalesEntryModel(
//         selectedNozzle: _currentNozzleDetails?.code ?? currentNozzle.id,
//         fuelType:
//         _currentNozzleDetails?.fuelTypeCode ?? currentNozzle.fuelTypeCode,
//         unitPrice:
//         _currentNozzleDetails?.fuelTypeUnitPrice ?? currentNozzle.unitPrice,
//         quantity: _calculatedLiters,
//         amountPayable: _calculatedAmount,
//         amountPaid:
//         double.tryParse(_collectingController.text) ?? _calculatedAmount,
//         customerName: _nameController.text.isNotEmpty
//             ? _nameController.text
//             : null,
//         customerMobile: _mobileController.text.isNotEmpty
//             ? _mobileController.text
//             : null,
//         customerDialCode: "91",
//         paymentMethod: selectedPaymentMethod?.code,
//       );
//
//       final result = await _salesService.storeSalesEntry(model);
//
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(result['message'] ?? 'Entry saved successfully'),
//             backgroundColor: Colors.green,
//           ),
//         );
//
//         // Reset fields immediately
//         _amountController.clear();
//         _nameController.clear();
//         _mobileController.clear();
//         _calculateValues('');
//
//         // Refresh current nozzle details
//         _fetchNozzleDetails();
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(e.toString().replaceAll('Exception: ', '')),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }
//
//   void _roundAmount() {
//     if (_calculatedAmount == 0) return;
//
//     double floorVal = _calculatedAmount.floorToDouble();
//     double ceilVal = _calculatedAmount.ceilToDouble();
//
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: Colors.transparent,
//         contentPadding: EdgeInsets.zero,
//         content: GlassContainer(
//           padding: const EdgeInsets.all(24),
//           blur: 30,
//           opacity: 0.2,
//           borderRadius: 24,
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(
//                 'ROUND AMOUNT',
//                 style: AppTextStyles.labelBold.copyWith(
//                   color: _indigo,
//                   letterSpacing: 2,
//                 ),
//               ),
//               const SizedBox(height: 24),
//               Row(
//                 children: [
//                   Expanded(child: _buildRoundOption(floorVal)),
//                   const SizedBox(width: 12),
//                   Expanded(child: _buildRoundOption(ceilVal)),
//                 ],
//               ),
//               const SizedBox(height: 24),
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: Text(
//                   'CANCEL',
//                   style: TextStyle(color: Colors.white.withAlpha(128)),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildRoundOption(double value) {
//     return GestureDetector(
//       onTap: () {
//         _handleButtonPress();
//         setState(() {
//           _collectingController.text = value.toStringAsFixed(2);
//         });
//         Navigator.pop(context);
//       },
//       child: ScaleTransition(
//         scale: _buttonScaleAnimation,
//         child: GlassContainer(
//           borderRadius: 12,
//           opacity: 0.1,
//           padding: const EdgeInsets.symmetric(vertical: 20),
//           child: Column(
//             children: [
//               Text(
//                 '₹',
//                 style: TextStyle(color: _indigo, fontSize: 12),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 value.toStringAsFixed(0),
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F9FA), // Off-white/light grey background like the image
//       body: Stack(
//         children: [
//           SafeArea(
//             child: FadeTransition(
//               opacity: _fadeAnimation,
//               child: SlideTransition(
//                 position: _slideAnimation,
//                 child: SingleChildScrollView(
//                   physics: const BouncingScrollPhysics(),
//                   padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.stretch,
//                     children: [
//                       const SizedBox(height: 4),
//                       Row(
//                         children: [
//                           GestureDetector(
//                             onTap: () => Navigator.pop(context),
//                             child: Container(
//                               width: 36,
//                               height: 36,
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(10),
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Colors.black.withValues(alpha: 0.05),
//                                     blurRadius: 8,
//                                     offset: const Offset(0, 2),
//                                   )
//                                 ],
//                               ),
//                               child: const Icon(Icons.arrow_back, color: AppColors.textDark, size: 18),
//                             ),
//                           ),
//                           const Expanded(
//                             child: Text(
//                               'SALES ENTRY',
//                               textAlign: TextAlign.center,
//                               style: TextStyle(
//                                 letterSpacing: 2,
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.bold,
//                                 color: AppColors.textDark,
//                               ),
//                             ),
//                           ),
//                           // const Icon(Icons.calculate, color: Colors.black12, size: 24),
//                         ],
//                       ),
//                       const SizedBox(height: 10),
//
//                       // Nozzle Tabs
//                       SizedBox(
//                         height: 36,
//                         child: ListView.separated(
//                           scrollDirection: Axis.horizontal,
//                           itemCount: widget.selectedNozzles.length,
//                           separatorBuilder: (context, index) => const SizedBox(width: 8),
//                           itemBuilder: (context, index) {
//                             final noz = widget.selectedNozzles[index];
//                             final isSelected = index == _currentNozzleIndex;
//                             return GestureDetector(
//                               onTap: () {
//                                 _handleButtonPress();
//                                 setState(() {
//                                   _currentNozzleIndex = index;
//                                   _amountController.clear();
//                                   _calculateValues('');
//                                 });
//                                 _fetchNozzleDetails();
//                               },
//                               child: AnimatedContainer(
//                                 duration: const Duration(milliseconds: 200),
//                                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                                 decoration: BoxDecoration(
//                                   color: isSelected ? _indigo : Colors.white,
//                                   borderRadius: BorderRadius.circular(8),
//                                   boxShadow: isSelected
//                                       ? [BoxShadow(color: _indigo.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))]
//                                       : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 1))],
//                                 ),
//                                 alignment: Alignment.center,
//                                 child: Row(
//                                   mainAxisSize: MainAxisSize.min,
//                                   children: [
//                                     Icon(
//                                       isSelected ? Icons.check_circle : Icons.local_gas_station,
//                                       size: 14,
//                                       color: isSelected ? Colors.white : Colors.black45,
//                                     ),
//                                     const SizedBox(width: 6),
//                                     Text(
//                                       '#${noz.number}',
//                                       style: TextStyle(
//                                         fontSize: 12,
//                                         color: isSelected ? Colors.white : Colors.black87,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//
//                       const SizedBox(height: 10),
//
//                       // Card 1: Nozzle Details (Indigo Background as requested)
//                       Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                         decoration: BoxDecoration(
//                             color: _indigo,
//                             borderRadius: BorderRadius.circular(16),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: _indigo.withValues(alpha: 0.3),
//                                 blurRadius: 10,
//                                 offset: const Offset(0, 5),
//                               )
//                             ]
//                         ),
//                         child: Column(
//                             children: [
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         'NOZZLE #${widget.selectedNozzles[_currentNozzleIndex].number}',
//                                         style: AppTextStyles.h3.copyWith(
//                                           color: Colors.white,
//                                           fontSize: 13,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                       const SizedBox(height: 2),
//                                       Container(
//                                         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                                         decoration: BoxDecoration(
//                                           color: Colors.white.withValues(alpha: 0.2),
//                                           borderRadius: BorderRadius.circular(6),
//                                         ),
//                                         child: Text(
//                                           widget.selectedNozzles[_currentNozzleIndex].fuelType.toUpperCase(),
//                                           style: const TextStyle(
//                                             color: Colors.white,
//                                             fontSize: 10,
//                                             fontWeight: FontWeight.bold,
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   Column(
//                                     crossAxisAlignment: CrossAxisAlignment.end,
//                                     children: [
//                                       Text(
//                                         'PRICE / LTR',
//                                         style: TextStyle(
//                                           color: Colors.white.withValues(alpha: 0.7),
//                                           fontSize: 10,
//                                         ),
//                                       ),
//                                       Text(
//                                         '₹ ${widget.selectedNozzles[_currentNozzleIndex].unitPrice.toStringAsFixed(2)}',
//                                         style: AppTextStyles.h2.copyWith(
//                                           color: Colors.white,
//                                           fontWeight: FontWeight.bold,
//                                           fontSize: 18,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                               if (_currentNozzleDetails != null) ...[
//                                 const SizedBox(height: 8),
//                                 const Divider(color: Colors.white24, height: 1),
//                                 const SizedBox(height: 8),
//                                 Row(
//                                   children: [
//                                     _buildMiniDetail('DISPENSER', _currentNozzleDetails!.fuelDispenserDesc),
//                                     const SizedBox(width: 20),
//                                     _buildMiniDetail('O.R. NO', _currentNozzleDetails!.lastReadingNo.toStringAsFixed(2)),
//                                     const SizedBox(width: 20),
//                                     _buildMiniDetail('C.R. NO (TEMP)', _currentNozzleDetails!.expectedClosingReadingNo.toStringAsFixed(2)),
//                                   ],
//                                 ),
//                               ],
//                             ]
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//
//                       // Card 2: Calculated Details (Indigo Background as requested)
//                       Container(
//                         padding: const EdgeInsets.all(6),
//                         decoration: BoxDecoration(
//                             color: _indigo,
//                             borderRadius: BorderRadius.circular(16),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: _indigo.withValues(alpha: 0.3),
//                                 blurRadius: 10,
//                                 offset: const Offset(0, 5),
//                               )
//                             ]
//                         ),
//                         child: Row(
//                           children: [
//                             Expanded(child: _buildInfoRowCol('Liters', _calculatedLiters.toStringAsFixed(2))),
//                             Container(width: 1, height: 30, color: Colors.white24),
//                             Expanded(child: _buildInfoRowCol('Total Amount', '₹ ${_calculatedAmount.toStringAsFixed(2)}')),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(height: 10),
//                       Text(
//                         'SELECT SALES MODE',
//                         style: AppTextStyles.labelBold.copyWith(
//                           color: _indigo,
//                           letterSpacing: 1.5,
//                           fontSize: 11,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 6),
//                       // Amount / Ltr Toggle
//                       Row(
//                         children: [
//                           Expanded(
//                             child: _buildToggleButton(
//                               label: 'Amount',
//                               isSelected: !isLtrSelected,
//                               onTap: () {
//                                 if (isLtrSelected) {
//                                   setState(() {
//                                     isLtrSelected = false;
//                                     _amountController.clear();
//                                     _calculateValues('');
//                                   });
//                                 }
//                               },
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: _buildToggleButton(
//                               label: 'Ltr',
//                               isSelected: isLtrSelected,
//                               onTap: () {
//                                 if (!isLtrSelected) {
//                                   setState(() {
//                                     isLtrSelected = true;
//                                     _amountController.clear();
//                                     _calculateValues('');
//                                   });
//                                 }
//                               },
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 10),
//
//                       // 2. ENTER AMOUNT
//                       Text(
//                         'ENTER ${isLtrSelected ? "LITERS" : "AMOUNT"}',
//                         style: AppTextStyles.labelBold.copyWith(
//                           color: _indigo,
//                           letterSpacing: 1.5,
//                           fontSize: 11,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 6),
//                       Container(
//                         height: 44,
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: TextField(
//                           cursorColor: _indigo,
//                           controller: _amountController,
//                           onChanged: (value) {
//                             setState(() {}); // triggers UI update when typing
//                             _calculateValues(value);
//                           },
//                           keyboardType: const TextInputType.numberWithOptions(decimal: true),
//                           style: const TextStyle(
//                             color: AppColors.textDark,
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                           decoration: InputDecoration(
//                             hintText: '0.00',
//
//                             // 👇 DEFAULT BORDER
//                             enabledBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                               borderSide: BorderSide(
//                                 color: _amountController.text.isNotEmpty
//                                     ? _indigo
//                                     : Colors.black,
//                               ),
//                             ),
//
//                             // 👇 WHEN USER CLICKS (FOCUS)
//                             focusedBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                               borderSide: const BorderSide(
//                                 color: _indigo,
//                                 width: 2,
//                               ),
//                             ),
//
//                             prefixIcon: Icon(
//                               isLtrSelected ? Icons.local_gas_station : Icons.currency_rupee,
//                               color: _indigo,
//                               size: 20,
//                             ),
//
//                             contentPadding: const EdgeInsets.symmetric(vertical: 12),
//                             hintStyle: const TextStyle(
//                               color: Colors.black12,
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 10),
//
//                       // 3. COLLECT PAYMENT
//                       Text(
//                         'COLLECTED AMOUNT',
//                         style: AppTextStyles.labelBold.copyWith(
//                           color: _indigo,
//                           letterSpacing: 1.5,
//                           fontSize: 11,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 6),
//                       Row(
//                           children: [
//                             Expanded(
//                               flex: 3,
//                               child: Container(
//                                 height: 44,
//                                 decoration: BoxDecoration(
//                                   color: Colors.white,
//                                   borderRadius: BorderRadius.circular(12),
//                                   border: Border.all(color: Colors.black),
//                                 ),
//                                 child: TextField(
//                                   controller: _collectingController,
//                                   readOnly: true,
//                                   style: const TextStyle(color: AppColors.textDark, fontSize: 14),
//                                   decoration: const InputDecoration(
//                                     hintText: 'Paid Amount',
//                                     hintStyle: TextStyle(color: Colors.black26, fontSize: 13),
//                                     prefixIcon: Icon(Icons.currency_rupee, color: _indigo, size: 18),
//                                     border: InputBorder.none,
//                                     contentPadding: EdgeInsets.symmetric(
//                                       horizontal: 16,
//                                       vertical: 12,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(width: 12),
//                             Expanded(
//                               flex: 1,
//                               child: Container(
//                                 height: 44,
//                                 decoration: BoxDecoration(
//                                   color: Colors.white,
//                                   borderRadius: BorderRadius.circular(12),
//                                   border: Border.all(color: Colors.black),
//                                 ),
//                                 child: TextButton(
//                                   onPressed: !isLtrSelected ? null : () {
//                                     _handleButtonPress();
//                                     _roundAmount();
//                                   },
//                                   style: TextButton.styleFrom(
//                                     padding: EdgeInsets.zero,
//                                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                                   ),
//                                   child: Text(
//                                     'Round',
//                                     style: TextStyle(
//                                       color: !isLtrSelected ? Colors.black26 : Colors.black54,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ]
//                       ),
//
//                       const SizedBox(height: 10),
//
//                       // 4. SELECT PAYMENT
//                       Text(
//                         'PAYMENT TYPE',
//                         style: AppTextStyles.labelBold.copyWith(
//                           color: _indigo,
//                           letterSpacing: 1.5,
//                           fontSize: 11,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 6),
//                       if (_paymentMethods.isEmpty && !_isFetchingDetails)
//                         Container(
//                           padding: const EdgeInsets.all(5),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(8),
//                             border: Border.all(color: Colors.black),
//                           ),
//                           child: const Text(
//                             'No payment methods available',
//                             style: TextStyle(color: Colors.black26, fontSize: 12),
//                           ),
//                         )
//                       else if (_paymentMethods.isNotEmpty)
//                         GridView.builder(
//                           shrinkWrap: true,
//                           physics: const NeverScrollableScrollPhysics(),
//                           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                             crossAxisCount: 3,
//                             childAspectRatio: 3.2,
//                             crossAxisSpacing: 8,
//                             mainAxisSpacing: 6,
//                           ),
//                           itemCount: _paymentMethods.length,
//                           itemBuilder: (context, index) {
//                             final method = _paymentMethods[index];
//                             final isSel = selectedPaymentMethod?.code == method.code;
//                             return GestureDetector(
//                               onTap: () {
//                                 _handleButtonPress();
//                                 setState(() => selectedPaymentMethod = method);
//                               },
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                   color: isSel ? _indigo : Colors.white,
//                                   borderRadius: BorderRadius.circular(8),
//                                   border: Border.all(
//                                     color: isSel ? _indigo : Colors.black54,
//                                   ),
//                                 ),
//                                 alignment: Alignment.center,
//                                 child: Text(
//                                   method.name,
//                                   textAlign: TextAlign.center,
//                                   style: TextStyle(
//                                     color: isSel ? Colors.white : Colors.black54,
//                                     fontSize: 10,
//                                     fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
//                                   ),
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//
//                       const SizedBox(height: 10),
//                       // 5. INFO
//                       Text(
//                         'CUSTOMER INFO (Optional)',
//                         style: AppTextStyles.labelBold.copyWith(
//                           color: _indigo,
//                           letterSpacing: 1.5,
//                           fontSize: 11,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 6),
//                       Row(
//                         children: [
//                           Container(
//                             width: 45,
//                             height: 37,
//                             alignment: Alignment.center,
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(12),
//                               border: Border.all(color: Colors.black12),
//                             ),
//                             child: const Text(
//                               '+91',
//                               style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 14),
//                             ),
//                           ),
//                           const SizedBox(width: 8),
//                           Expanded(
//                             child: Container(
//                               height: 37,
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               child: TextField(
//                                 cursorColor: _indigo,
//                                 controller: _mobileController,
//                                 keyboardType: TextInputType.phone,
//                                 maxLength: 10,
//                                 inputFormatters: [
//                                   FilteringTextInputFormatter.digitsOnly,
//                                 ],
//                                 onChanged: (value) => setState(() {}),
//
//                                 style: const TextStyle(
//                                   color: AppColors.textDark,
//                                   fontSize: 14,
//                                 ),
//
//                                 decoration: InputDecoration(
//                                   counterText: "",
//                                   hintText: 'Mobile No (Optional)',
//                                   hintStyle: const TextStyle(
//                                     color: Colors.black26,
//                                     fontSize: 11,
//                                   ),
//
//                                   // 👇 DEFAULT BORDER (changes when typing)
//                                   enabledBorder: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(12),
//                                     borderSide: BorderSide(
//                                       color: _mobileController.text.isNotEmpty
//                                           ? _indigo
//                                           : Colors.black12,
//                                     ),
//                                   ),
//
//                                   // 👇 FOCUS BORDER
//                                   focusedBorder: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(12),
//                                     borderSide: const BorderSide(
//                                       color: _indigo,
//                                       width: 2,
//                                     ),
//                                   ),
//
//                                   contentPadding: const EdgeInsets.symmetric(
//                                     horizontal: 16,
//                                     vertical: 12,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       if (_mobileController.text.isNotEmpty) ...[
//                         const SizedBox(height: 8),
//                         Container(
//                           height: 37,
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: TextField(
//                             cursorColor: _indigo,
//                             controller: _nameController,
//                             onChanged: (value) => setState(() {}), // 👈 important
//
//                             style: const TextStyle(
//                               color: AppColors.textDark,
//                               fontSize: 14,
//                             ),
//
//                             decoration: InputDecoration(
//                               hintText: 'Customer Name (Optional)',
//                               hintStyle: const TextStyle(
//                                 color: Colors.black26,
//                                 fontSize: 14,
//                               ),
//
//                               prefixIcon: const Icon(
//                                 Icons.person_outline,
//                                 color: _indigo,
//                                 size: 18,
//                               ),
//
//                               // 👇 Dynamic border (when typing)
//                               enabledBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                                 borderSide: BorderSide(
//                                   color: _nameController.text.isNotEmpty
//                                       ? _indigo
//                                       : Colors.black12,
//                                 ),
//                               ),
//
//                               // 👇 Focus border
//                               focusedBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                                 borderSide: const BorderSide(
//                                   color: _indigo,
//                                   width: 2,
//                                 ),
//                               ),
//
//                               contentPadding: const EdgeInsets.symmetric(
//                                 horizontal: 16,
//                                 vertical: 12,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                       const SizedBox(height: 12),
//                       ScaleTransition(
//                         scale: _buttonScaleAnimation,
//                         child: ElevatedButton(
//                           onPressed: _isLoading ? null : _saveEntry,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: _indigo,
//                             foregroundColor: Colors.white,
//                             padding: const EdgeInsets.symmetric(vertical: 14),
//                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                             elevation: 4,
//                           ),
//                           child: Text(
//                             _isLoading ? 'SAVING ENTRY' : 'SAVE ENTRY',
//                             style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 14),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 10),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//
//           if (_isFetchingDetails || _isLoading)
//             Positioned.fill(
//               child: Container(
//                 color: Colors.white.withValues(alpha: 0.8),
//                 child: Center(
//                   child: Container(
//                     padding: const EdgeInsets.all(24),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(20),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withValues(alpha: 0.1),
//                           blurRadius: 30,
//                         )
//                       ],
//                     ),
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         const CircularProgressIndicator(
//                           color: _indigo,
//                           strokeWidth: 3,
//                         ),
//                         const SizedBox(height: 16),
//                         Text(
//                           _isLoading
//                               ? 'Please wait, saving entry...'
//                               : 'Please wait, fetching nozzle data...',
//                           style: const TextStyle(
//                             color: _indigo,
//                             fontWeight: FontWeight.bold,
//                             letterSpacing: 1.5,
//                             fontSize: 12,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildToggleButton({
//     required String label,
//     required bool isSelected,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: () {
//         _handleButtonPress();
//         onTap();
//       },
//       child: ScaleTransition(
//         scale: _buttonScaleAnimation,
//         child: Container(
//           height: 37,
//           decoration: BoxDecoration(
//             color: isSelected ? _indigo : Colors.white,
//             borderRadius: BorderRadius.circular(10),
//             border: Border.all(
//               color: isSelected ? _indigo : Colors.black12,
//               width: 1,
//             ),
//           ),
//           child: Center(
//             child: Text(
//               label,
//               style: AppTextStyles.bodyLarge.copyWith(
//                 color: isSelected ? Colors.white : Colors.black54,
//                 fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildInfoRowCol(String label, String value) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Text(
//           label,
//           style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11),
//         ),
//         const SizedBox(height: 2),
//         Text(
//           value,
//           style: const TextStyle(
//             color: Colors.white,
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildMiniDetail(String label, String value) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label.toUpperCase(),
//           style: TextStyle(
//             color: Colors.white.withValues(alpha: 0.6),
//             fontSize: 9,
//             letterSpacing: 1,
//           ),
//         ),
//         const SizedBox(height: 2),
//         Text(
//           value,
//           style: const TextStyle(
//             color: Colors.white,
//             fontSize: 12,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ],
//     );
//   }
// }
