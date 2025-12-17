import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/order_model.dart';
import '../models/invoice_model.dart';

class PdfInvoiceService {
  Future<Uint8List> generateInvoice(InvoiceModel invoice, OrderModel order) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('INVOICE', style: pw.TextStyle(fontSize: 40, fontWeight: pw.FontWeight.bold)),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Invoice #: ${invoice.invoiceNumber}'),
                      pw.Text('Date: ${order.date.toIso8601String().split('T')[0]}'),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              
              // Customer Details
              pw.Text('Bill To:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(order.customerName),
              pw.SizedBox(height: 20),

              // Items Table
              pw.Table.fromTextArray(
                context: context,
                headers: ['Item', 'Qty', 'Price', 'Total'],
                data: order.items.map((item) {
                  final qty = item['quantity'] as int;
                  final price = (item['price'] as num).toDouble();
                  return [
                    item['productName'],
                    qty.toString(),
                    price.toStringAsFixed(2),
                    (price * qty).toStringAsFixed(2),
                  ];
                }).toList(),
              ),
              pw.SizedBox(height: 20),

              // Total
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Text('Total Amount: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text('INR ${order.totalAmount.toStringAsFixed(2)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18)),
                ],
              ),
               pw.SizedBox(height: 40),
               pw.Text('Thank you for your business!', style: const pw.TextStyle(color: PdfColors.grey)),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  Future<void> printInvoice(InvoiceModel invoice, OrderModel order) async {
    final bytes = await generateInvoice(invoice, order);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => bytes,
      name: 'Invoice-${invoice.invoiceNumber}',
    );
  }
}
