import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/firestore_service.dart';
import 'models/invoice_model.dart';
import 'dart:math';

class InvoiceListScreen extends StatefulWidget {
  const InvoiceListScreen({super.key});

  @override
  State<InvoiceListScreen> createState() => _InvoiceListScreenState();
}

class _InvoiceListScreenState extends State<InvoiceListScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<InvoiceModel> _invoices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInvoices();
  }

  Future<void> _loadInvoices() async {
    setState(() => _isLoading = true);
    try {
      final invoices = await _firestoreService.getAllInvoices();
      setState(() {
        _invoices = invoices;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading invoices: $e')),
        );
      }
    }
  }

  Future<void> _seedDemoInvoices() async {
    setState(() => _isLoading = true);
    try {
      final random = Random();
      final customers = ['John Doe', 'Jane Smith', 'Robert Johnson', 'Alice Brown'];
      
      for (int i = 0; i < 3; i++) {
        await _firestoreService.addInvoice(InvoiceModel(
          invoiceNumber: 'INV-${random.nextInt(9999).toString().padLeft(4, '0')}',
          customerName: customers[random.nextInt(customers.length)],
          amount: (random.nextInt(10000) + 1000).toDouble(),
          status: random.nextBool() ? 'Paid' : 'Unpaid',
          dueDate: DateTime.now().add(Duration(days: random.nextInt(30))),
        ));
      }

      await _loadInvoices();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Demo invoices added!')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error seeding invoices: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FCF9),
      appBar: AppBar(
        title: Text('Invoices', style: GoogleFonts.anekMalayalam()),
        backgroundColor: const Color(0xFF00BF6D),
        foregroundColor: Colors.white,
        actions: [
          if (_invoices.isEmpty && !_isLoading)
            TextButton.icon(
              onPressed: _seedDemoInvoices,
              icon: const Icon(Icons.receipt_long, color: Colors.white),
              label: const Text('Add Demo Invoices', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _invoices.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.receipt, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        'No invoices found',
                        style: GoogleFonts.anekMalayalam(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _seedDemoInvoices,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00BF6D),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Generate Demo Invoices'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _invoices.length,
                  itemBuilder: (context, index) {
                    final invoice = _invoices[index];
                    final isPaid = invoice.status == 'Paid';
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isPaid 
                              ? Colors.blue.withOpacity(0.1) 
                              : Colors.red.withOpacity(0.1),
                          child: Icon(
                            isPaid ? Icons.check_circle_outline : Icons.warning_amber_rounded,
                            color: isPaid ? Colors.blue : Colors.red,
                          ),
                        ),
                        title: Text(
                          invoice.invoiceNumber,
                          style: GoogleFonts.anekMalayalam(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              invoice.customerName,
                              style: GoogleFonts.anekMalayalam(fontSize: 14),
                            ),
                            Text(
                              'Due: ${invoice.dueDate.day}/${invoice.dueDate.month}/${invoice.dueDate.year}',
                              style: GoogleFonts.anekMalayalam(
                                fontSize: 12,
                                color: isPaid ? Colors.grey : Colors.red,
                              ),
                            ),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '₹${invoice.amount.toStringAsFixed(2)}',
                              style: GoogleFonts.anekMalayalam(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: const Color(0xFF00BF6D),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: isPaid ? Colors.blue : Colors.red,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                invoice.status,
                                style: GoogleFonts.anekMalayalam(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
