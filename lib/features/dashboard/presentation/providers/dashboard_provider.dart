import 'package:flutter/material.dart';
import 'package:fk_salesman/features/dashboard/domain/models/nozzle_model.dart';
import 'package:fk_salesman/features/dashboard/domain/models/nozzle_response_model.dart';
import 'package:fk_salesman/features/dashboard/data/services/nozzle_service.dart';
import 'package:fk_salesman/features/dashboard/data/services/profile_service.dart';
import 'package:fk_salesman/features/dashboard/domain/models/profile_model.dart';

import '../../data/services/attendance_service.dart';
import '../../domain/models/attendance_record_model.dart';
import '../../domain/models/sales_history_model.dart';

class DashboardProvider extends ChangeNotifier {
  final NozzleService _nozzleService = NozzleService();
  final ProfileService _profileService = ProfileService();
  final AttendanceService _attendanceService = AttendanceService();

  List<Nozzle> _nozzles = [];
  List<NozzleDetail> _nozzleDetails = [];
  List<Nozzle> _mySelectedNozzles = [];
  List<NozzleDetail> _mySelectedNozzleDetails = [];
  List<AttendanceRecord> _attendanceRecords = [];
  List<SaleRecord> _salesHistory = [];
  List<Nozzle> _testingNozzles = [];
  UserProfile? _profile;
  int _totalTestingAllowed = 0;
  bool _showCloseShift = false;
  bool _showCompleteSales = false;
  bool _dipEntryAllowed = false;
  bool _densityEntryAllowed = false;

  List<Nozzle> get nozzles => _nozzles;
  List<NozzleDetail> get nozzleDetails => _nozzleDetails;
  List<Nozzle> get mySelectedNozzles => _mySelectedNozzles;
  List<NozzleDetail> get mySelectedNozzleDetails => _mySelectedNozzleDetails;
  List<AttendanceRecord> get attendanceRecords => _attendanceRecords;
  List<SaleRecord> get salesHistory => _salesHistory;
  List<Nozzle> get testingNozzles => _testingNozzles;
  UserProfile? get profile => _profile;
  int get totalTestingAllowed => _totalTestingAllowed;
  bool get showCloseShift => _showCloseShift;
  bool get showCompleteSales => _showCompleteSales;
  bool get dipEntryAllowed => _dipEntryAllowed;
  bool get densityEntryAllowed => _densityEntryAllowed;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isUpdating = false;
  bool get isUpdating => _isUpdating;

  String? _error;
  String? get error => _error;

  bool _isSalesStarted = false;
  bool get isSalesStarted => _isSalesStarted;

  final Set<String> _selectedNozzleCodes = {};
  Set<String> get selectedNozzleCodes => _selectedNozzleCodes;

  bool get hasTodayAttendance {
    return todayAttendance != null;
  }

  AttendanceRecord? get todayAttendance {
    if (_attendanceRecords.isEmpty) return null;
    final today = DateTime.now().toString().substring(0, 10);
    try {
      return _attendanceRecords.firstWhere((record) =>
          record.attendanceDate == today &&
          (record.checkIn != null || record.checkOut != null));
    } catch (_) {
      return null;
    }
  }
  
  // Track data per nozzle code
  final Map<String, String> _dispenserReadings = {};
  final Map<String, String> _amounts = {};
  final Map<String, String> _quantities = {};

  String? getDispenserReading(String nozzleCode) => _dispenserReadings[nozzleCode];
  String? getAmount(String nozzleCode) => _amounts[nozzleCode];
  String? getQuantity(String nozzleCode) => _quantities[nozzleCode];

  // For backward compatibility or single-nozzle fallback
  String? get dispenserReading => _selectedNozzleCodes.isEmpty ? null : _dispenserReadings[_selectedNozzleCodes.first];
  String? get amount => _selectedNozzleCodes.isEmpty ? null : _amounts[_selectedNozzleCodes.first];
  String? get quantity => _selectedNozzleCodes.isEmpty ? null : _quantities[_selectedNozzleCodes.first];

  Future<void> fetchNozzles() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Always fetch latest profile info (dashboard API)
      await fetchProfile();

      // Ensure we have the latest selected nozzles first so the UI knows what's "Added"
      await fetchSelectedNozzles();
      await fetchNozzlesForTesting();

