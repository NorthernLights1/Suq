import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';

class Product extends Equatable {
  const Product({
    required this.id,
    required this.shopId,
    required this.name,
    this.categoryId,
    required this.measurementUnitId,
    required this.measurementUnitAbbr,
    required this.lowStockThreshold,
    required this.isActive,
  });

  final String id;
  final String shopId;
  final String name;
  final String? categoryId;
  final String measurementUnitId;
  final String measurementUnitAbbr;
  final Decimal lowStockThreshold;
  final bool isActive;

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'] as String,
        shopId: json['shop_id'] as String,
        name: json['name'] as String,
        categoryId: json['category_id'] as String?,
        measurementUnitId: json['measurement_unit_id'] as String,
        measurementUnitAbbr:
            (json['measurement_units'] as Map<String, dynamic>?)?['abbreviation']
                as String? ??
            '',
        lowStockThreshold:
            Decimal.parse(json['low_stock_threshold'].toString()),
        isActive: json['is_active'] as bool,
      );

  @override
  List<Object?> get props => [id, name];
}
