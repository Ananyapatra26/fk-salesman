import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/utils/api_constants.dart';
import '../../../../core/utils/session_manager.dart';
import '../models/sales_entry_model.dart';
import '../models/payment_method_model.dart';

class SalesService {
  Future<Map<String, dynamic>> storeSalesEntry(SalesEntryModel model) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.storeSales}');
    print("Request Body...............................: $url");
    final token = SessionManager.getToken();

    try {
      // Convert model to JSON
      final requestBody = jsonEncode(model.toJson());

      // Print Request Body
      print("Request Body...............................: $requestBody");

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: requestBody,
      );
      print("987654657890-987654567890------------------------------S");
      print(requestBody);
      final responseData = jsonDecode(response.body);

      print("Response Data....: $responseData");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return responseData;
      } else {
        print("Status Code: ${response.statusCode}");
        print("Response Body: ${response.body}");

        if (responseData['errors'] != null) {
          final errors = responseData['errors'] as Map<String, dynamic>;
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            throw Exception(firstError.first);
          }
        }
        throw Exception(responseData['message'] ?? 'Failed to save sales entry');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: $e');
    }
  }

  Future<List<PaymentMethod>> getPaymentMethods() async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.paymentMethods}');
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

      print("GET URL: $url");
      print("GET Payment Methods Response: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> list = responseData['data'];
          return list.map((item) => PaymentMethod.fromJson(item)).toList();
        }
      }
      throw Exception('Failed to load payment methods');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> submitShiftWiseSales(List<Map<String, dynamic>> sales) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.shiftWiseSales}');
    final token = SessionManager.getToken();

    try {
      final body = {
        "sales": sales,
      };

      final requestBody = jsonEncode(body);
      print("POST URL: $url");
      print("POST Body: $requestBody");

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: requestBody,
      );

      print("POST Response Status: ${response.statusCode}");
      print("POST Response Body: ${response.body}");

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return responseData;
      } else {
        if (responseData['errors'] != null) {
          final errors = responseData['errors'] as Map<String, dynamic>;
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            throw Exception(firstError.first);
          }
        }
        throw Exception(responseData['message'] ?? 'Failed to submit shift wise sales');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: $e');
    }
  }
}