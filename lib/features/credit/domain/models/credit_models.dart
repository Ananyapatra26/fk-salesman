import 'dart:io';

class CreditCard {
  final String id;
  final String name;
  final String mobile;
  final String? photoUrl;

  CreditCard({
    required this.id,
    required this.name,
    required this.mobile,
    this.photoUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mobile': mobile,
      'photoUrl': photoUrl,
    };
  }

  factory CreditCard.fromJson(Map<String, dynamic> json) {
    return CreditCard(
      id: json['id'] as String,
      name: json['name'] as String,
      mobile: json['mobile'] as String,
      photoUrl: json['photoUrl'] as String?,
    );
  }
}

class CreditEntry {
  final String id;
  final String cardId;
  final String nozzleCode;
  final double amount;
  final String remark;
  final List<String> imagePaths;
  final DateTime date;

  CreditEntry({
    required this.id,
    required this.cardId,
    required this.nozzleCode,
    required this.amount,
    required this.remark,
    required this.imagePaths,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cardId': cardId,
      'nozzleCode': nozzleCode,
      'amount': amount,
      'remark': remark,
      'imagePaths': imagePaths,
      'date': date.toIso8601String(),
    };
  }

  factory CreditEntry.fromJson(Map<String, dynamic> json) {
    return CreditEntry(
      id: json['id'] as String,
      cardId: json['cardId'] as String,
      nozzleCode: json['nozzleCode'] as String,
      amount: (json['amount'] as num).toDouble(),
      remark: json['remark'] as String? ?? '',
      imagePaths: List<String>.from(json['imagePaths'] as List? ?? []),
      date: DateTime.parse(json['date'] as String),
    );
  }
}
