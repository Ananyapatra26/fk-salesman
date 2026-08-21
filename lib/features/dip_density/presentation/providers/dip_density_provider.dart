import 'dart:io';
import 'package:flutter/material.dart';
import '../../data/models/fuel_tank_model.dart';
import '../../data/services/dip_density_service.dart';

class DipDensityProvider with ChangeNotifier {
  final DipDensityService _service = DipDensityService();

  List<FuelTank> _tanks = [];
  List<FuelProduct> _products = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  bool _isCalculating = false;
  String? _error;

  List<FuelTank> get tanks => _tanks;
  List<FuelProduct> get products => _products;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  bool get isCalculating => _isCalculating;
  String? get error => _error;

  Future<void> fetchTanks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _service.getFuelTanks();
      _tanks = response.data;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _service.getFuelProducts();
      _products = response.data;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitDip({
    required String tankCode,
    required double dipValue,
    required double waterDipValue,
    required File dipLevelPhoto,
    required File waterLevelPhoto,
  }) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _service.submitDipEntry(
        tankCode: tankCode,
        dipValue: dipValue,
        waterDipValue: waterDipValue,
        dipLevelPhoto: dipLevelPhoto,
        waterLevelPhoto: waterLevelPhoto,
      );
      return success;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> submitDensity({
    required String tankCode,
    required double densityValue,
    required double temperature,
    File? photo,
  }) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _service.submitDensityEntry(
        tankCode: tankCode,
        densityValue: densityValue,
        temperature: temperature,
        photo: photo,
      );
      return success;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> calculateFuelStock({
    required String tankCode,
    required double dipValue,
    required double waterDipValue,
  }) async {
    _isCalculating = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _service.calculateFuelStock(
        tankCode: tankCode,
        dipValue: dipValue,
        waterDipValue: waterDipValue,
      );
      return result;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return null;
    } finally {
      _isCalculating = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> calculateDensity({
    required double hydrometerReading,
    required double temperature,
  }) async {
    _isCalculating = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _service.calculateDensity(
        hydrometerReading: hydrometerReading,
        temperature: temperature,
      );
      return result;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return null;
    } finally {
      _isCalculating = false;
      notifyListeners();
    }
  }
}
