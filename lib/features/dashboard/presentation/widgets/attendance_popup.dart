import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fk_salesman/core/constants/app_colors.dart';
import 'package:fk_salesman/core/widgets/app_alert.dart';
import 'package:fk_salesman/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:fk_salesman/features/auth/presentation/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

class AttendancePopup extends StatefulWidget {
  final VoidCallback onCheckedIn;

  const AttendancePopup({super.key, required this.onCheckedIn});

  @override
  State<AttendancePopup> createState() => _AttendancePopupState();
}

class _AttendancePopupState extends State<AttendancePopup> {
  bool _isLoading = false;
  bool _isLoggingOut = false;

  Future<void> _markAttendance() async {
    setState(() {
      _isLoading = true;
    });

    final provider = context.read<DashboardProvider>();
    final now = TimeOfDay.now();
    final hour = now.hourOfPeriod == 0 ? 12 : now.hourOfPeriod;
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.period == DayPeriod.am ? 'AM' : 'PM';
    final timeFormatted = '$hour:$minute $period';

    final success = await provider.markAttendance('checkin');

    if (success) {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toString().substring(0, 10);

      await prefs.setString("attendance_date", today);
      await prefs.setString("attendance_time", timeFormatted);

      if (mounted) {
        widget.onCheckedIn();
        AppAlert.showSuccess(
          context,
          message: 'Attendance Marked Successfully!',
        );
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        AppAlert.showError(
          context,
          message: provider.error ?? 'Failed to mark attendance',
        );
      }
    }
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
        setState(() {
          _isLoggingOut = true;
        });

        final authProvider = context.read<AuthProvider>();
        await authProvider.logout();
        await context.read<DashboardProvider>().logout();

        if (mounted) {
          setState(() {
            _isLoggingOut = false;
          });
          context.go('/login');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Container(
                  //   padding: const EdgeInsets.all(16),
                  //   decoration: BoxDecoration(
                  //     color: AppColors.primary.withOpacity(0.1),
                  //     shape: BoxShape.circle,
                  //   ),
                  //   child: const Icon(
                  //     Icons.fingerprint_rounded,
                  //     color: AppColors.primary,
                  //     size: 40,
                  //   ),
                  // ),
                  const SizedBox(height: 24),
                  const Text(
                    'DAILY ATTENDANCE',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Please mark your attendance to access the sales dashboard.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textDark.withOpacity(0.5),
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Details Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.black.withOpacity(0.05)),
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow("Date", DateTime.now().toString().substring(0, 10), Icons.calendar_today),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(height: 1, color: Colors.black12),
                        ),
                        _buildDetailRow("Time", _getFormattedTime(), Icons.access_time),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Action Buttons
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      onPressed: _isLoading || _isLoggingOut ? null : _markAttendance,
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                            )
                          : const Text(
                              "CHECK IN",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 2,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: TextButton.icon(
                      onPressed: _isLoading || _isLoggingOut ? null : _showLogoutConfirmation,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.power_settings_new, size: 18),
                      label: const Text(
                        "LOGOUT",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_isLoggingOut)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.black54, fontSize: 13, fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(color: AppColors.textDark, fontSize: 14, fontWeight: FontWeight.w900),
        ),
      ],
    );
  }

  String _getFormattedTime() {
    final now = TimeOfDay.now();
    final hour = now.hourOfPeriod == 0 ? 12 : now.hourOfPeriod;
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}
