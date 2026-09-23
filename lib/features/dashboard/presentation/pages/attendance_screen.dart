import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fk_salesman/core/constants/app_colors.dart';
import 'package:fk_salesman/core/widgets/app_alert.dart';
import 'package:fk_salesman/features/dashboard/presentation/providers/dashboard_provider.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  String selectedShift = "Morning";
  bool _isLoading = false;

  Future<void> _markAttendance() async {
    setState(() {
      _isLoading = true;
    });

    final provider = context.read<DashboardProvider>();
    final success = await provider.markAttendance('checkin');

    if (success && mounted) {
      final now = TimeOfDay.now();
      final hour = now.hourOfPeriod == 0 ? 12 : now.hourOfPeriod;
      final minute = now.minute.toString().padLeft(2, '0');
      final period = now.period == DayPeriod.am ? 'AM' : 'PM';
      final timeFormatted = '$hour:$minute $period';

      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toString().substring(0, 10);

      await prefs.setString("attendance_date", today);
      await prefs.setString("attendance_time", timeFormatted);
      await prefs.setString("attendance_shift", selectedShift);

      await AppAlert.showSuccess(
        context,
        message: 'Attendance Marked Successfully!',
      );
      
      if (mounted) context.go('/dashboard');
    } else if (mounted) {
      setState(() {
        _isLoading = false;
      });
      AppAlert.showError(
        context,
        message: provider.error ?? 'Failed to mark attendance',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = TimeOfDay.now();
    final hour = now.hourOfPeriod == 0 ? 12 : now.hourOfPeriod;
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.period == DayPeriod.am ? 'AM' : 'PM';
    final timeFormatted = '$hour:$minute $period';

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: const Text('Mark Your Attendance', style: TextStyle(color: Colors.white, fontSize: 18)),
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        automaticallyImplyLeading: false, 
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Please mark your attendance before continuing.",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 32),
                
                // Date Details
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Date:", style: TextStyle(color: Colors.white, fontSize: 16)),
                    Text(
                      DateTime.now().toString().substring(0, 10),
                      style: const TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Time Details
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Time:", style: TextStyle(color: Colors.white, fontSize: 16)),
                    Text(
                      timeFormatted,
                      style: const TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                
                // Shift Dropdown
                const Text("Select Shift", style: TextStyle(color: Colors.white, fontSize: 16)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: selectedShift,
                      dropdownColor: const Color(0xFF2D2D2D),
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                      items: ["Morning", "Evening", "Night"]
                          .map((shift) => DropdownMenuItem(
                                value: shift,
                                child: Text(shift),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedShift = value!;
                        });
                      },
                    ),
                  ),
                ),
                
                const Spacer(),
                
                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    onPressed: _isLoading ? null : _markAttendance,
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(
                            "CHECK IN",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.5,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
        ],
      ),
    );
  }
}
