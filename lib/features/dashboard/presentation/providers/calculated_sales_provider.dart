import 'package:flutter/material.dart';
import '../../data/services/calculated_sales_service.dart';
import '../../domain/models/calculated_sales_model.dart';

class CalculatedSalesProvider extends ChangeNotifier {
  final CalculatedSalesService _service = CalculatedSalesService();
  
  CalculatedSalesData? _data;
  bool _isLoading = false;
  String? _error;

  CalculatedSalesData? get data => _data;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchCalculatedSales() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _service.fetchCalculatedSales();

    if (result.success && result.data != null) {
      _data = result.data;
      _error = null;
    } else {
      _error = result.message ?? 'Unknown error occurred';
    }

    _isLoading = false;
    notifyListeners();
  }
}
