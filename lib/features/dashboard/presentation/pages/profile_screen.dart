import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:fk_salesman/core/constants/app_text_styles.dart';
import 'package:fk_salesman/core/constants/app_colors.dart';
import 'package:fk_salesman/core/widgets/app_alert.dart';
import 'package:fk_salesman/features/dashboard/presentation/providers/dashboard_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/models/attendance_record_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoggingOut = false;
  bool _isCheckingOut = false;

  @override
  void initState() {
    super.initState();
    _checkAttendance();
  }

  Future<void> _checkAttendance() async {
    // Fetch records from API via provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().fetchAttendanceRecords();
    });
  }

  Future<void> _showLogoutConfirmation() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.background,
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
      setState(() {
        _isLoggingOut = true;
      });

      final authProvider = context.read<AuthProvider>();
      await authProvider.logout();

      // Clear all dashboard data (profile, nozzles, etc) for the next login
      if (mounted) {
        await context.read<DashboardProvider>().logout();
      }

      if (mounted) {
        setState(() {
          _isLoggingOut = false;
        });
        context.go('/login');
      }
    }
  }

  Future<void> _showCheckoutConfirmation() async {
    final shouldCheckout = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Check-out",
            style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            "Are you sure you want to check out?",
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
                backgroundColor: AppColors.primary,
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

    if (shouldCheckout == true) {
      setState(() {
        _isCheckingOut = true;
      });

      try {
        final provider = context.read<DashboardProvider>();
        final success = await provider.markAttendance('checkout');

        if (mounted) {
          if (success) {
            AppAlert.showSuccess(
              context,
              message: 'Checked out successfully!',
            );
          } else {
            AppAlert.showError(
              context,
              message: provider.error ?? 'Failed to check out',
            );
          }
        }
      } catch (e) {
        if (mounted) {
          AppAlert.showError(
            context,
            message: 'Error: $e',
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isCheckingOut = false;
          });
        }
      }
    }
  }

  Future<void> _handleCheckout() async {
    context.push('/checkout-form');
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DashboardProvider>();
    final profile = provider.profile;

    // Find today's record
    final today = DateTime.now().toString().substring(0, 10);
    AttendanceRecord? todayRecord;
    try {
      todayRecord = provider.attendanceRecords.firstWhere(
        (r) => r.attendanceDate.startsWith(today),
      );
    } catch (_) {
      todayRecord = null;
    }

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            title: const Text(
              "Profile",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, size: 18),
              onPressed: () => context.pop(),
            ),
          ),
          backgroundColor: const Color(0xFFF8F9FA),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Header Background & Profile Picture overlapping
                Stack(
                  alignment: Alignment.topCenter,
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      height: 70,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          image: profile?.photo != null
                              ? DecorationImage(
                                  image: NetworkImage(profile!.photo!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: profile?.photo == null
                            ? const Icon(
                                Icons.person,
                                color: Colors.black12,
                                size: 60,
                              )
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 70), // Spacer for overlapping avatar
                // Name & Email
                Text(
                  profile?.name ?? "Salesman",
                  style: AppTextStyles.h2.copyWith(
                    color: AppColors.textDark,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile?.email ?? "No email provided",
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.black54,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 32),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      // Info Grid
                      Row(
                        children: [
                          _buildInfoItem(
                            Icons.badge_outlined,
                            "Employee ID",
                            profile?.employeeId ?? "NA",
                          ),
                          const SizedBox(width: 16),
                          _buildInfoItem(
                            Icons.phone_android,
                            "Mobile",
                            profile?.mobile ?? "NA",
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // Attendance Section
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.black.withOpacity(0.06),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.event_available,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  "Today's Attendance",
                                  style: TextStyle(
                                    color: AppColors.textDark,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(color: Colors.black12, height: 32),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Check-in",
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      todayRecord?.checkinTime ?? "--:--",
                                      style: const TextStyle(
                                        color: AppColors.textDark,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  height: 40,
                                  width: 1,
                                  color: Colors.black12,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onTap: _isCheckingOut 
                                          ? null 
                                          : _showCheckoutConfirmation,
                                      child: const Text(
                                        "Check-out",
                                        style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    if (todayRecord != null &&
                                        todayRecord.checkIn != null &&
                                        todayRecord.checkOut == null)
                                      GestureDetector(
                                        onTap: _isCheckingOut 
                                            ? null 
                                            : _showCheckoutConfirmation,
                                        child: Row(
                                          children: [
                                            const Text(
                                              "--",
                                              style: TextStyle(
                                                color: AppColors.primary,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    else
                                      Text(
                                        todayRecord?.checkoutTime ?? "--:--",
                                        style: const TextStyle(
                                          color: AppColors.textDark,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                            if (todayRecord?.checkIn != null &&
                                todayRecord?.checkOut == null) ...[
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent
                                        .withOpacity(0.1),
                                    foregroundColor: Colors.redAccent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                    elevation: 0,
                                  ),
                                  onPressed: _isCheckingOut 
                                      ? null 
                                      : _showCheckoutConfirmation,
                                  icon: const Icon(
                                    Icons.logout,
                                    color: Colors.redAccent,
                                    size: 18,
                                  ),
                                  label: const Text(
                                    "CHECKOUT NOW",
                                    style: TextStyle(
                                      color: Colors.redAccent,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: TextButton.icon(
                                style: TextButton.styleFrom(
                                  backgroundColor: AppColors.primary
                                      .withOpacity(0.08),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                                onPressed: () {
                                  context.push('/my-attendance');
                                },
                                icon: const Icon(
                                  Icons.history,
                                  color: AppColors.primary,
                                  size: 18,
                                ),
                                label: const Text(
                                  "View My Attendance History",
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Logout Button
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: OutlinedButton.icon(
                          onPressed: _isLoggingOut
                              ? null
                              : _showLogoutConfirmation,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: Colors.redAccent.withOpacity(0.5),
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            backgroundColor: Colors.white,
                          ),
                          icon: const Icon(
                            Icons.power_settings_new,
                            color: Colors.redAccent,
                            size: 20,
                          ),
                          label: Text(
                            "LOGOUT",
                            style: AppTextStyles.buttonText.copyWith(
                              color: Colors.redAccent,
                              letterSpacing: 2.0,
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Loader Overlay Map
        if (_isLoggingOut || _isCheckingOut)
          Container(
            color: Colors.black54,
            child: const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black.withOpacity(0.06), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(height: 16),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: Colors.black54,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppTextStyles.labelBold.copyWith(
                color: AppColors.textDark,
                fontSize: 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
