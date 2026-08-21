import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String _tokenKey = 'auth_token';
  static const String _mobileKey = 'user_mobile';
  static const String _dialingCodeKey = 'user_dialing_code';
  static const String _clientKey = 'selected_client';
  static SharedPreferences? _prefs;
  static String? _token;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _token = _prefs?.getString(_tokenKey);
  }

  static Future<void> setToken(String token) async {
    _token = token;
    await _prefs?.setString(_tokenKey, token);
  }

  static String? getToken() {
    return _token;
  }

  static Future<void> setUserInfo(String mobile, String dialingCode) async {
    await _prefs?.setString(_mobileKey, mobile);
    await _prefs?.setString(_dialingCodeKey, dialingCode);
  }

  static String? getMobile() {
    return _prefs?.getString(_mobileKey);
  }

  static String? getDialingCode() {
    return _prefs?.getString(_dialingCodeKey);
  }

  static Future<void> setClient(String client) async {
    await _prefs?.setString(_clientKey, client);
  }

  static String getClient() {
    return _prefs?.getString(_clientKey) ?? 'laxmipratima';
  }

  static String getBaseUrl() {
    final client = getClient();
    final host = client == 'shaktiksk'
        ? 'https://shaktiksk.fuelkhata.com'
        : 'https://fuelkhata-app-dev.webuserve.in';
    return '$host/api/v1/fsm/app/salesman';
  }

  static bool isLoggedIn() {
    return _token != null && _token!.isNotEmpty;
  }

  static Future<void> logout() async {
    _token = null;
    if (_prefs != null) {
      final client = getClient();
      await _prefs!.clear();
      await setClient(client);
    }
  }
}
