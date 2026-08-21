abstract class AuthRepository {
  Future<void> sendOtp(String phoneNumber, {String dialingCode = '91'});
  Future<String> verifyOtp(String phoneNumber, String otp, {String dialingCode = '91'});
  Future<void> logout();
}
