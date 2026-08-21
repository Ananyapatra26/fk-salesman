import '../models/auth_models.dart';
import '../services/auth_service.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService = AuthService();

  @override
  Future<void> sendOtp(String phoneNumber, {String dialingCode = '91'}) async {
    final request = LoginRequest(mobile: phoneNumber, dialingCode: dialingCode);
    await _authService.sendOtp(request);
  }

  @override
  Future<String> verifyOtp(String phoneNumber, String otp, {String dialingCode = '91'}) async {
    final request = OtpRequest(mobile: phoneNumber, dialingCode: dialingCode, otp: otp);
    final responseData = await _authService.verifyOtp(request);

    if (responseData['data'] != null && responseData['data']['token'] != null) {
      return responseData['data']['token'];
    }
    throw Exception('Token not found in response');
  }

  @override
  Future<void> logout() async {
    await _authService.logout();
  }
}
