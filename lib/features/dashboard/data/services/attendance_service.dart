import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fk_salesman/core/utils/api_constants.dart';
import 'package:fk_salesman/core/utils/session_manager.dart';
import 'package:fk_salesman/features/dashboard/domain/models/attendance_record_model.dart';
import 'package:fk_salesman/features/dashboard/domain/models/sales_history_model.dart';

class AttendanceService {
  Future<bool> markAttendance(String type, {Map<String, dynamic>? readings}) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.markAttendance}');
    final token = SessionManager.getToken();

    try {
      final body = jsonEncode({
        'type': type,
        if (readings != null) ...readings,
      });
      print('--- MARK ATTENDANCE REQUEST ---');
      print('URL: $url');
      print('BODY: $body');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: body,
      );

      final responseData = jsonDecode(response.body);
      print('STATUS: ${response.statusCode}');
      print('RESPONSE: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw Exception(responseData['message'] ?? 'Failed to mark attendance');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: $e');
    }
  }

  Future<bool> closeShift(Map<String, dynamic> readings) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.closeShift}');
    final token = SessionManager.getToken();

    try {
      final body = jsonEncode(readings);
      print('--- CLOSE SHIFT REQUEST ---');
      print('URL: $url');
      print('BODY: $body');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: body,
      );

      final responseData = jsonDecode(response.body);
      print('STATUS: ${response.statusCode}');
      print('RESPONSE: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw Exception(responseData['message'] ?? 'Failed to close shift');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: $e');
    }
  }

  Future<List<AttendanceRecord>> getAttendanceRecords() async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.attendanceRecords}');
    final token = SessionManager.getToken();

    print('--- ATTENDANCE RECORDS REQUEST ---');
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
        final List<dynamic> recordsData = responseData['data'] ?? [];
        return recordsData.map((data) => AttendanceRecord.fromJson(data)).toList();
      } else {
        throw Exception(responseData['message'] ?? 'Failed to fetch attendance records');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: $e');
    }
  }

  Future<List<SaleRecord>> getSalesHistory() async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.myNozzleWiseSales}');
    print(url);
    final token = SessionManager.getToken();

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
      print(response.statusCode);
      print(response.body);
      if (response.statusCode == 200) {
        final salesResponse = SalesHistoryResponse.fromJson(responseData);
        return salesResponse.data.sales.data;
      } else {
        throw Exception(responseData['message'] ?? 'Failed to fetch sales history');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: $e');
    }
  }
}
