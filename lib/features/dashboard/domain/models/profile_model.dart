class ProfileResponse {
  final bool success;
  final DashboardData? data;

  ProfileResponse({
    required this.success,
    this.data,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      success: json['success'] ?? false,
      data: json['data'] != null ? DashboardData.fromJson(json['data']) : null,
    );
  }
}

class DashboardData {
  final UserProfile? salesman;
  final CurrentWorkShift? currentWorkShift;
  final int totalTestingAllowed;
  final bool closeMyShift;
  final bool completeMySalesEntry;
  final bool dipEntryAllowed;
  final bool densityEntryAllowed;

  DashboardData({
    this.salesman,
    this.currentWorkShift,
    required this.totalTestingAllowed,
    this.closeMyShift = false,
    this.completeMySalesEntry = false,
    this.dipEntryAllowed = false,
    this.densityEntryAllowed = false,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      salesman: json['salesman'] != null ? UserProfile.fromJson(json['salesman']) : null,
      currentWorkShift: json['current_work_shift'] != null ? CurrentWorkShift.fromJson(json['current_work_shift']) : null,
      totalTestingAllowed: json['total_testing_allowed'] ?? 0,
      closeMyShift: json['close_my_shift'] ?? false,
      completeMySalesEntry: json['complete_my_sales_entry'] ?? false,
      dipEntryAllowed: json['dip_entry_allowed'] ?? false,
      densityEntryAllowed: json['density_entry_allowed'] ?? false,
    );
  }
}

class CurrentWorkShift {
  final String? currentDatetime;
  final String? id;
  final String? code;
  final String? name;
  final String? desc;
  final String? startTime;
  final String? endTime;

  CurrentWorkShift({
    this.currentDatetime,
    this.id,
    this.code,
    this.name,
    this.desc,
    this.startTime,
    this.endTime,
  });

  factory CurrentWorkShift.fromJson(Map<String, dynamic> json) {
    return CurrentWorkShift(
      currentDatetime: json['current_datetime'],
      id: json['id'],
      code: json['code'],
      name: json['name'],
      desc: json['desc'],
      startTime: json['start_time'],
      endTime: json['end_time'],
    );
  }
}

class UserProfile {
  final String employeeId;
  final String name;
  final String? photo;
  final String mobile;
  final bool isMobileVerified;
  final String? gender;
  final String? dob;
  final String? pan;
  final String? email;
  final bool? isEmailVerified;
  final String? createdAt;
  final String? updatedAt;

  UserProfile({
    required this.employeeId,
    required this.name,
    this.photo,
    required this.mobile,
    required this.isMobileVerified,
    this.gender,
    this.dob,
    this.pan,
    this.email,
    this.isEmailVerified,
    this.createdAt,
    this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      employeeId: json['employee_id'] ?? '',
      name: json['name'] ?? '',
      photo: json['photo'],
      mobile: json['mobile'] ?? '',
      isMobileVerified: json['is_mobile_verified'] ?? false,
      gender: json['gender'],
      dob: json['dob'],
      pan: json['pan'],
      email: json['email'],
      isEmailVerified: json['is_email_verified'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}
