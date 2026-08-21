import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/utils/api_constants.dart';
import '../../../../core/utils/session_manager.dart';
import '../models/customer_credit_model.dart';

class CreditService {
  Future<CustomerCreditResponse> getCustomerCredits({int page = 1}) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.customerCredits}?page=$page');
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

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return CustomerCreditResponse.fromJson(responseData);
      } else {
        final responseData = jsonDecode(response.body);
        throw Exception(responseData['message'] ?? 'Failed to load customer credits');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: $e');
    }
  }

  Future<CustomerCreditDetailResponse> getCustomerCreditDetail(String code) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.customerCredits}/$code');
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

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return CustomerCreditDetailResponse.fromJson(responseData);
      } else {
        final responseData = jsonDecode(response.body);
        throw Exception(responseData['message'] ?? 'Failed to load credit details');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: $e');
    }
  }

  Future<bool> submitCreditEntry({
    required String creditCode,
    required String nozzle,
    required double amount,
    required double quantity,
    required double fuelTypeUnitPrice,
    File? image1,
    File? image2,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.customerCreditNewTransaction}');
    final token = SessionManager.getToken();

    try {
      var request = http.MultipartRequest('POST', url);
      
      request.headers.addAll({
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      });

      request.fields['credit_code'] = creditCode;
      request.fields['nozzle'] = nozzle;
      request.fields['amount'] = amount.toString();
      request.fields['quantity'] = quantity.toString();
      request.fields['fuel_type_unit_price'] = fuelTypeUnitPrice.toString();

      if (image1 != null) {
        request.files.add(await http.MultipartFile.fromPath('image_1', image1.path));
      }
      if (image2 != null) {
        request.files.add(await http.MultipartFile.fromPath('image_2', image2.path));
      }

      print("DEBUG: Submitting Credit Entry Request:");
      print("URL: $url");
      print("Headers: ${request.headers}");
      print("Fields: ${request.fields}");
      print("Files: ${request.files.map((f) => '${f.field}: ${f.filename}').toList()}");

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print("DEBUG: Credit Entry Response:");
      print("URL: $url");
      print("Status: ${response.statusCode}");
      print("Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        final responseData = jsonDecode(response.body);
        throw Exception(responseData['message'] ?? 'Failed to submit credit entry');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: $e');
    }
  }
}
