import 'nozzle_response_model.dart';

class Nozzle {
  final String id;
  final String number;
  final String fuelType;
  final String fuelTypeCode;
  final double unitPrice;
  final String? fuelDispenserCode;
  final String? fuelDispenserDesc;
  final double? lastReadingNo;
  final double? expectedClosingReadingNo;
  final String status;
  final bool isSelected;
  final Salesman? salesman;

  Nozzle({
    required this.id,
    required this.number,
    required this.fuelType,
    required this.fuelTypeCode,
    required this.unitPrice,
    this.fuelDispenserCode,
    this.fuelDispenserDesc,
    this.lastReadingNo,
    this.expectedClosingReadingNo,
    this.status = 'active',
    this.isSelected = false,
    this.salesman,
  });

  Nozzle copyWith({
    String? id,
    String? number,
    String? fuelType,
    String? fuelTypeCode,
    double? unitPrice,
    String? status,
    bool? isSelected,
    Salesman? salesman,
  }) {
    return Nozzle(
      id: id ?? this.id,
      number: number ?? this.number,
      fuelType: fuelType ?? this.fuelType,
      fuelTypeCode: fuelTypeCode ?? this.fuelTypeCode,
      unitPrice: unitPrice ?? this.unitPrice,
      status: status ?? this.status,
      isSelected: isSelected ?? this.isSelected,
      salesman: salesman ?? this.salesman,
    );
  }
}
