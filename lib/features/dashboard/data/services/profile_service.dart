import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/utils/api_constants.dart';
import '../../../../core/utils/session_manager.dart';
import '../../domain/models/profile_model.dart';

class ProfileService {
  Future<ProfileResponse> getProfile() async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.dashboardInfo}');
    final token = SessionManager.getToken();

    print('--- PROFILE REQUEST ---');
    print('URL: $url');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body);
      print('STATUS: ${response.statusCode}');
      print('RESPONSE: ${response.body}');

      if (response.statusCode == 200) {
        return ProfileResponse.fromJson(responseData);
      } else {
        throw Exception(responseData['message'] ?? 'Failed to fetch profile details');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: $e');
    }
  }
}
