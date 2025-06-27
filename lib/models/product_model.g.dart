// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductSize _$ProductSizeFromJson(Map<String, dynamic> json) => ProductSize(
  size: json['size'] as String,
  price: (json['price'] as num).toDouble(),
);

Map<String, dynamic> _$ProductSizeToJson(ProductSize instance) =>
    <String, dynamic>{'size': instance.size, 'price': instance.price};

Product _$ProductFromJson(Map<String, dynamic> json) => Product(
  id: json['id'] as String,
  title: json['title'] as String,
  subtitle: json['subtitle'] as String,
  imageUrl: json['imageUrl'] as String,
  category: json['category'] as String,
  availableSizes:
      (json['availableSizes'] as List<dynamic>)
          .map((e) => ProductSize.fromJson(e as Map<String, dynamic>))
          .toList(),
  selectedUnit: json['selectedUnit'] as String?,
);

Map<String, dynamic> _$ProductToJson(Product instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'subtitle': instance.subtitle,
  'imageUrl': instance.imageUrl,
  'category': instance.category,
  'availableSizes': instance.availableSizes,
  'selectedUnit': instance.selectedUnit,
};
