import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/firestore_service.dart';
import 'models/order_model.dart';
import 'dart:math';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<OrderModel> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    try {
      final orders = await _firestoreService.getAllOrders();
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading orders: $e')),
        );
      }
    }
  }

  Future<void> _seedDemoOrders() async {
    setState(() => _isLoading = true);
    try {
      final random = Random();
      final customers = ['John Doe', 'Jane Smith', 'Robert Johnson', 'Alice Brown'];
      
      for (int i = 0; i < 3; i++) {
        await _firestoreService.addOrder(OrderModel(
          orderNumber: 'ORD-${random.nextInt(99999).toString().padLeft(5, '0')}',
          customerName: customers[random.nextInt(customers.length)],
          totalAmount: (random.nextInt(5000) + 500).toDouble(),
          status: random.nextBool() ? 'Completed' : 'Pending',
          date: DateTime.now().subtract(Duration(days: random.nextInt(30))),
        ));
      }

      await _loadOrders();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Demo orders added!')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error seeding orders: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FCF9),
      appBar: AppBar(
        title: Text('Orders', style: GoogleFonts.anekMalayalam()),
        backgroundColor: const Color(0xFF00BF6D),
        foregroundColor: Colors.white,
        actions: [
          if (_orders.isEmpty && !_isLoading)
            TextButton.icon(
              onPressed: _seedDemoOrders,
              icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
              label: const Text('Add Demo Orders', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        'No orders found',
                        style: GoogleFonts.anekMalayalam(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _seedDemoOrders,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00BF6D),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Generate Demo Orders'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _orders.length,
                  itemBuilder: (context, index) {
                    final order = _orders[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: order.status == 'Completed' 
                              ? Colors.green.withOpacity(0.1) 
                              : Colors.orange.withOpacity(0.1),
                          child: Icon(
                            order.status == 'Completed' ? Icons.check : Icons.access_time,
                            color: order.status == 'Completed' ? Colors.green : Colors.orange,
                          ),
                        ),
                        title: Text(
                          order.orderNumber,
                          style: GoogleFonts.anekMalayalam(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.customerName,
                              style: GoogleFonts.anekMalayalam(fontSize: 14),
                            ),
                            Text(
                              '${order.date.day}/${order.date.month}/${order.date.year}',
                              style: GoogleFonts.anekMalayalam(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '₹${order.totalAmount.toStringAsFixed(2)}',
                              style: GoogleFonts.anekMalayalam(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: const Color(0xFF00BF6D),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: order.status == 'Completed' ? Colors.green : Colors.orange,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                order.status,
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
