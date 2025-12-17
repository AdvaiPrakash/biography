import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  final String? id; // Firestore Doc ID
  final String name;

  CategoryModel({
    this.id,
    required this.name,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
    };
  }

  factory CategoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CategoryModel(
      id: doc.id,
      name: data['name'] as String,
    );
  }
}
