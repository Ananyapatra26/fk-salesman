class CustomerCreditResponse {
  final bool success;
  final CustomerCreditData data;

  CustomerCreditResponse({
    required this.success,
    required this.data,
  });

  factory CustomerCreditResponse.fromJson(Map<String, dynamic> json) {
    return CustomerCreditResponse(
      success: json['success'] ?? false,
      data: CustomerCreditData.fromJson(json['data'] ?? {}),
    );
  }
}

class CustomerCreditData {
  final int currentPage;
  final List<CustomerCredit> data;
  final String? firstPageUrl;
  final int? from;
  final int lastPage;
  final String? lastPageUrl;
  final String? nextPageUrl;
  final String path;
  final int perPage;
  final String? prevPageUrl;
  final int? to;
  final int total;

  CustomerCreditData({
    required this.currentPage,
    required this.data,
    this.firstPageUrl,
    this.from,
    required this.lastPage,
    this.lastPageUrl,
    this.nextPageUrl,
    required this.path,
    required this.perPage,
    this.prevPageUrl,
    this.to,
    required this.total,
  });

  factory CustomerCreditData.fromJson(Map<String, dynamic> json) {
    return CustomerCreditData(
      currentPage: json['current_page'] ?? 1,
      data: (json['data'] as List? ?? [])
          .map((item) => CustomerCredit.fromJson(item))
          .toList(),
      firstPageUrl: json['first_page_url'],
      from: json['from'],
      lastPage: json['last_page'] ?? 1,
      lastPageUrl: json['last_page_url'],
      nextPageUrl: json['next_page_url'],
      path: json['path'] ?? '',
      perPage: json['per_page'] ?? 10,
      prevPageUrl: json['prev_page_url'],
      to: json['to'],
      total: json['total'] ?? 0,
    );
  }
}

class CustomerCreditDetailResponse {
  final bool success;
  final CustomerCredit data;

  CustomerCreditDetailResponse({
    required this.success,
    required this.data,
  });

  factory CustomerCreditDetailResponse.fromJson(Map<String, dynamic> json) {
    return CustomerCreditDetailResponse(
      success: json['success'] ?? false,
      data: CustomerCredit.fromJson(json['data'] ?? {}),
    );
  }
}

class CustomerCredit {
  final String code;
  final double? amount;
  final double? quantity;
  final String? creditedAt;
  final String? info;
  final String? remark;
  final String status;
  final String createdAt;
  final String updatedAt;
  
  final CreditFuelStation? fuelStation;
  final CreditFuelType? fuelType;
  final CreditNozzle? nozzle;
  final CreditWorkShift? workShift;
  final CreditCustomer? customer;

  // Flat fields from list API
  final String? customerUidField;
  final String? customerNameField;
  final String? customerMobileField;
  final String? customerPhotoField;
  final String? nozzleCodeField;
  final String? fuelTypeCodeField;

  CustomerCredit({
    required this.code,
    this.amount,
    this.quantity,
    this.creditedAt,
    this.info,
    this.remark,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.fuelStation,
    this.fuelType,
    this.nozzle,
    this.workShift,
    this.customer,
    this.customerUidField,
    this.customerNameField,
    this.customerMobileField,
    this.customerPhotoField,
    this.nozzleCodeField,
    this.fuelTypeCodeField,
  });

  // Helper getters for backward compatibility and ease of use
  String get customerName => customer?.name ?? customerNameField ?? '';
  String get customerMobile => customer?.mobile ?? customerMobileField ?? '';
  String get customerUid => customer?.uid ?? customerUidField ?? '';
  String? get customerPhoto => customerPhotoField; 
  String get nozzleCode => nozzle?.code ?? nozzleCodeField ?? '';
  String get fuelTypeCode => fuelType?.code ?? fuelTypeCodeField ?? '';

  factory CustomerCredit.fromJson(Map<String, dynamic> json) {
    return CustomerCredit(
      code: json['code'] ?? '',
      amount: json['amount'] != null ? double.tryParse(json['amount'].toString()) : null,
      quantity: json['quantity'] != null ? double.tryParse(json['quantity'].toString()) : null,
      creditedAt: json['credited_at'],
      info: json['info'],
      remark: json['remark'],
      status: json['status'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      fuelStation: json['fuel_station'] != null ? CreditFuelStation.fromJson(json['fuel_station']) : null,
      fuelType: json['fuel_type'] != null ? CreditFuelType.fromJson(json['fuel_type']) : null,
      nozzle: json['nozzle'] != null ? CreditNozzle.fromJson(json['nozzle']) : null,
      workShift: json['work_shift'] != null ? CreditWorkShift.fromJson(json['work_shift']) : null,
      customer: json['customer'] != null ? CreditCustomer.fromJson(json['customer']) : null,
      customerUidField: json['customer_uid'],
      customerNameField: json['customer_name'],
      customerMobileField: json['customer_mobile'],
      customerPhotoField: json['customer_photo'],
      nozzleCodeField: json['nozzle_code'],
      fuelTypeCodeField: json['fuel_type_code'],
    );
  }
}

class CreditFuelStation {
  final int id;
  final String code;
  final String name;
  final String companyName;

  CreditFuelStation({
    required this.id,
    required this.code,
    required this.name,
    required this.companyName,
  });

  factory CreditFuelStation.fromJson(Map<String, dynamic> json) {
    return CreditFuelStation(
      id: json['id'] ?? 0,
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      companyName: json['company_name'] ?? '',
    );
  }
}

class CreditFuelType {
  final String code;
  final String name;
  final String? unit;

  CreditFuelType({
    required this.code,
    required this.name,
    this.unit,
  });

  factory CreditFuelType.fromJson(Map<String, dynamic> json) {
    return CreditFuelType(
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      unit: json['unit'],
    );
  }
}

class CreditNozzle {
  final String code;
  final String? desc;

  CreditNozzle({
    required this.code,
    this.desc,
  });

  factory CreditNozzle.fromJson(Map<String, dynamic> json) {
    return CreditNozzle(
      code: json['code'] ?? '',
      desc: json['desc'],
    );
  }
}

class CreditWorkShift {
  final String code;
  final String name;

  CreditWorkShift({
    required this.code,
    required this.name,
  });

  factory CreditWorkShift.fromJson(Map<String, dynamic> json) {
    return CreditWorkShift(
      code: json['code'] ?? '',
      name: json['name'] ?? '',
    );
  }
}

class CreditCustomer {
  final String uid;
  final String name;
  final String mobile;
  final String? email;

  CreditCustomer({
    required this.uid,
    required this.name,
    required this.mobile,
    this.email,
  });

  factory CreditCustomer.fromJson(Map<String, dynamic> json) {
    return CreditCustomer(
      uid: json['uid'] ?? '',
      name: json['name'] ?? '',
      mobile: json['mobile'] ?? '',
      email: json['email'],
    );
  }
}
