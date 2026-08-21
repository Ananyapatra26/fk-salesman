import 'package:flutter/material.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/utils/session_manager.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;

  AuthProvider(this._repository);

  String _phoneNumber = '';
  String _dialingCode = '91';
  String _otp = '';
  bool _isLoading = false;
  String? _error;

  String get phoneNumber => _phoneNumber;
  String get dialingCode => _dialingCode;
  String get otp => _otp;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setPhoneNumber(String phone, {String dialingCode = '91'}) {
    _phoneNumber = phone;
    _dialingCode = dialingCode;
    notifyListeners();
  }

  void setOtp(String otp) {
    _otp = otp;
    notifyListeners();
  }

  Future<bool> sendOtp() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.sendOtp(_phoneNumber, dialingCode: _dialingCode);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyOtp() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _repository.verifyOtp(_phoneNumber, _otp, dialingCode: _dialingCode);
      await SessionManager.setToken(token);
      await SessionManager.setUserInfo(_phoneNumber, _dialingCode);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.logout();
      await SessionManager.logout();
      _phoneNumber = '';
      _otp = '';
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
