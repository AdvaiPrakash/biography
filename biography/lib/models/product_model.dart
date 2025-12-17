import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String? id; // Firestore Doc ID
  final String title;
  final String price;
  final String offerPrice;
  final String unit;
  final String description;
  final String? imageBase64;
  // New Fields
  final String category;
  final String barcode;
  final String stockQuantity;

  final DateTime createdAt;
  final DateTime updatedAt;

  ProductModel({
    this.id,
    required this.title,
    required this.price,
    this.offerPrice = '',
    required this.unit,
    required this.description,
    this.imageBase64,
    this.category = 'General',
    this.barcode = '',
    this.stockQuantity = '0',
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'price': price,
      'offerPrice': offerPrice,
      'unit': unit,
      'description': description,
      'imageBase64': imageBase64,
      'category': category,
      'barcode': barcode,
      'stockQuantity': stockQuantity,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductModel(
      id: doc.id,
      title: data['title'] as String,
      price: data['price'] as String,
      offerPrice: data['offerPrice'] as String? ?? '',
      unit: data['unit'] as String,
      description: data['description'] as String,
      imageBase64: data['imageBase64'] as String?,
      category: data['category'] as String? ?? 'General',
      barcode: data['barcode'] as String? ?? '',
      stockQuantity: data['stockQuantity'] as String? ?? '0',
      createdAt: DateTime.parse(data['createdAt'] as String),
      updatedAt: DateTime.parse(data['updatedAt'] as String),
    );
  }

  ProductModel copyWith({
    String? id,
    String? title,
    String? price,
    String? offerPrice,
    String? unit,
    String? description,
    String? imageBase64,
    String? category,
    String? barcode,
    String? stockQuantity,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      title: title ?? this.title,
      price: price ?? this.price,
      offerPrice: offerPrice ?? this.offerPrice,
      unit: unit ?? this.unit,
      description: description ?? this.description,
      imageBase64: imageBase64 ?? this.imageBase64,
      category: category ?? this.category,
      barcode: barcode ?? this.barcode,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }


  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is ProductModel &&
      other.id == id &&
      other.title == title;
  }

  @override
  int get hashCode => id.hashCode ^ title.hashCode;
}
