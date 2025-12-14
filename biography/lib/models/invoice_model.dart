import 'package:cloud_firestore/cloud_firestore.dart';

class InvoiceModel {
  final String? id;
  final String invoiceNumber;
  final String customerName;
  final double amount;
  final String status;
  final DateTime dueDate;

  InvoiceModel({
    this.id,
    required this.invoiceNumber,
    required this.customerName,
    required this.amount,
    required this.status,
    DateTime? dueDate,
  }) : dueDate = dueDate ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'invoiceNumber': invoiceNumber,
      'customerName': customerName,
      'amount': amount,
      'status': status,
      'dueDate': dueDate.toIso8601String(),
    };
  }

  factory InvoiceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return InvoiceModel(
      id: doc.id,
      invoiceNumber: data['invoiceNumber'] as String,
      customerName: data['customerName'] as String,
      amount: (data['amount'] as num).toDouble(),
      status: data['status'] as String,
      dueDate: DateTime.parse(data['dueDate'] as String),
    );
  }
}