      final response = await _nozzleService.getNozzles();
      _nozzleDetails = response.data;
      
      // Map NozzleDetail to existing Nozzle UI model
      _nozzles = _nozzleDetails.map((detail) => Nozzle(
        id: detail.code,
        number: detail.nozzleCode,
        fuelType: detail.fuelTypeName,
        fuelTypeCode: detail.fuelTypeCode,
        unitPrice: detail.fuelTypeUnitPrice,
        fuelDispenserCode: detail.fuelDispenserCode,
        fuelDispenserDesc: detail.fuelDispenserDesc,
        lastReadingNo: detail.lastReadingNo,
        expectedClosingReadingNo: detail.expectedClosingReadingNo,
        status: detail.status,
        salesman: detail.salesman,
      )).toList();
      
      _isLoading = false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
    }
    notifyListeners();
  }

  Future<void> fetchNozzlesForTesting() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _nozzleService.getNozzlesForTesting();
      _testingNozzles = response.data.map((detail) => Nozzle(
        id: detail.code,
        number: detail.nozzleCode,
        fuelType: detail.fuelTypeName,
        fuelTypeCode: detail.fuelTypeCode,
        unitPrice: detail.fuelTypeUnitPrice,
        fuelDispenserCode: detail.fuelDispenserCode,
        fuelDispenserDesc: detail.fuelDispenserDesc,
        lastReadingNo: detail.lastReadingNo,
        expectedClosingReadingNo: detail.expectedClosingReadingNo,
        status: detail.status,
        salesman: detail.salesman,
      )).toList();
      
      _isLoading = false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
    }
    notifyListeners();
  }

  Future<void> fetchLogTestNozzles() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _nozzleService.getNozzlesForLogTest();
      _testingNozzles = response.data.map((detail) => Nozzle(
        id: detail.code,
        number: detail.nozzleCode,
        fuelType: detail.fuelTypeName,
        fuelTypeCode: detail.fuelTypeCode,
        unitPrice: detail.fuelTypeUnitPrice,
        fuelDispenserCode: detail.fuelDispenserCode,
        fuelDispenserDesc: detail.fuelDispenserDesc,
        lastReadingNo: detail.lastReadingNo,
        expectedClosingReadingNo: detail.expectedClosingReadingNo,
        status: detail.status,
        salesman: detail.salesman,
      )).toList();
      
      _isLoading = false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
    }
    notifyListeners();
  }

  Future<void> refreshDashboard() async {
    _isUpdating = true;
    _error = null;
    notifyListeners();
    try {
      await fetchProfile();
      await fetchSelectedNozzles();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  Future<void> fetchSelectedNozzles() async {

    if (_mySelectedNozzles.isEmpty) {
      _isLoading = true;
    } else {
      _isUpdating = true;
    }
    _error = null;
    notifyListeners();

    try {
      if (_profile == null) {
        await fetchProfile();
      }

      final response = await _nozzleService.getSelectedNozzles();
      _mySelectedNozzleDetails = response.data;
      
      _mySelectedNozzles = _mySelectedNozzleDetails.map((detail) => Nozzle(
        id: detail.code,
        number: detail.nozzleCode,
        fuelType: detail.fuelTypeName,
        fuelTypeCode: detail.fuelTypeCode,
        unitPrice: detail.fuelTypeUnitPrice,
        fuelDispenserCode: detail.fuelDispenserCode,
        fuelDispenserDesc: detail.fuelDispenserDesc,
        lastReadingNo: detail.lastReadingNo,
        expectedClosingReadingNo: detail.expectedClosingReadingNo,
        status: detail.status,
        salesman: detail.salesman,
      )).toList();
      
      // Cleanup selection if any nozzle is no longer in the list
      final Set<String> validCodes = _mySelectedNozzles.map((n) => n.id).toSet();
      _selectedNozzleCodes.retainAll(validCodes);

    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      _isUpdating = false;
      notifyListeners();
    }
  }

  Future<bool> selectNozzle(String nozzleCode) async {
    // Let the API handle the limit validation

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _nozzleService.selectNozzle(nozzleCode);
      if (success) {
        // Refresh selected nozzles to get the true state from server
        await fetchSelectedNozzles();
        
        // Automatically select for sales if limit not reached
        if (_selectedNozzleCodes.length < 1) {
          _selectedNozzleCodes.add(nozzleCode);
        }
      }
      return success;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      _isUpdating = false;
      notifyListeners();
    }
  }

  Future<bool> deselectNozzle(String nozzleCode, {String? closingReading}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _nozzleService.deselectNozzle(nozzleCode, closingReading: closingReading);
      if (success) {
        // Remove from selection as well
        _selectedNozzleCodes.remove(nozzleCode);
        _dispenserReadings.remove(nozzleCode);
        _amounts.remove(nozzleCode);
        _quantities.remove(nozzleCode);
        
        // Refresh selected nozzles
        await fetchSelectedNozzles();
      }
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      _isUpdating = false;
      notifyListeners();
    }
  }



  Future<bool> markAttendance(String type) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _attendanceService.markAttendance(type);
      if (success) {
        await fetchAttendanceRecords(); // Refresh the history if marked
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> checkoutWithReadings(Map<String, dynamic> readings) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _attendanceService.closeShift(readings);
      if (success) {
        await fetchAttendanceRecords();
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchAttendanceRecords() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _attendanceRecords = await _attendanceService.getAttendanceRecords();
      // Sort in descending order to show latest first
      _attendanceRecords.sort((a, b) => b.attendanceDate.compareTo(a.attendanceDate));
      _isLoading = false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
    }
    notifyListeners();
  }

  Future<void> fetchSalesHistory() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _salesHistory = await _attendanceService.getSalesHistory();
      _isLoading = false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
    }
    notifyListeners();
  }

  void startSales() {
    _isSalesStarted = true;
    notifyListeners();
  }

  Future<void> fetchProfile() async {
    try {
      final response = await _profileService.getProfile();
      if (response.success && response.data != null) {
        _profile = response.data?.salesman;
        _totalTestingAllowed = response.data?.totalTestingAllowed ?? 0;
        _showCloseShift = response.data?.closeMyShift ?? false;
        _showCompleteSales = response.data?.completeMySalesEntry ?? false;
        _dipEntryAllowed = response.data?.dipEntryAllowed ?? false;
        _densityEntryAllowed = response.data?.densityEntryAllowed ?? false;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error fetching profile: $e");
    }
  }

  List<Nozzle> getSelectedNozzles() {
    return _mySelectedNozzles.where((n) => _selectedNozzleCodes.contains(n.id)).toList();
  }

  bool toggleNozzleSelection(String nozzleId) {
    if (_selectedNozzleCodes.contains(nozzleId)) {
      _selectedNozzleCodes.remove(nozzleId);
      
      _dispenserReadings.remove(nozzleId);
      _amounts.remove(nozzleId);
      _quantities.remove(nozzleId);
      notifyListeners();
      return true;
    } else {
      if (_selectedNozzleCodes.length >= 1) {
        return false; // Max 1 nozzle allowed
      }
      
      _selectedNozzleCodes.add(nozzleId);
      notifyListeners();
      return true;
    }
  }

  void setDispenserReading(String nozzleCode, String reading) {
    _dispenserReadings[nozzleCode] = reading;
    notifyListeners();
  }

  void setSalesInfo(String nozzleCode, String amount, String quantity) {
    _amounts[nozzleCode] = amount;
    _quantities[nozzleCode] = quantity;
    notifyListeners();
  }

  bool isNozzleReadingComplete(String nozzleCode) => _dispenserReadings.containsKey(nozzleCode);
  bool isNozzleSalesComplete(String nozzleCode) => _amounts.containsKey(nozzleCode) && _quantities.containsKey(nozzleCode);

  void resetSales() {
    _isSalesStarted = false;
    _selectedNozzleCodes.clear();
    _dispenserReadings.clear();
    _amounts.clear();
    _quantities.clear();
    notifyListeners();
  }


  Future<void> logout() async {
    _profile = null;
    _nozzles = [];
    _nozzleDetails = [];
    _mySelectedNozzles = [];
    _mySelectedNozzleDetails = [];
    _attendanceRecords = [];
    _salesHistory = [];
    _dipEntryAllowed = false;
    _densityEntryAllowed = false;
    _error = null;
    resetSales();
    notifyListeners();
  }
}

