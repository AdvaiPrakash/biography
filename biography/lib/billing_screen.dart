import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/firestore_service.dart';
import 'models/product_model.dart';
import 'models/customer_model.dart';
import 'models/order_model.dart';
import 'models/invoice_model.dart';
import 'services/activity_log_service.dart';
import 'product_form_screen.dart';
import 'services/pdf_invoice_service.dart';

// Helper for "searchable" dropdown or dialog could be moved, 
// using simple dialogs for Quick Add now.

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
        
        // Validation: Ensure selected customer still exists
        if (_selectedCustomer != null) {
          try {
             _selectedCustomer = _allCustomers.firstWhere((c) => c.id == _selectedCustomer!.id);
          } catch (_) {
             _selectedCustomer = null; 
          }
        }
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
      
      // Get Sequential ID
      final invoiceNumber = await _firestoreService.getNextInvoiceNumber();
      // Using same number for order for simplicity, or generate separate
      final orderNumber = invoiceNumber.replaceFirst('INV', 'ORD');
      
      // Prepare Items List
      final List<Map<String, dynamic>> orderItems = [];
      _cart.forEach((product, qty) {
        double price = double.tryParse(product.offerPrice.isNotEmpty ? product.offerPrice.replaceAll('₹', '') : product.price.replaceAll('₹', '')) ?? 0.0;
        orderItems.add({
          'productId': product.id,
          'productName': product.title,
          'quantity': qty,
          'price': price,
        });
      });

      // Create Order
      final order = OrderModel(
        orderNumber: orderNumber,
        customerName: _selectedCustomer!.name,
        totalAmount: total,
        items: orderItems,
        status: 'Completed',
        date: DateTime.now(),
      );
      await _firestoreService.addOrder(order);
      
      // Update Stock (Decrement)
      for (var item in orderItems) {
        await _firestoreService.updateProductStock(item['productId'], -(item['quantity'] as int));
      }

      // Log Activity
      await ActivityLogService().logAction(
        action: 'Bill Generated',
        description: 'Generated Invoice #$invoiceNumber for ₹${total.toStringAsFixed(2)}',
      );

      // Create Invoice
      final invoice = InvoiceModel(
        invoiceNumber: invoiceNumber,
        customerName: _selectedCustomer!.name,
        amount: total,
        status: 'Unpaid',
        dueDate: DateTime.now().add(const Duration(days: 7)),
      );
      await _firestoreService.addInvoice(invoice);

      if (mounted) {
        // Show success dialog with options
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Bill Generated'),
            content: Text('Invoice #$invoiceNumber created successfully.'),
            actions: [
              TextButton(
                onPressed: () { 
                  Navigator.pop(ctx);
                  _reset();
                },
                child: const Text('Close'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  try {
                     await PdfInvoiceService().printInvoice(invoice, order);
                  } catch (printError) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Print Error: $printError')));
                    }
                  }
                  _reset();
                },
                child: const Text('Print / Save PDF'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        setState(() => _isLoading = false);
      }
    }
  }

  void _reset() {
    setState(() {
      _cart.clear();
      _selectedCustomer = null;
      _isLoading = false;
    });
  }

  // Quick Add Customer Dialog
  Future<void> _showAddCustomerDialog() async {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Customer'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name *')),
              TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone *')),
              TextField(controller: addressController, decoration: const InputDecoration(labelText: 'Address')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty || phoneController.text.isEmpty) {
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Name and Phone required')));
                 return;
              }
              Navigator.pop(context);
              
              setState(() => _isLoading = true);
              final newCustomer = CustomerModel(
                name: nameController.text,
                email: '', // Optional
                phone: phoneController.text,
                address: addressController.text,
                joinedAt: DateTime.now(),
              );
              
              await _firestoreService.addCustomer(newCustomer);
              await _loadData(); // Reload to get new customer
              // Auto-select new customer? Simple logic: find by phone
              try {
                final added = _allCustomers.firstWhere((c) => c.phone == newCustomer.phone);
                setState(() => _selectedCustomer = added);
              } catch (_) {}
              
              setState(() => _isLoading = false);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
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
                      // Customer Row
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<CustomerModel>(
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
                          ),
                          const SizedBox(width: 8),
                          IconButton.filled(
                            onPressed: _showAddCustomerDialog,
                            icon: const Icon(Icons.add),
                            tooltip: 'Add Customer',
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Product Row
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<ProductModel>(
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
                          ),
                          const SizedBox(width: 8),
                          IconButton.filled(
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const ProductFormScreen()),
                              );
                              _loadData(); // Refresh products
                            },
                            icon: const Icon(Icons.add),
                            tooltip: 'Add Product',
                            style: IconButton.styleFrom(backgroundColor: const Color(0xFF00BF6D)),
                          ),
                        ],
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
