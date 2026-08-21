import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fk_salesman/core/utils/api_constants.dart';
import 'package:fk_salesman/core/utils/session_manager.dart';
import '../../domain/models/calculated_sales_model.dart';

class CalculatedSalesService {
  Future<CalculatedSalesResponse> fetchCalculatedSales() async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.calculatedSales}');
    final token = SessionManager.getToken();

    try {
      print("--- FETCH CALCULATED SALES REQUEST ---");
      print("URL: $url");

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      print("--- FETCH CALCULATED SALES RESPONSE ---");
      print("STATUS: ${response.statusCode}");
      print("RESPONSE: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return CalculatedSalesResponse.fromJson(jsonDecode(response.body));
      } else {
        final data = jsonDecode(response.body);
        return CalculatedSalesResponse(
          success: false,
          message: data['message'] ?? 'Failed to fetch calculated sales',
        );
      }
    } catch (e) {
      return CalculatedSalesResponse(
        success: false,
        message: 'Network error: $e',
      );
    }
  }
}
