import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/utils/api_constants.dart';
import '../../../../core/utils/session_manager.dart';
import '../../../../features/sales/data/models/nozzle_detail_response_model.dart';
import '../../domain/models/nozzle_response_model.dart';

class NozzleService {
  Future<NozzleDetailResponse> getNozzleDetails(String nozzleId) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.selectedNozzles}/$nozzleId');
    final token = SessionManager.getToken();

    print('--- GET NOZZLE DETAILS REQUEST ---');
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
        return NozzleDetailResponse.fromJson(responseData);
      } else {
        throw Exception(responseData['message'] ?? 'Failed to fetch nozzle details');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: $e');
    }
  }

  Future<NozzleResponse> getNozzles() async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.dashboard}');
    final token = SessionManager.getToken();

    print('--- GET ALL NOZZLES REQUEST ---');
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
        return NozzleResponse.fromJson(responseData);
      } else {
        throw Exception(responseData['message'] ?? 'Failed to fetch nozzle details');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: $e');
    }
  }

  Future<NozzleResponse> getSelectedNozzles() async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.selectedNozzles}');
    final token = SessionManager.getToken();

    print('--- GET SELECTED NOZZLES REQUEST ---');
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
        return NozzleResponse.fromJson(responseData);
      } else {
        throw Exception(responseData['message'] ?? 'Failed to fetch selected nozzles');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: $e');
    }
  }

  Future<bool> selectNozzle(String nozzleCode) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.selectNozzle}');
    final token = SessionManager.getToken();

    try {
      final bodyData = {
        'nozzle': nozzleCode,
      };

      print("--- SELECT NOZZLE REQUEST ---");
      print("URL: $url");
      print("BODY: ${jsonEncode(bodyData)}");

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(bodyData),
      );

      final responseData = jsonDecode(response.body);
      print("STATUS: ${response.statusCode}");
      print("RESPONSE: ${response.body}");

      if ((response.statusCode == 200 || response.statusCode == 201) && responseData['success'] == true) {
        return true;
      } else {
        throw Exception(responseData['message'] ?? 'Operation failed');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: $e');
    }
  }

  Future<bool> deselectNozzle(String nozzleCode, {String? closingReading}) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.deselectNozzle}');
    final token = SessionManager.getToken();

    try {
      final bodyData = {
        'nozzle': nozzleCode,
        if (closingReading != null) 'closing_reading_no': closingReading,
      };

      print("--- DESELECT NOZZLE REQUEST ---");
      print("URL: $url");
      print("BODY: ${jsonEncode(bodyData)}");

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(bodyData),
      );

      print("--- DESELECT NOZZLE RESPONSE ---");
      print("URL: $url");
      print("REQUEST BODY: ${jsonEncode(bodyData)}");
      print("STATUS: ${response.statusCode}");
      print("RESPONSE: ${response.body}");

      final responseData = jsonDecode(response.body);

      if ((response.statusCode == 200 || response.statusCode == 201) && responseData['success'] == true) {
        return true;
      } else {
        throw Exception(responseData['message'] ?? 'Failed to remove nozzle');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: $e');
    }
  }
  Future<NozzleResponse> getNozzlesForTesting() async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.nozzlesForTesting}');
    final token = SessionManager.getToken();

    print('--- GET NOZZLES FOR TESTING REQUEST ---');
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
        return NozzleResponse.fromJson(responseData);
      } else {
        throw Exception(responseData['message'] ?? 'Failed to fetch nozzles for testing');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: $e');
    }
  }

  Future<NozzleResponse> getNozzlesForLogTest() async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.nozzlesForTesting}');
    final token = SessionManager.getToken();

    print('--- GET NOZZLES FOR LOG TEST REQUEST ---');
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
        return NozzleResponse.fromJson(responseData);
      } else {
        throw Exception(responseData['message'] ?? 'Failed to fetch nozzles for log test');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: $e');
    }
  }
}
