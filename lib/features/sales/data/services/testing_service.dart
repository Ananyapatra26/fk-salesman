import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/utils/api_constants.dart';
import '../../../../core/utils/session_manager.dart';
import '../models/nozzle_testing_request.dart';

class TestingService {
  Future<Map<String, dynamic>> fetchNozzleDetails(String nozzleCode) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.nozzlesForTesting}/$nozzleCode');
print(url);
    final token = SessionManager.getToken();

    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseData['data'] ?? responseData;
      } else {
        throw Exception(responseData['message'] ?? 'Failed to fetch nozzle details');
      }
    } catch (e) {
      throw Exception('Error fetching nozzle details: $e');
    }
  }

  Future<Map<String, dynamic>> submitNozzleTesting(NozzleTestingRequest request) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.nozzleTestingInfo}');
    final token = SessionManager.getToken();

    print("API URL: $url");

    try {
      final httpRequest = http.MultipartRequest('POST', url)
        ..headers.addAll({
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        })
        ..fields.addAll(request.toMap());

      /// PRINT REQUEST BODY
      print("Request Fields: ${request.toMap()}");

      /// PRINT IMAGES
      print("Image 1 Path: ${request.image1?.path}");
      print("Image 2 Path: ${request.image2?.path}");
      print("Image 3 Path: ${request.image3?.path}");

      if (request.image1 != null) {
        httpRequest.files.add(await http.MultipartFile.fromPath(
          'image_1',
          request.image1!.path,
        ));
      }

      if (request.image2 != null) {
        httpRequest.files.add(await http.MultipartFile.fromPath(
          'image_2',
          request.image2!.path,
        ));
      }

      if (request.image3 != null) {
        httpRequest.files.add(await http.MultipartFile.fromPath(
          'image_3',
          request.image3!.path,
        ));
      }

      final streamedResponse = await httpRequest.send();
      final response = await http.Response.fromStream(streamedResponse);
      final responseData = jsonDecode(response.body);

      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

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
        throw Exception(responseData['message'] ?? 'Failed to submit testing info');
      }
    } catch (e) {
      throw Exception('Error submitting testing info: $e');
    }
  }
}
