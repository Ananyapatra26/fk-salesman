import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../../../core/utils/api_constants.dart';
import '../../../../core/utils/session_manager.dart';
import '../models/fuel_tank_model.dart';

class DipDensityService {
  Future<FuelTankResponse> getFuelTanks() async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.fuelTanks}');
    final token = SessionManager.getToken();

    print('--- GET FUEL TANKS REQUEST ---');
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

      print('STATUS: ${response.statusCode}');
      print('RESPONSE: ${response.body}');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return FuelTankResponse.fromJson(responseData);
      } else {
        throw Exception(responseData['message'] ?? 'Failed to fetch fuel tanks');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: $e');
    }
  }

  Future<FuelProductResponse> getFuelProducts() async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.densityInfo}');
    final token = SessionManager.getToken();

    print('--- GET FUEL PRODUCTS REQUEST ---');
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

      print('STATUS: ${response.statusCode}');
      print('RESPONSE: ${response.body}');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return FuelProductResponse.fromJson(responseData);
      } else {
        throw Exception(responseData['message'] ?? 'Failed to fetch products');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: $e');
    }
  }

  Future<bool> submitDipEntry({
    required String tankCode,
    required double dipValue,
    required double waterDipValue,
    required File dipLevelPhoto,
    required File waterLevelPhoto,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.dipEntry}');
    final token = SessionManager.getToken();

    print('--- SUBMIT DIP ENTRY REQUEST ---');
    print('URL: $url');

    try {
      final request = http.MultipartRequest('POST', url)
        ..headers.addAll({
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        })
        ..fields.addAll({
          'tank_code': tankCode,
          'dip_value': dipValue.toString(),
          'water_dip_value': waterDipValue.toString(),
        });

      print("Dip Photo Path: ${dipLevelPhoto.path}");
      print("Water Photo Path: ${waterLevelPhoto.path}");

      request.files.add(await http.MultipartFile.fromPath(
        'dip_level_photo',
        dipLevelPhoto.path,
        contentType: MediaType('image', 'jpeg'),
      ));

      request.files.add(await http.MultipartFile.fromPath(
        'water_level_photo',
        waterLevelPhoto.path,
        contentType: MediaType('image', 'jpeg'),
      ));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print("STATUS: ${response.statusCode}");
      print("RESPONSE: ${response.body}");

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseData['success'] == true) {
          return true;
        } else {
          throw Exception(responseData['message'] ?? 'Failed to submit DIP entry');
        }
      } else {
        if (responseData['errors'] != null) {
          final errors = responseData['errors'] as Map<String, dynamic>;
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            throw Exception(firstError.first);
          }
        }
        throw Exception(responseData['message'] ?? 'Failed to submit DIP entry');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: $e');
    }
  }

  Future<bool> submitDensityEntry({
    required String tankCode,
    required double densityValue,
    required double temperature,
    File? photo,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.densityEntry}');
    final token = SessionManager.getToken();

    print('--- SUBMIT DENSITY ENTRY REQUEST ---');
    print('URL: $url');

    try {
      final request = http.MultipartRequest('POST', url)
        ..headers.addAll({
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        })
        ..fields.addAll({
          'tank_code': tankCode,
          'density_value': densityValue.toString(),
          'temperature': temperature.toString(),
        });

      print("Request Fields: ${request.fields}");
      if (photo != null) {
        print("Photo Path: ${photo.path}");
        request.files.add(await http.MultipartFile.fromPath(
          'photo',
          photo.path,
          contentType: MediaType('image', 'jpeg'),
        ));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print("STATUS: ${response.statusCode}");
      print("RESPONSE: ${response.body}");

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseData['success'] == true) {
          return true;
        } else {
          throw Exception(responseData['message'] ?? 'Failed to submit density entry');
        }
      } else {
        if (responseData['errors'] != null) {
          final errors = responseData['errors'] as Map<String, dynamic>;
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            throw Exception(firstError.first);
          }
        }
        throw Exception(responseData['message'] ?? 'Failed to submit density entry');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> calculateFuelStock({
    required String tankCode,
    required double dipValue,
    required double waterDipValue,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.calculateFuelStock}');
    final token = SessionManager.getToken();

    print('--- CALCULATE FUEL STOCK REQUEST ---');
    print('URL: $url');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'fuel_tank': tankCode,
          'dip_level': dipValue,
          'water_dip_level': waterDipValue,
        }),
      );

      print('STATUS: ${response.statusCode}');
      print('RESPONSE: ${response.body}');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (responseData['success'] == true) {
          return responseData['data'] as Map<String, dynamic>;
        } else {
          throw Exception(responseData['message'] ?? 'Failed to calculate fuel stock');
        }
      } else {
        throw Exception(responseData['message'] ?? 'Failed to calculate fuel stock');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> calculateDensity({
    required double hydrometerReading,
    required double temperature,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.calculateDensity}');
    final token = SessionManager.getToken();

    print('--- CALCULATE DENSITY REQUEST ---');
    print('URL: $url');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'hydrometer_reading': hydrometerReading,
          'temperature': temperature,
        }),
      );

      print('STATUS: ${response.statusCode}');
      print('RESPONSE: ${response.body}');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (responseData['success'] == true) {
          return responseData['data'] as Map<String, dynamic>;
        } else {
          throw Exception(responseData['message'] ?? 'Failed to calculate density');
        }
      } else {
        throw Exception(responseData['message'] ?? 'Failed to calculate density');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: $e');
    }
  }
}
