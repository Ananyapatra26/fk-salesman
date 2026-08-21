class AttendanceRecord {
  final String code;
  final int employeeId;
  final String attendanceDate;
  final String? checkIn;
  final String? checkOut;
  final String status;

  AttendanceRecord({
    required this.code,
    required this.employeeId,
    required this.attendanceDate,
    this.checkIn,
    this.checkOut,
    required this.status,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      code: json['code'] as String? ?? '',
      employeeId: json['employee_id'] as int? ?? 0,
      attendanceDate: json['attendance_date'] as String? ?? '',
      checkIn: json['check_in'] as String?,
      checkOut: json['check_out'] as String?,
      status: json['status'] as String? ?? 'absent',
    );
  }

  // UI Helper Getters
  String get formattedDate => attendanceDate;
  
  String get checkinTime => _formatTo12Hour(checkIn);

  String get checkoutTime => _formatTo12Hour(checkOut);

  String _formatTo12Hour(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) return '--:--';
    try {
      // Handle "yyyy-MM-dd HH:mm:ss" or just "HH:mm:ss"
      String timePart = dateTimeStr.contains(' ') 
          ? dateTimeStr.split(' ')[1] 
          : dateTimeStr;
      
      List<String> parts = timePart.split(':');
      if (parts.length < 2) return timePart;

      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);
      
      String period = hour >= 12 ? 'PM' : 'AM';
      int displayHour = hour % 12;
      if (displayHour == 0) displayHour = 12;
      
      String displayMinute = minute.toString().padLeft(2, '0');
      
      return '$displayHour:$displayMinute $period';
    } catch (_) {
      return '--:--';
    }
  }

  String get shift => 'Shift 1'; // Placeholder if shift not in API
}

