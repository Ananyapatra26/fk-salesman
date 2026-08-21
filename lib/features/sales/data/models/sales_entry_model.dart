class SalesEntryModel {
  final String selectedNozzle;
  final String fuelType;
  final double unitPrice;
  final double quantity;
  final double amountPayable;
  final double amountPaid;
  final String? customerName;
  final String? customerMobile;
  final String? customerDialCode;
  final String? paymentMethod;
  final String? otherAmountType;
  final double? otherAmount;

  SalesEntryModel({
    required this.selectedNozzle,
    required this.fuelType,
    required this.unitPrice,
    required this.quantity,
    required this.amountPayable,
    required this.amountPaid,
    this.customerName,
    this.customerMobile,
    this.customerDialCode,
    this.paymentMethod,
    this.otherAmountType,
    this.otherAmount,
  });

  Map<String, dynamic> toJson() {
    return {
      'selected_nozzle': selectedNozzle,
      'fuel_type': fuelType,
      'unit_price': unitPrice.toStringAsFixed(2),
      'quantity': quantity.toStringAsFixed(2),
      'amount_payable': amountPayable.toStringAsFixed(2),
      'amount_paid': amountPaid.toStringAsFixed(2),
      'customer_name': customerName,
      'customer_mobile': customerMobile,
      'customer_dial_code': customerDialCode,
      'payment_method': paymentMethod,
      'other_amount_type': otherAmountType,
      'other_amount': otherAmount?.toStringAsFixed(2),
    };
  }
}
