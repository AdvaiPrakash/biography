class PosterModel {
  final int? id;
  final String title;
  final String price;
  final String unit;
  final String offerPrice;
  final String description;
  final String? imageBase64;
  final DateTime createdAt;
  final DateTime updatedAt;

  PosterModel({
    this.id,
    required this.title,
    required this.price,
    required this.unit,
    this.offerPrice = '',
    required this.description,
    this.imageBase64,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'unit': unit,
      'offerPrice': offerPrice,
      'description': description,
      'imageBase64': imageBase64,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory PosterModel.fromMap(Map<String, dynamic> map) {
    return PosterModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      price: map['price'] as String,
      unit: map['unit'] as String,
      offerPrice: map['offerPrice'] as String? ?? '',
      description: map['description'] as String,
      imageBase64: map['imageBase64'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  PosterModel copyWith({
    int? id,
    String? title,
    String? price,
    String? unit,
    String? offerPrice,
    String? description,
    String? imageBase64,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PosterModel(
      id: id ?? this.id,
      title: title ?? this.title,
      price: price ?? this.price,
      unit: unit ?? this.unit,
      offerPrice: offerPrice ?? this.offerPrice,
      description: description ?? this.description,
      imageBase64: imageBase64 ?? this.imageBase64,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
