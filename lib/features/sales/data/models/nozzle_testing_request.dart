import 'dart:io';

class NozzleTestingRequest {
  final String testingCode;
  final double quantity;
  final String salesType; // Will be "Testing"
  final File? image1;
  final File? image2;
  final File? image3;
  final String? remark;

  NozzleTestingRequest({
    required this.testingCode,
    required this.quantity,
    required this.salesType,
    this.image1,
    this.image2,
    this.image3,
    this.remark,
  });

  Map<String, String> toMap() {
    return {
      'testing_code': testingCode,
      'quantity': quantity.toString(),
      'sales_type': salesType,
      if (remark != null) 'remark': remark!,
    };
  }
}
