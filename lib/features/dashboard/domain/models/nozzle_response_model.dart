class NozzleResponse {
  final bool success;
  final List<NozzleDetail> data;

  NozzleResponse({
    required this.success,
    required this.data,
  });

  factory NozzleResponse.fromJson(Map<String, dynamic> json) {
    var rawData = json['data'];
    List<dynamic> nozzleList = [];
    
    if (rawData is List) {
      nozzleList = rawData;
    } else if (rawData is Map && rawData['data'] is List) {
      // Handle paginated response
      nozzleList = rawData['data'];
    }

    return NozzleResponse(
      success: json['success'] ?? false,
      data: nozzleList.map((i) => NozzleDetail.fromJson(i)).toList(),
    );
  }
}

class Salesman {
  final String eid;
  final String name;
  final String mobile;
  final String? email;
  final String? photo;

  Salesman({
    required this.eid,
    required this.name,
    required this.mobile,
    this.email,
    this.photo,
  });

  factory Salesman.fromJson(Map<String, dynamic> json) {
    return Salesman(
      eid: json['eid']?.toString() ?? '',
      name: json['name'] ?? '',
      mobile: json['mobile'] ?? '',
      email: json['email'],
      photo: json['photo'],
    );
  }
}

class NozzleDetail {
  final String code;
  final String nozzleCode;
  final String nozzleDesc;
  final String? nozzleCodeLogo;
  final String fuelTypeCode;
  final String fuelTypeName;
  final String? fuelTypeDesc;
  final double fuelTypeUnitPrice;
  final String fuelTypeUnitPriceUpdatedAt;
  final String fuelDispenserCode;
  final String fuelDispenserDesc;
  final String? fuelDispenserLogo;
  final double lastReadingNo;
  final double expectedClosingReadingNo;
  final String status;
  final Salesman? salesman;

  NozzleDetail({
    required this.code,
    required this.nozzleCode,
    required this.nozzleDesc,
    this.nozzleCodeLogo,
    required this.fuelTypeCode,
    required this.fuelTypeName,
    this.fuelTypeDesc,
    required this.fuelTypeUnitPrice,
    required this.fuelTypeUnitPriceUpdatedAt,
    required this.fuelDispenserCode,
    required this.fuelDispenserDesc,
    this.fuelDispenserLogo,
    required this.lastReadingNo,
    required this.expectedClosingReadingNo,
    required this.status,
    this.salesman,
  });

  factory NozzleDetail.fromJson(Map<String, dynamic> json) {
    return NozzleDetail(
      code: json['code']?.toString() ?? '',
      nozzleCode: json['fuel_nozzle_code'] ?? json['nozzle_code'] ?? json['code']?.toString() ?? '',
      nozzleDesc: json['fuel_nozzle_desc'] ?? json['nozzle_desc'] ?? json['desc'] ?? '',
      nozzleCodeLogo: json['nozzle_code_logo'] ?? json['logo'],
      fuelTypeCode: json['fuel_type_code'] ?? '',
      fuelTypeName: json['fuel_type_name'] ?? '',
      fuelTypeDesc: json['fuel_type_desc'],
      fuelTypeUnitPrice: (json['fuel_type_unit_price'] as num?)?.toDouble() ?? 
                         (json['unit_price'] as num?)?.toDouble() ?? 0.0,
      fuelTypeUnitPriceUpdatedAt: json['fuel_type_unit_price_updated_at'] ?? json['updated_at'] ?? '',
      fuelDispenserCode: json['fuel_dispenser_code']?.toString() ?? '',
      fuelDispenserDesc: json['fuel_dispenser_desc'] ?? '',
      fuelDispenserLogo: json['fuel_dispenser_logo'],
      lastReadingNo: (json['last_reading_no'] as num?)?.toDouble() ?? 0.0,
      expectedClosingReadingNo: (json['expected_closing_reading_no'] as num?)?.toDouble() ?? 0.0,
      status: json['status']?.toString() ?? 'active',
      salesman: json['salesman'] != null ? Salesman.fromJson(json['salesman']) : null,
    );
  }
}
