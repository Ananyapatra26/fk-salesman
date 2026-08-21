class LoginRequest {
  final String mobile;
  final String dialingCode;

  LoginRequest({
    required this.mobile,
    this.dialingCode = '91',
  });

  Map<String, dynamic> toJson() {
    return {
      'mobile': mobile,
      'dialing_code': dialingCode,
    };
  }
}

class OtpRequest {
  final String mobile;
  final String dialingCode;
  final String otp;

  OtpRequest({
    required this.mobile,
    this.dialingCode = '91',
    required this.otp,
  });

  Map<String, dynamic> toJson() {
    return {
      'mobile': mobile,
      'dialing_code': dialingCode,
      'otp': otp,
    };
  }
}
