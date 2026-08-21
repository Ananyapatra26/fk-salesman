import 'payment_method_model.dart';

class NozzleDetailResponse {
  final bool success;
  final NozzleDetailData data;

  NozzleDetailResponse({
    required this.success,
    required this.data,
  });

  factory NozzleDetailResponse.fromJson(Map<String, dynamic> json) {
    return NozzleDetailResponse(
      success: json['success'] ?? false,
      data: NozzleDetailData.fromJson(json['data'] ?? {}),
    );
  }
}

class NozzleDetailData {
  final String code;
  final String nozzleCode;
  final String nozzleDesc;
  final String? nozzleCodeLogo;
  final int fuelStationFuelTypeId;
  final int fuelDispenserId;
  final double lastReadingNo;
  final String fuelDispenserCode;
  final String fuelDispenserDesc;
  final String? fuelDispenserLogo;
  final String fuelTypeCode;
  final String fuelTypeName;
  final String? fuelTypeDesc;
  final double fuelTypeUnitPrice;
  final String fuelTypeUnitPriceUpdatedAt;
  final String date;
  final String status;
  final String createdAt;
  final String updatedAt;
  final double expectedClosingReadingNo;
  final List<PaymentMethod> availablePaymentMethods;

  NozzleDetailData({
    required this.code,
    required this.nozzleCode,
    required this.nozzleDesc,
    this.nozzleCodeLogo,
    required this.fuelStationFuelTypeId,
    required this.fuelDispenserId,
    required this.lastReadingNo,
    required this.fuelDispenserCode,
    required this.fuelDispenserDesc,
    this.fuelDispenserLogo,
    required this.fuelTypeCode,
    required this.fuelTypeName,
    this.fuelTypeDesc,
    required this.fuelTypeUnitPrice,
    required this.fuelTypeUnitPriceUpdatedAt,
    required this.date,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.expectedClosingReadingNo,
    required this.availablePaymentMethods,
  });

  factory NozzleDetailData.fromJson(Map<String, dynamic> json) {
    return NozzleDetailData(
      code: json['code']?.toString() ?? '',
      nozzleCode: json['nozzle_code'] ?? '',
      nozzleDesc: json['nozzle_desc'] ?? '',
      nozzleCodeLogo: json['nozzle_code_logo'],
      fuelStationFuelTypeId: json['fuel_station_fuel_type_id'] ?? 0,
      fuelDispenserId: json['fuel_dispenser_id'] ?? 0,
      lastReadingNo: (json['last_reading_no'] as num?)?.toDouble() ?? 0.0,
      fuelDispenserCode: json['fuel_dispenser_code']?.toString() ?? '',
      fuelDispenserDesc: json['fuel_dispenser_desc'] ?? '',
      fuelDispenserLogo: json['fuel_dispenser_logo'],
      fuelTypeCode: json['fuel_type_code'] ?? '',
      fuelTypeName: json['fuel_type_name'] ?? '',
      fuelTypeDesc: json['fuel_type_desc'],
      fuelTypeUnitPrice: (json['fuel_type_unit_price'] as num?)?.toDouble() ?? 0.0,
      fuelTypeUnitPriceUpdatedAt: json['fuel_type_unit_price_updated_at'] ?? '',
      date: json['date'] ?? '',
      status: json['status'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      expectedClosingReadingNo: (json['expected_closing_reading_no'] as num?)?.toDouble() ?? 0.0,
      availablePaymentMethods: (json['available_payment_methods'] as List?)
              ?.map((i) => PaymentMethod.fromJson(i))
              .toList() ??
          [],
    );
  }
}
