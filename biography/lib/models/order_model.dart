import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String? id;
  final String orderNumber;
  final String customerName;
  final double totalAmount;
  final String status;
  final DateTime date;

  OrderModel({
    this.id,
    required this.orderNumber,
    required this.customerName,
    required this.totalAmount,
    required this.status,
    DateTime? date,
  }) : date = date ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'orderNumber': orderNumber,
      'customerName': customerName,
      'totalAmount': totalAmount,
      'status': status,
      'date': date.toIso8601String(),
    };
  }

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderModel(
      id: doc.id,
      orderNumber: data['orderNumber'] as String,
      customerName: data['customerName'] as String,
      totalAmount: (data['totalAmount'] as num).toDouble(),
      status: data['status'] as String,
      date: DateTime.parse(data['date'] as String),
    );
  }
}
