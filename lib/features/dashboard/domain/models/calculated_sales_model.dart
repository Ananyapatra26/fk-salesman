class CalculatedSalesResponse {
  final bool success;
  final CalculatedSalesData? data;
  final String? message;

  CalculatedSalesResponse({
    required this.success,
    this.data,
    this.message,
  });

  factory CalculatedSalesResponse.fromJson(Map<String, dynamic> json) {
    return CalculatedSalesResponse(
      success: json['success'] ?? false,
      data: json['data'] != null ? CalculatedSalesData.fromJson(json['data']) : null,
      message: json['message'],
    );
  }
}

class CalculatedSalesData {
  final List<NozzleCalculation> nozzles;
  final NozzleTotal total;

  CalculatedSalesData({
    required this.nozzles,
    required this.total,
  });

  factory CalculatedSalesData.fromJson(Map<String, dynamic> json) {
    return CalculatedSalesData(
      nozzles: (json['nozzles'] as List?)
              ?.map((i) => NozzleCalculation.fromJson(i))
              .toList() ??
          [],
      total: NozzleTotal.fromJson(json['total'] ?? {}),
    );
  }
}

class NozzleCalculation {
  final String nozzleCode;
  final String nozzleName;
  final List<PaymentMethodSale> paymentMethodSales;
  final double totalSalesAmount;

  NozzleCalculation({
    required this.nozzleCode,
    required this.nozzleName,
    required this.paymentMethodSales,
    required this.totalSalesAmount,
  });

  factory NozzleCalculation.fromJson(Map<String, dynamic> json) {
    return NozzleCalculation(
      nozzleCode: json['nozzle_code']?.toString() ?? '',
      nozzleName: json['nozzle_name'] ?? '',
      paymentMethodSales: (json['total_payment_method_wise_sales'] as List?)
              ?.map((i) => PaymentMethodSale.fromJson(i))
              .toList() ??
          [],
      totalSalesAmount: (json['total_sales_amount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class NozzleTotal {
  final List<PaymentMethodSale> paymentMethodSales;
  final double totalSalesAmount;

  NozzleTotal({
    required this.paymentMethodSales,
    required this.totalSalesAmount,
  });

  factory NozzleTotal.fromJson(Map<String, dynamic> json) {
    return NozzleTotal(
      paymentMethodSales: (json['total_payment_method_wise_sales'] as List?)
              ?.map((i) => PaymentMethodSale.fromJson(i))
              .toList() ??
          [],
      totalSalesAmount: (json['total_sales_amount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class PaymentMethodSale {
  final String methodCode;
  final String methodName;
  final double salesAmount;

  PaymentMethodSale({
    required this.methodCode,
    required this.methodName,
    required this.salesAmount,
  });

  factory PaymentMethodSale.fromJson(Map<String, dynamic> json) {
    return PaymentMethodSale(
      methodCode: json['payment_method_code']?.toString() ?? '',
      methodName: json['payment_method_name'] ?? '',
      salesAmount: (json['sales_amount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
