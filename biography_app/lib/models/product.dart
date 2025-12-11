class Product {
  final int? id;
  final String name;
  final String imagePath;
  final double price;
  final double? offerPrice;
  final int categoryId;
  final double stock;
  final String barcode;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    this.id,
    required this.name,
    required this.imagePath,
    required this.price,
    this.offerPrice,
    required this.categoryId,
    required this.stock,
    required this.barcode,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'imagePath': imagePath,
      'price': price,
      'offerPrice': offerPrice,
      'categoryId': categoryId,
      'stock': stock,
      'barcode': barcode,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      imagePath: map['imagePath'],
      price: map['price'].toDouble(),
      offerPrice: map['offerPrice']?.toDouble(),
      categoryId: map['categoryId'],
      stock: map['stock'].toDouble(),
      barcode: map['barcode'],
      description: map['description'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  Product copyWith({
    int? id,
    String? name,
    String? imagePath,
    double? price,
    double? offerPrice,
    int? categoryId,
    double? stock,
    String? barcode,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      imagePath: imagePath ?? this.imagePath,
      price: price ?? this.price,
      offerPrice: offerPrice ?? this.offerPrice,
      categoryId: categoryId ?? this.categoryId,
      stock: stock ?? this.stock,
      barcode: barcode ?? this.barcode,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
