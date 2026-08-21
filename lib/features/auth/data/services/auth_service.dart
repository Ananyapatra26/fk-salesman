import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/utils/api_constants.dart';
import '../../../../core/utils/session_manager.dart';
import '../models/auth_models.dart';

class AuthService {
  Future<Map<String, dynamic>> sendOtp(LoginRequest request) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.login}');
    final body = jsonEncode(request.toJson());
    
    print('--- SEND OTP REQUEST ---');
    print('URL: $url');
    print('BODY: $body');
    
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: body,
      );

      final responseData = jsonDecode(response.body);
      print('RESPONSE: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return responseData;
      } else {
        throw Exception(responseData['message'] ?? 'Failed to send OTP');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> verifyOtp(OtpRequest request) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.login}?otpVerification=yes');
    final body = jsonEncode(request.toJson());

    print('--- VERIFY OTP REQUEST ---');
    print('URL: $url');
    print('BODY: $body');
    
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: body,
      );

      final responseData = jsonDecode(response.body);
      print('RESPONSE: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return responseData;
      } else {
        throw Exception(responseData['message'] ?? 'Failed to verify OTP');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: $e');
    }
  }
  Future<void> logout() async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.logout}');
    final token = SessionManager.getToken();
    
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        final responseData = jsonDecode(response.body);
        throw Exception(responseData['message'] ?? 'Failed to logout');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error during logout: $e');
    } finally {
      await SessionManager.logout();
    }
  }
}
