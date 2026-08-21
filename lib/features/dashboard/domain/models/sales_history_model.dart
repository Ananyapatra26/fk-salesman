class SalesHistoryResponse {
  final bool success;
  final SalesData data;

  SalesHistoryResponse({required this.success, required this.data});

  factory SalesHistoryResponse.fromJson(Map<String, dynamic> json) {
    return SalesHistoryResponse(
      success: json['success'] ?? false,
      data: SalesData.fromJson(json['data'] ?? {}),
    );
  }
}

class SalesData {
  final SalesList sales;

  SalesData({required this.sales});

  factory SalesData.fromJson(Map<String, dynamic> json) {
    return SalesData(
      sales: SalesList.fromJson(json['sales'] ?? {}),
    );
  }
}

class SalesList {
  final int currentPage;
  final List<SaleRecord> data;
  final int lastPage;
  final int total;

  SalesList({
    required this.currentPage,
    required this.data,
    required this.lastPage,
    required this.total,
  });

  factory SalesList.fromJson(Map<String, dynamic> json) {
    return SalesList(
      currentPage: json['current_page'] ?? 1,
      data: (json['data'] as List? ?? [])
          .map((item) => SaleRecord.fromJson(item))
          .toList(),
      lastPage: json['last_page'] ?? 1,
      total: json['total'] ?? 0,
    );
  }
}

class SaleRecord {
  final int id;
  final int fuelStationId;
  final int salesmanNozzleId;
  final int fuelTypeId;
  final double unitPrice;
  final double qty;
  final double amountPayable;
  final double amountPaid;
  final String? workShiftName;
  final String? fuelTypeCode;
  final String? nozzleCode;
  final int? paymentMethodId;
  final String? paymentMethodName;
  final String timestamp;
  final String? customerName;
  final String? customerMobile;
  final String salesType; // "fuel" or "test"
  final String? testingInfo;
  final String? remark;
  final String status;
  final String createdAt;

  SaleRecord({
    required this.id,
    required this.fuelStationId,
    required this.salesmanNozzleId,
    required this.fuelTypeId,
    required this.unitPrice,
    required this.qty,
    required this.amountPayable,
    required this.amountPaid,
    this.workShiftName,
    this.fuelTypeCode,
    this.nozzleCode,
    this.paymentMethodId,
    this.paymentMethodName,
    required this.timestamp,
    this.customerName,
    this.customerMobile,
    required this.salesType,
    this.testingInfo,
    this.remark,
    required this.status,
    required this.createdAt,
  });

  factory SaleRecord.fromJson(Map<String, dynamic> json) {
    return SaleRecord(
      id: json['id'] ?? 0,
      fuelStationId: json['fuel_station_id'] ?? 0,
      salesmanNozzleId: json['salesman_nozzle_id'] ?? 0,
      fuelTypeId: json['fuel_type_id'] ?? 0,
      unitPrice: (json['unit_price'] ?? 0).toDouble(),
      qty: (json['qty'] ?? 0).toDouble(),
      amountPayable: (json['amount_payable'] ?? 0).toDouble(),
      amountPaid: (json['amount_paid'] ?? 0).toDouble(),
      workShiftName: json['work_shift_name']?.toString(),
      fuelTypeCode: json['fuel_type_code']?.toString(),
      nozzleCode: json['nozzle_code']?.toString(),
      paymentMethodId: json['payment_method_id'],
      paymentMethodName: json['payment_method_name']?.toString(),
      timestamp: json['timestamp'] ?? "",
      customerName: json['customer_name'],
      customerMobile: json['customer_mobile'],
      salesType: json['sales_type'] ?? "fuel",
      testingInfo: json['testing_info'],
      remark: json['remark'],
      status: json['status'] ?? "active",
      createdAt: json['created_at'] ?? "",
    );
  }

  String get formattedDate {
    try {
      final dt = DateTime.parse(timestamp);
      return "${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.year}";
    } catch (e) {
      return timestamp;
    }
  }

  String get formattedTime {
    try {
      final dt = DateTime.parse(timestamp);
      int hour = dt.hour;
      String period = "AM";
      if (hour >= 12) {
        period = "PM";
        if (hour > 12) hour -= 12;
      }
      if (hour == 0) hour = 12;
      return "${hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} $period";
    } catch (e) {
      return "";
    }
  }

  String get formattedCreatedAt {
    try {
      final dt = DateTime.parse(createdAt);
      int hour = dt.hour;
      String period = "AM";
      if (hour >= 12) {
        period = "PM";
        if (hour > 12) hour -= 12;
      }
      if (hour == 0) hour = 12;
      return "${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.year} ${hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} $period";
    } catch (e) {
      return createdAt;
    }
  }
}
