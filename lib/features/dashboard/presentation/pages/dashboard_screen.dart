import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fk_salesman/core/constants/app_text_styles.dart';
import 'package:fk_salesman/core/constants/app_colors.dart';
import 'package:fk_salesman/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:fk_salesman/features/dashboard/presentation/widgets/attendance_popup.dart';
import 'package:fk_salesman/features/dashboard/presentation/widgets/nozzle_card.dart';
import 'package:fk_salesman/features/dashboard/presentation/widgets/dashboard_shimmer.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/models/nozzle_model.dart';
import 'package:fk_salesman/features/auth/presentation/providers/auth_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  String? attendanceDate;
  String? checkInTime;
  String? checkOutTime;
  final ScrollController _scrollController = ScrollController();
  bool _showBottomLoader = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context.read<DashboardProvider>().fetchNozzles();
      await checkAttendance();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent &&
          !_scrollController.position.outOfRange) {
        if (!context.read<DashboardProvider>().isUpdating) {
          setState(() {
            _showBottomLoader = true;
          });
          context.read<DashboardProvider>().refreshDashboard().then((_) {
            if (mounted) {
              setState(() {
                _showBottomLoader = false;
              });
            }
          });
        }
      }
    });
  }

  /// Check if attendance already marked today
  Future<void> checkAttendance() async {
    final provider = context.read<DashboardProvider>();
    

    await provider.fetchAttendanceRecords();

    if (mounted) {
      if (!provider.hasTodayAttendance) {
        showAttendancePopup();
      } else {

        setState(() {
          attendanceDate = provider.todayAttendance?.attendanceDate;
          checkInTime = provider.todayAttendance?.checkinTime;
          checkOutTime = provider.todayAttendance?.checkoutTime;
        });
      }
    }

    final prefs = await SharedPreferences.getInstance();
    final savedDate = prefs.getString("attendance_date");
    final savedInTime = prefs.getString("attendance_time");


    if (mounted && attendanceDate == null) {
      setState(() {
        attendanceDate = savedDate;
        checkInTime = savedInTime;
      });
    }
  }

  /// Attendance Popup Replacement
  void showAttendancePopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return PopScope(
          canPop: false,
          child: AttendancePopup(
            onCheckedIn: () async {
              Navigator.of(context).pop();
              await checkAttendance();
            },
          ),
        );
      },
    );
  }

  void _showRemovalPopup(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: GlassContainer(
          width: 250,
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          blur: 30,
          opacity: 0.15,
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
                'REMOVING NOZZLE',
                style: AppTextStyles.labelBold.copyWith(
                  color: AppColors.primary,
                  letterSpacing: 2,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Updating your dashboard...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showCloseNozzleModal(BuildContext context, Nozzle nozzle) async {
    final TextEditingController closingReadingController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header Area
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.05),
                        border: Border(
                          bottom: BorderSide(color: AppColors.primary.withOpacity(0.1)),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.no_drinks, color: AppColors.primary, size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Remove Nozzle",
                                  style: AppTextStyles.h3.copyWith(
                                    color: AppColors.primary,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                Text(
                                  "Final reading required",
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.textDark.withOpacity(0.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Vertical stacking of Info Cards
                            _buildInfoSmallCard(
                              "Nozzle Code",
                              "${nozzle.number} - ${nozzle.fuelTypeCode.toUpperCase()}",
                              Icons.numbers,
                            ),
                            const SizedBox(height: 12),
                            _buildInfoSmallCard(
                              "Open Reading",
                              nozzle.lastReadingNo?.toString() ?? "0.0",
                              Icons.play_arrow,
                            ),

                            const SizedBox(height: 24),

                            Text(
                              "Enter Closing Reading",
                              style: AppTextStyles.labelBold.copyWith(
                                color: AppColors.textDark,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: closingReadingController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              textAlign: TextAlign.center,
                              style: AppTextStyles.h2.copyWith(
                                color: AppColors.primary,
                                letterSpacing: 2,
                              ),
                              decoration: InputDecoration(
                                hintText: "0000.00",
                                hintStyle: TextStyle(color: AppColors.primary.withOpacity(0.2)),
                                filled: true,
                                fillColor: AppColors.primary.withOpacity(0.03),
                                contentPadding: const EdgeInsets.all(20),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: AppColors.primary.withOpacity(0.1)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: AppColors.primary.withOpacity(0.1)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                                ),
                                errorStyle: const TextStyle(height: 0.8),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) return "Field Required";
                                if (double.tryParse(value) == null) return "Invalid Number";
                                return null;
                              },
                            ),

                            const SizedBox(height: 32),

                            // Actions
                            Row(
                              children: [
                                Expanded(
                                  child: TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text(
                                      "Cancel",
                                      style: AppTextStyles.bodyLarge.copyWith(
                                        color: AppColors.grey,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (formKey.currentState!.validate()) {
                                        Navigator.pop(context, closingReadingController.text);
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text(
                                      "Confirm & Remove",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    if (result != null && mounted) {
      final provider = context.read<DashboardProvider>();
      final messenger = ScaffoldMessenger.of(context);
      final navigator = Navigator.of(context);

      _showRemovalPopup(context);

      final success = await provider.deselectNozzle(nozzle.number, closingReading: result);

      if (!mounted) return;
      navigator.pop(); // close loader dialog

      if (success) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Removed Nozzle ${nozzle.number}'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      } else {
        messenger.showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Failed to remove nozzle'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  Widget _buildInfoSmallCard(String label, String value, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: AppColors.primary.withOpacity(0.5)),
              const SizedBox(width: 4),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.labelBold.copyWith(fontSize: 15),
          ),
        ],
      ),
    );
  }

  Future<void> _showLogoutConfirmation() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Logout",
            style: TextStyle(color: AppColors.textDark),
          ),
          content: const Text(
            "Are you sure you want to logout?",
            style: TextStyle(color: AppColors.textDark),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                "No",
                style: TextStyle(color: AppColors.textDark),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Yes", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      if (mounted) {
        final authProvider = context.read<AuthProvider>();
        await authProvider.logout();
        await context.read<DashboardProvider>().logout();

        if (mounted) {
          context.go('/login');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    final provider = context.watch<DashboardProvider>();

    return SafeArea(

      child: Container(
        color:AppColors.primary ,
        child: Scaffold(
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          body: Stack(
            children: [
              if (provider.isLoading && provider.mySelectedNozzles.isEmpty)
                const DashboardShimmer()
              else
                RefreshIndicator(
                  onRefresh: () => provider.refreshDashboard(),
                  color: AppColors.primary,
                  backgroundColor: AppColors.white,
                  child: ListView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      const SizedBox(height: 20),

                      /// Profile Row
                      Row(
                        children: [

                          GestureDetector(
                            onTap: () {
                              context.push('/profile');
                            },
                            child: Container(
                              width: 50,
                              height: 50,

                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.primary,
                                  width: 2,
                                ),
                                color: Colors.white.withOpacity(0.1),
                              ),

                              child: provider.profile?.photo == null
                                  ? const Icon(Icons.person, color: Colors.black26)
                                  : ClipRRect(
                                borderRadius: BorderRadius.circular(25),
                                child: Image.network(
                                  provider.profile!.photo!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          GestureDetector(
                            onTap: () {
                              context.push('/profile');
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Welcome",
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.textDark.withOpacity(0.9),
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  provider.profile?.name ?? "Salesman",
                                  style: AppTextStyles.h3.copyWith(
                                    color: AppColors.primary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const Spacer(),

                          /// Logout Button
                          // IconButton(
                          //   onPressed: () => _showLogoutConfirmation(),
                          //   icon: const Icon(
                          //     Icons.power_settings_new,
                          //     color: Colors.redAccent,
                          //     size: 24,
                          //   ),
                          // ),

                          /// Attendance time shown here
                          if (attendanceDate != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.black12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_today, size: 14, color: AppColors.primary),
                                      const SizedBox(width: 6),
                                      Text(
                                        attendanceDate!,
                                        style: const TextStyle(
                                          color: AppColors.textDark,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 4),

                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (checkInTime != null && checkInTime != '--:--')
                                        Row(
                                          children: [
                                            const Icon(Icons.login, size: 12, color: Colors.greenAccent),
                                            const SizedBox(width: 6),
                                            Text(
                                              "In: $checkInTime",
                                              style: const TextStyle(
                                                color: AppColors.textDark,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ),
                                      if (checkOutTime != null && checkOutTime != '--:--')
                                        Padding(
                                          padding: const EdgeInsets.only(top: 2),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.logout, size: 12, color: Colors.orangeAccent),
                                              const SizedBox(width: 6),
                                              Text(
                                                "Out: $checkOutTime",
                                                style: const TextStyle(
                                                  color: AppColors.textDark,
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),

                                  const SizedBox(height: 4),

                                    // Row(
                                    //   children: [
                                    //     const Icon(Icons.check_circle_outline, size: 14, color: Colors.green),
                                    //     const SizedBox(width: 6),
                                    //     const Text(
                                    //       "Checked In",
                                    //       style: TextStyle(
                                    //         color: Colors.green,
                                    //         fontSize: 12,
                                    //       ),
                                    //     ),
                                    //   ],
                                    // ),
                                  ],
                                ),
                              )
                        ],
                      ),

                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(
                            child: _buildDipDensityButton(
                              context: context,
                              label: "DIP",
                              icon: Icons.opacity,
                              gradientColors: [const Color(0xFF1E88E5), const Color(0xFF64B5F6)],
                              onTap: () => context.push('/dip-entry'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildDipDensityButton(
                              context: context,
                              label: "DENSITY",
                              icon: Icons.science,
                              gradientColors: [const Color(0xFF00897B), const Color(0xFF4DB6AC)],
                              onTap: () => context.push('/density-entry'),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      /// Credit Management Card
                      GestureDetector(
                        onTap: () {
                          context.push('/credit-cards');
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF8E24AA), Color(0xFFCE93D8)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF8E24AA).withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.credit_card_outlined, color: Colors.white, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Credit Management",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "Manage customer cards & entry",
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                            ],
                          ),
                        ),
                      ),

                      // const SizedBox(height: 12),
                      //
                      // /// My Sales History Card
                      // GestureDetector(
                      //   onTap: () {
                      //     context.push('/sales-history');
                      //   },
                      //   child: Container(
                      //     width: double.infinity,
                      //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                      //     decoration: BoxDecoration(
                      //       gradient: LinearGradient(
                      //         colors: [Colors.blue[400]!, Colors.blue[200]!],
                      //         begin: Alignment.topLeft,
                      //         end: Alignment.bottomRight,
                      //       ),
                      //       borderRadius: BorderRadius.circular(16),
                      //       boxShadow: [
                      //         BoxShadow(
                      //           color: Colors.blue.withOpacity(0.2),
                      //           blurRadius: 10,
                      //           offset: const Offset(0, 4),
                      //         ),
                      //       ],
                      //     ),
                      //     child: Row(
                      //       children: [
                      //         Container(
                      //           padding: const EdgeInsets.all(10),
                      //           decoration: BoxDecoration(
                      //             color: Colors.white.withOpacity(0.2),
                      //             shape: BoxShape.circle,
                      //           ),
                      //           child: const Icon(Icons.history_edu, color: Colors.white, size: 20),
                      //         ),
                      //         const SizedBox(width: 12),
                      //         Expanded(
                      //           child: Column(
                      //             crossAxisAlignment: CrossAxisAlignment.start,
                      //             children: [
                      //               const Text(
                      //                 "My Sales History",
                      //                 style: TextStyle(
                      //                   color: Colors.white,
                      //                   fontSize: 14,
                      //                   fontWeight: FontWeight.w800,
                      //                 ),
                      //               ),
                      //               const SizedBox(height: 2),
                      //               Text(
                      //                 "View all your past sales & forms",
                      //                 style: TextStyle(
                      //                   color: Colors.white.withOpacity(0.8),
                      //                   fontSize: 11,
                      //                 ),
                      //               ),
                      //             ],
                      //           ),
                      //         ),
                      //         const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                      //       ],
                      //     ),
                      //   ),
                      // ),

                      if (provider.totalTestingAllowed > 0) ...[
                        const SizedBox(height: 12),

                        /// Log Test Info Card
                        GestureDetector(
                          onTap: () {
                            context.push('/log-test-info');
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.amber[200]!, Colors.amber[200]!],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.amber.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.note_alt, color: Colors.black87, size: 22),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    "TESTING (${provider.testingNozzles.length})",
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ),
                                const Icon(Icons.arrow_forward_ios, color: Colors.black87, size: 16),
                              ],
                            ),
                          ),
                        ),
                      ],

                      if (provider.showCloseShift) ...[
                        const SizedBox(height: 12),

                        /// Close My Shift Card
                        GestureDetector(
                          onTap: () {
                            context.push('/checkout-form');
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.red[300]!, Colors.red[200]!],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.timer_off_outlined, color: Colors.white, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Close My Shift",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                              ],
                            ),
                          ),
                        ),
                      ],
                      if (provider.showCompleteSales) ...[
                        const SizedBox(height: 12),
                        /// Sales Entry Card
                        GestureDetector(
                          onTap: () {
                            context.push('/sales-entry');
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF00897B), Color(0xFF4DB6AC)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF00897B).withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.point_of_sale_outlined, color: Colors.white, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Sales Entry",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        "Record and submit daily sales figures",
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.8),
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                              ],
                            ),
                          ),
                        ),
                      ],
                      //
                      // if (provider.showCompleteSales) ...[
                      //   const SizedBox(height: 12),
                      //
                      //   /// Complete Your Sales Entry Card
                      //   GestureDetector(
                      //     onTap: () {
                      //       context.push('/calculated-details');
                      //     },
                      //     child: Container(
                      //       width: double.infinity,
                      //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                      //       decoration: BoxDecoration(
                      //         gradient: LinearGradient(
                      //           colors: [Colors.green[300]!, Colors.green[400]!],
                      //           begin: Alignment.topLeft,
                      //           end: Alignment.bottomRight,
                      //         ),
                      //         borderRadius: BorderRadius.circular(16),
                      //         boxShadow: [
                      //           BoxShadow(
                      //             color: Colors.green.withOpacity(0.2),
                      //             blurRadius: 10,
                      //             offset: const Offset(0, 4),
                      //           ),
                      //         ],
                      //       ),
                      //       child: Row(
                      //         children: [
                      //           Container(
                      //             padding: const EdgeInsets.all(10),
                      //             decoration: BoxDecoration(
                      //               color: Colors.white.withOpacity(0.2),
                      //               shape: BoxShape.circle,
                      //             ),
                      //             child: const Icon(Icons.assignment_turned_in_outlined, color: Colors.white, size: 20),
                      //           ),
                      //           const SizedBox(width: 12),
                      //           Expanded(
                      //             child: Column(
                      //               crossAxisAlignment: CrossAxisAlignment.start,
                      //               children: [
                      //                 const Text(
                      //                   "My Sales",
                      //                   style: TextStyle(
                      //                     color: Colors.white,
                      //                     fontSize: 13,
                      //                     fontWeight: FontWeight.w800,
                      //                   ),
                      //                 ),
                      //               ],
                      //             ),
                      //           ),
                      //           const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                      //         ],
                      //       ),
                      //     ),
                      //   ),
                      // ],

                      // const SizedBox(height: 12),
                      //
                      // /// Calculated Sales Details Card
                      // GestureDetector(
                      //   onTap: () {
                      //     context.push('/calculated-details');
                      //   },
                      //   child: Container(
                      //     width: double.infinity,
                      //     padding: const EdgeInsets.all(16),
                      //     decoration: BoxDecoration(
                      //       color: Colors.white,
                      //       borderRadius: BorderRadius.circular(16),
                      //       border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                      //       boxShadow: [
                      //         BoxShadow(
                      //           color: Colors.black.withOpacity(0.04),
                      //           blurRadius: 10,
                      //           offset: const Offset(0, 4),
                      //         ),
                      //       ],
                      //     ),
                      //     child: Row(
                      //       children: [
                      //         Container(
                      //           padding: const EdgeInsets.all(10),
                      //           decoration: BoxDecoration(
                      //             color: Colors.orangeAccent.withOpacity(0.1),
                      //             shape: BoxShape.circle,
                      //           ),
                      //           child: const Icon(Icons.calculate_outlined, color: Colors.orangeAccent, size: 20),
                      //         ),
                      //         const SizedBox(width: 12),
                      //         Expanded(
                      //           child: Column(
                      //             crossAxisAlignment: CrossAxisAlignment.start,
                      //             children: [
                      //               const Text(
                      //                 "Calculated Sales Details",
                      //                 style: TextStyle(
                      //                   color: AppColors.textDark,
                      //                   fontSize: 14,
                      //                   fontWeight: FontWeight.w700,
                      //                 ),
                      //               ),
                      //               const SizedBox(height: 2),
                      //               Text(
                      //                 "Summarized nozzle-wise sales",
                      //                 style: TextStyle(
                      //                   color: AppColors.textDark.withOpacity(0.5),
                      //                   fontSize: 11,
                      //                 ),
                      //               ),
                      //             ],
                      //           ),
                      //         ),
                      //         const Icon(Icons.arrow_forward_ios, color: AppColors.primary, size: 16),
                      //       ],
                      //     ),
                      //   ),
                      // ),

                      const SizedBox(height: 8),
                      /// Active Nozzles Header
                      Row(
                        children: [

                          const Icon(
                            Icons.local_gas_station,
                            color: AppColors.primary,
                            size: 18,
                          ),

                          const SizedBox(width: 8),

                          const Text(
                            "My Selected Nozzles",
                            style: TextStyle(
                              color: AppColors.textDark,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(width: 4),

                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "${provider.mySelectedNozzles.length}",
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),

                          const Spacer(),

                          TextButton.icon(
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              context.push('/add-nozzles');
                            },
                            icon: const Icon(Icons.add, color: AppColors.primary, size: 18),
                            label: const Text(
                              "Add Nozzles",
                              style: TextStyle(
                                color: AppColors.textDark,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      // Nozzle List Section
                      if (provider.mySelectedNozzles.isEmpty && !provider.isLoading)
                        Column(
                          children: [
                            SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                            Center(
                              child: Column(
                                children: [
                                  Icon(Icons.no_drinks_outlined, size: 64, color: Colors.white.withOpacity(0.2)),
                                  const SizedBox(height: 16),
                                  Text(
                                    provider.error ?? "No nozzles added yet.\nTap 'Add Nozzles' to get started.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: AppColors.textDark.withOpacity(0.5), fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      else
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 1,
                            mainAxisSpacing: 16,
                            mainAxisExtent: 180,
                          ),
                          itemCount: provider.mySelectedNozzles.length,
                          itemBuilder: (context, index) {
                            final nozzle = provider.mySelectedNozzles[index];

                            void handleNavigation() {
                              // if (!provider.selectedNozzleCodes.contains(nozzle.id)) {
                              //   provider.toggleNozzleSelection(nozzle.id);
                              // }
                              // final List<Nozzle> allDashboardNozzles = provider.mySelectedNozzles;
                              // context.push('/sales-form', extra: {
                              //   'selectedNozzles': allDashboardNozzles,
                              //   'initialIndex': index,
                              // });
                            }

                            return GestureDetector(
                              onTap: handleNavigation,
                              child: NozzleCard(
                                number: nozzle.number,
                                fuelType: nozzle.fuelType,
                                fuelTypeCode: nozzle.fuelTypeCode,
                                unitPrice: nozzle.unitPrice,
                                status: nozzle.status,
                                showStatus: true,
                                isSelected: provider.selectedNozzleCodes.contains(nozzle.id),
                                actionLabel: "Start Sales",
                                salesman: nozzle.salesman,
                                onSelect: handleNavigation,
                                onDeselect: () => _showCloseNozzleModal(context, nozzle),
                              ),
                            );
                          },
                        ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDipDensityButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}