import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/firestore_service.dart';
import 'models/product_model.dart';
import 'models/customer_model.dart';
import 'models/order_model.dart';
import 'models/invoice_model.dart';

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  
  // Data
  List<ProductModel> _allProducts = [];
  List<CustomerModel> _allCustomers = [];
  
  // Selection
  CustomerModel? _selectedCustomer;
  ProductModel? _selectedProduct;
  
  // Cart
  final Map<ProductModel, int> _cart = {}; // Product -> Quantity
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final products = await _firestoreService.getAllProducts();
      final customers = await _firestoreService.getAllCustomers();
      setState(() {
        _allProducts = products;
        _allCustomers = customers;
      });
    } catch (e) {
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _addToCart(ProductModel product) {
    setState(() {
      if (_cart.containsKey(product)) {
        _cart[product] = _cart[product]! + 1;
      } else {
        _cart[product] = 1;
      }
    });
  }

  void _removeFromCart(ProductModel product) {
    setState(() {
      if (_cart.containsKey(product)) {
        if (_cart[product]! > 1) {
          _cart[product] = _cart[product]! - 1;
        } else {
          _cart.remove(product);
        }
      }
    });
  }

  double get _totalAmount {
    double total = 0;
    _cart.forEach((product, quantity) {
      double price = double.tryParse(product.offerPrice.isNotEmpty ? product.offerPrice.replaceAll('₹', '') : product.price.replaceAll('₹', '')) ?? 0.0;
      total += price * quantity;
    });
    return total;
  }

  Future<void> _generateBill() async {
    if (_selectedCustomer == null || _cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a customer and add items to cart')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final total = _totalAmount;
      final orderNumber = 'ORD-${DateTime.now().millisecondsSinceEpoch}';
      
      // Create Order
      final order = OrderModel(
        orderNumber: orderNumber,
        customerName: _selectedCustomer!.name,
        totalAmount: total,
        status: 'Completed',
        date: DateTime.now(),
      );
      await _firestoreService.addOrder(order);

      // Create Invoice
      final invoice = InvoiceModel(
        invoiceNumber: 'INV-${DateTime.now().millisecondsSinceEpoch}',
        customerName: _selectedCustomer!.name,
        amount: total,
        status: 'Unpaid',
        dueDate: DateTime.now().add(const Duration(days: 7)),
      );
      await _firestoreService.addInvoice(invoice);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bill Generated! Saved to Orders & Invoices.')),
        );
        // Reset
        setState(() {
          _cart.clear();
          _selectedCustomer = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Billing', style: GoogleFonts.anekMalayalam()),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Top Section: Selection
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Customer Dropdown
                      DropdownButtonFormField<CustomerModel>(
                        value: _selectedCustomer,
                        decoration: const InputDecoration(
                          labelText: 'Select Customer',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        items: _allCustomers.map((c) {
                          return DropdownMenuItem(value: c, child: Text(c.name));
                        }).toList(),
                        onChanged: (val) => setState(() => _selectedCustomer = val),
                      ),
                      const SizedBox(height: 12),
                      // Product Dropdown (Simple for now, ideal would be search)
                       DropdownButtonFormField<ProductModel>(
                        value: null, // Reset after selection
                        decoration: const InputDecoration(
                          labelText: 'Add Product',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.shopping_bag),
                        ),
                        items: _allProducts.map((p) {
                          return DropdownMenuItem(value: p, child: Text('${p.title} - ${p.price}'));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) _addToCart(val);
                        },
                      ),
                    ],
                  ),
                ),
                const Divider(),
                // Cart List
                Expanded(
                  child: _cart.isEmpty
                      ? Center(child: Text('Cart is empty', style: GoogleFonts.anekMalayalam(color: Colors.grey)))
                      : ListView.builder(
                          itemCount: _cart.length,
                          itemBuilder: (context, index) {
                            final product = _cart.keys.elementAt(index);
                            final quantity = _cart[product]!;
                            final priceStr = product.offerPrice.isNotEmpty ? product.offerPrice : product.price;
                            
                            return ListTile(
                              title: Text(product.title),
                              subtitle: Text(priceStr),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline),
                                    onPressed: () => _removeFromCart(product),
                                  ),
                                  Text('$quantity', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline),
                                    onPressed: () => _addToCart(product),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
                // Bottom Section: Total & Generate
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total:', style: GoogleFonts.anekMalayalam(fontSize: 20, fontWeight: FontWeight.bold)),
                          Text('₹${_totalAmount.toStringAsFixed(2)}', style: GoogleFonts.anekMalayalam(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _generateBill,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Generate Bill'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
