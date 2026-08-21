class FuelTank {
  final String code;
  final String name;
  final String? title;
  final String? desc;
  final String? fuelType;
  final String? fuelTypeCode;

  FuelTank({
    required this.code,
    required this.name,
    this.title,
    this.desc,
    this.fuelType,
    this.fuelTypeCode,
  });

  String get displayName {
    if (title != null && fuelTypeCode != null) {
      return '$title / $fuelTypeCode';
    }
    if (title != null) {
      return title!;
    }
    return name;
  }

  factory FuelTank.fromJson(Map<String, dynamic> json) {
    return FuelTank(
      code: json['code']?.toString() ?? '',
      name: json['name'] ?? json['title'] ?? json['desc'] ?? json['code']?.toString() ?? '',
      title: json['title'],
      desc: json['desc'] ?? json['description'],
      fuelType: json['fuel_type'] ?? json['fuel_type_name'],
      fuelTypeCode: json['fuel_type_code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      if (title != null) 'title': title,
      if (desc != null) 'desc': desc,
      if (fuelType != null) 'fuel_type': fuelType,
      if (fuelTypeCode != null) 'fuel_type_code': fuelTypeCode,
    };
  }
}

class FuelTankResponse {
  final bool success;
  final List<FuelTank> data;

  FuelTankResponse({
    required this.success,
    required this.data,
  });

  factory FuelTankResponse.fromJson(Map<String, dynamic> json) {
    var rawData = json['data'];
    List<dynamic> list = [];
    if (rawData is List) {
      list = rawData;
    } else if (rawData is Map) {
      if (rawData['data'] is List) {
        list = rawData['data'];
      } else if (rawData['tanks'] is List) {
        list = rawData['tanks'];
      }
    }
    return FuelTankResponse(
      success: json['success'] ?? false,
      data: list.map((item) => FuelTank.fromJson(item)).toList(),
    );
  }
}

class FuelProduct {
  final String fuelTypeCode;
  final String fuelTypeName;

  FuelProduct({
    required this.fuelTypeCode,
    required this.fuelTypeName,
  });

  factory FuelProduct.fromJson(Map<String, dynamic> json) {
    return FuelProduct(
      fuelTypeCode: json['fuel_type_code']?.toString() ?? '',
      fuelTypeName: json['fuel_type_name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fuel_type_code': fuelTypeCode,
      'fuel_type_name': fuelTypeName,
    };
  }
}

class FuelProductResponse {
  final bool success;
  final List<FuelProduct> data;

  FuelProductResponse({
    required this.success,
    required this.data,
  });

  factory FuelProductResponse.fromJson(Map<String, dynamic> json) {
    var rawData = json['data'];
    List<dynamic> list = [];
    if (rawData is List) {
      list = rawData;
    } else if (rawData is Map && rawData['products'] is List) {
      list = rawData['products'];
    }
    return FuelProductResponse(
      success: json['success'] ?? false,
      data: list.map((item) => FuelProduct.fromJson(item)).toList(),
    );
  }
}
