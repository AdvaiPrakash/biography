import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/user.dart';
import '../../models/customer.dart';
import '../../models/product.dart';
import '../../models/invoice.dart';
import '../../services/storage_service.dart';

class CreateInvoiceScreen extends StatefulWidget {
  final User currentUser;

  const CreateInvoiceScreen({super.key, required this.currentUser});

  @override
  State<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends State<CreateInvoiceScreen> {
  final _formKey = GlobalKey<FormState>();
  List<Customer> _customers = [];
  List<Product> _products = [];
  Customer? _selectedCustomer;
  DateTime _invoiceDate = DateTime.now();
  final List<InvoiceItemData> _invoiceItems = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final customers = await DatabaseService().getCustomers();
      final products = await DatabaseService().getProducts();
      setState(() {
        _customers = customers;
        _products = products;
      });
    } catch (e) {
      _showErrorSnackBar('Error loading data: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _addProduct() {
    showDialog(
      context: context,
      builder: (context) => _ProductSelectionDialog(
        products: _products,
        onProductSelected: (product, quantity) {
          setState(() {
            _invoiceItems.add(
              InvoiceItemData(
                product: product,
                quantity: quantity,
                unitPrice: product.offerPrice ?? product.price,
              ),
            );
          });
        },
      ),
    );
  }

  void _removeItem(int index) {
    setState(() {
      _invoiceItems.removeAt(index);
    });
  }

  double get _totalAmount {
    return _invoiceItems.fold(0, (sum, item) => sum + item.totalPrice);
  }

  Future<void> _saveInvoice() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCustomer == null) {
      _showErrorSnackBar('Please select a customer');
      return;
    }
    if (_invoiceItems.isEmpty) {
      _showErrorSnackBar('Please add at least one product');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final invoiceNumber = await DatabaseService().generateInvoiceNumber();

      final invoice = Invoice(
        invoiceNumber: invoiceNumber,
        customerId: _selectedCustomer!.id!,
        invoiceDate: _invoiceDate,
        totalAmount: _totalAmount,
        items: [],
        createdAt: DateTime.now(),
      );

      final invoiceId = await DatabaseService().insertInvoice(invoice);

      for (final itemData in _invoiceItems) {
        final item = InvoiceItem(
          invoiceId: invoiceId,
          productId: itemData.product.id!,
          quantity: itemData.quantity,
          unitPrice: itemData.unitPrice,
          totalPrice: itemData.totalPrice,
        );
        await DatabaseService().insertInvoiceItem(item);

        // Update product stock
        final updatedProduct = itemData.product.copyWith(
          stock: itemData.product.stock - itemData.quantity,
          updatedAt: DateTime.now(),
        );
        await DatabaseService().updateProduct(updatedProduct);
      }

      await DatabaseService().logActivity(
        widget.currentUser.id!,
        'Generated invoice',
        'Invoice: $invoiceNumber',
      );

      _showErrorSnackBar('Invoice created successfully');
      Navigator.pop(context);
    } catch (e) {
      _showErrorSnackBar('Error creating invoice: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Invoice'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Customer selection
                    DropdownButtonFormField<Customer>(
                      initialValue: _selectedCustomer,
                      decoration: const InputDecoration(
                        labelText: 'Select Customer *',
                        border: OutlineInputBorder(),
                      ),
                      items: _customers.map((customer) {
                        return DropdownMenuItem(
                          value: customer,
                          child: Text('${customer.name} - ${customer.phone}'),
                        );
                      }).toList(),
                      onChanged: (customer) =>
                          setState(() => _selectedCustomer = customer),
                    ),
                    const SizedBox(height: 16),

                    // Invoice date
                    ListTile(
                      title: const Text('Invoice Date'),
                      subtitle: Text(
                        DateFormat('MMM dd, yyyy').format(_invoiceDate),
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _invoiceDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (date != null) {
                          setState(() => _invoiceDate = date);
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Products section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Products',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        ElevatedButton.icon(
                          onPressed: _addProduct,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Product'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Invoice items
                    if (_invoiceItems.isEmpty)
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('No products added'),
                        ),
                      )
                    else
                      ...List.generate(_invoiceItems.length, (index) {
                        final item = _invoiceItems[index];
                        return Card(
                          child: ListTile(
                            title: Text(item.product.name),
                            subtitle: Text(
                              'Qty: ${item.quantity} × ₹${item.unitPrice} = ₹${item.totalPrice.toStringAsFixed(2)}',
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _removeItem(index),
                            ),
                          ),
                        );
                      }),

                    const SizedBox(height: 16),

                    // Total amount
                    Card(
                      color: Colors.blue.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Amount:',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(
                              '₹${_totalAmount.toStringAsFixed(2)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade800,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Save button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveInvoice,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Create Invoice'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InvoiceItemData {
  final Product product;
  final double quantity;
  final double unitPrice;

  InvoiceItemData({
    required this.product,
    required this.quantity,
    required this.unitPrice,
  });

  double get totalPrice => quantity * unitPrice;
}

class _ProductSelectionDialog extends StatefulWidget {
  final List<Product> products;
  final Function(Product, double) onProductSelected;

  const _ProductSelectionDialog({
    required this.products,
    required this.onProductSelected,
  });

  @override
  State<_ProductSelectionDialog> createState() =>
      _ProductSelectionDialogState();
}

class _ProductSelectionDialogState extends State<_ProductSelectionDialog> {
  Product? _selectedProduct;
  final _quantityController = TextEditingController();

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Product'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<Product>(
            initialValue: _selectedProduct,
            decoration: const InputDecoration(
              labelText: 'Select Product',
              border: OutlineInputBorder(),
            ),
            items: widget.products.map((product) {
              return DropdownMenuItem(
                value: product,
                child: Text('${product.name} (Stock: ${product.stock})'),
              );
            }).toList(),
            onChanged: (product) => setState(() => _selectedProduct = product),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _quantityController,
            decoration: const InputDecoration(
              labelText: 'Quantity',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_selectedProduct != null &&
                _quantityController.text.isNotEmpty) {
              final quantity = double.tryParse(_quantityController.text);
              if (quantity != null && quantity > 0) {
                widget.onProductSelected(_selectedProduct!, quantity);
                Navigator.pop(context);
              }
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
