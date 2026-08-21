class PaymentMethod {
  final String code;
  final String name;
  final String? description;
  final String? logo;
  final String? bankAccountCode;
  final String? bankAccountName;
  final String? bankAccountDesc;
  final String? pspCode;
  final String? pspName;
  final String? pspDesc;

  PaymentMethod({
    required this.code,
    required this.name,
    this.description,
    this.logo,
    this.bankAccountCode,
    this.bankAccountName,
    this.bankAccountDesc,
    this.pspCode,
    this.pspName,
    this.pspDesc,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      logo: json['logo'],
      bankAccountCode: json['bank_account_code'],
      bankAccountName: json['bank_account_name'],
      bankAccountDesc: json['bank_account_desc'],
      pspCode: json['psp_code'],
      pspName: json['psp_name'],
      pspDesc: json['psp_desc'],
    );
  }
}
