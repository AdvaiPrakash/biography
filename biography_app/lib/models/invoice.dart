class Invoice {
  final int? id;
  final String invoiceNumber;
  final int customerId;
  final DateTime invoiceDate;
  final double totalAmount;
  final List<InvoiceItem> items;
  final DateTime createdAt;

  Invoice({
    this.id,
    required this.invoiceNumber,
    required this.customerId,
    required this.invoiceDate,
    required this.totalAmount,
    required this.items,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoiceNumber': invoiceNumber,
      'customerId': customerId,
      'invoiceDate': invoiceDate.toIso8601String(),
      'totalAmount': totalAmount,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Invoice.fromMap(Map<String, dynamic> map) {
    return Invoice(
      id: map['id'],
      invoiceNumber: map['invoiceNumber'],
      customerId: map['customerId'],
      invoiceDate: DateTime.parse(map['invoiceDate']),
      totalAmount: map['totalAmount'].toDouble(),
      items: [],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}

class InvoiceItem {
  final int? id;
  final int invoiceId;
  final int productId;
  final double quantity;
  final double unitPrice;
  final double totalPrice;

  InvoiceItem({
    this.id,
    required this.invoiceId,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoiceId': invoiceId,
      'productId': productId,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
    };
  }

  factory InvoiceItem.fromMap(Map<String, dynamic> map) {
    return InvoiceItem(
      id: map['id'],
      invoiceId: map['invoiceId'],
      productId: map['productId'],
      quantity: map['quantity'].toDouble(),
      unitPrice: map['unitPrice'].toDouble(),
      totalPrice: map['totalPrice'].toDouble(),
    );
  }
}
