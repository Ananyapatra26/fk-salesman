import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/credit_models.dart';
import '../../data/models/customer_credit_model.dart';
import '../../data/services/credit_service.dart';

class CreditProvider with ChangeNotifier {
  final CreditService _creditService = CreditService();

  final List<CreditCard> _cards = [
    CreditCard(
      id: 'cc_1',
      name: 'Rajesh Kumar',
      mobile: '+919876543210',
      photoUrl: 'https://i.pravatar.cc/150?img=33',
    ),
    CreditCard(
      id: 'cc_2',
      name: 'Priya Sharma',
      mobile: '+919876543635',
      photoUrl: 'https://i.pravatar.cc/150?img=47',
    ),
    CreditCard(
      id: 'cc_3',
      name: 'Anil Singh',
      mobile: '+919123456789',
      photoUrl: 'https://i.pravatar.cc/150?img=12',
    ),
  ];

  final List<CreditEntry> _entries = [];
  List<CustomerCredit> _apiCredits = [];
  CustomerCredit? _currentCreditDetail;
  bool _isLoading = false;
  String? _error;

  List<CreditCard> get cards => _cards;
  List<CreditEntry> get entries => _entries;
  List<CustomerCredit> get apiCredits => _apiCredits;
  CustomerCredit? get currentCreditDetail => _currentCreditDetail;
  bool get isLoading => _isLoading;
  String? get error => _error;

  CreditProvider() {
    _loadFromPrefs();
    fetchApiCredits();
  }

  Future<void> fetchApiCredits({int page = 1}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _creditService.getCustomerCredits(page: page);
      if (page == 1) {
        _apiCredits = response.data.data;
      } else {
        _apiCredits.addAll(response.data.data);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCreditDetail(String code) async {
    _isLoading = true;
    _error = null;
    _currentCreditDetail = null;
    notifyListeners();

    try {
      final response = await _creditService.getCustomerCreditDetail(code);
      _currentCreditDetail = response.data;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitCredit({
    required String creditCode,
    required String nozzle,
    required double amount,
    required double quantity,
    required double fuelTypeUnitPrice,
    File? image1,
    File? image2,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _creditService.submitCreditEntry(
        creditCode: creditCode,
        nozzle: nozzle,
        amount: amount,
        quantity: quantity,
        fuelTypeUnitPrice: fuelTypeUnitPrice,
        image1: image1,
        image2: image2,
      );
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load custom cards added by user
      final cardsJson = prefs.getString('custom_credit_cards');
      if (cardsJson != null) {
        final List<dynamic> decoded = jsonDecode(cardsJson);
        for (var c in decoded) {
          final card = CreditCard.fromJson(c);
          if (!_cards.any((element) => element.id == card.id)) {
            _cards.add(card);
          }
        }
      }

      // Load entries
      final entriesJson = prefs.getString('credit_entries');
      if (entriesJson != null) {
        final List<dynamic> decoded = jsonDecode(entriesJson);
        _entries.clear();
        _entries.addAll(decoded.map((e) => CreditEntry.fromJson(e)));
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading from SharedPreferences: $e");
    }
  }

  Future<void> addCard(String name, String mobile, {String? photoUrl}) async {
    final newCard = CreditCard(
      id: 'cc_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      mobile: mobile,
      photoUrl: photoUrl ?? 'https://i.pravatar.cc/150?img=${_cards.length + 10}',
    );
    _cards.add(newCard);
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final customCards = _cards.where((c) => !['cc_1', 'cc_2', 'cc_3'].contains(c.id)).toList();
      await prefs.setString('custom_credit_cards', jsonEncode(customCards.map((c) => c.toJson()).toList()));
    } catch (e) {
      debugPrint("Error saving card: $e");
    }
  }

  Future<void> addEntry(CreditEntry entry) async {
    _entries.add(entry);
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('credit_entries', jsonEncode(_entries.map((e) => e.toJson()).toList()));
    } catch (e) {
      debugPrint("Error saving entries: $e");
    }
  }
}
