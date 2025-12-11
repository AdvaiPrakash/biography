import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../models/category.dart' as app_category;
import '../models/customer.dart';
import '../models/user.dart';
import '../models/invoice.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  // In-memory storage for web compatibility
  final List<app_category.Category> _categories = [];
  final List<Product> _products = [];
  final List<Customer> _customers = [];
  final List<User> _users = [];
  final List<Invoice> _invoices = [];
  final List<InvoiceItem> _invoiceItems = [];
  final List<Map<String, dynamic>> _activityLogs = [];

  int _nextCategoryId = 1;
  int _nextProductId = 1;
  int _nextCustomerId = 1;
  int _nextUserId = 2; // Start from 2 since admin is 1
  int _nextInvoiceId = 1;
  int _nextInvoiceItemId = 1;
  int _nextLogId = 1;

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize with default data
    _initializeDefaultData();
    _initialized = true;
  }

  void _initializeDefaultData() {
    // Add default admin user
    _users.add(User(
      id: 1,
      name: 'Admin',
      email: 'admin@biography.com',
      phone: '1234567890',
      userType: UserType.admin,
      createdAt: DateTime.now(),
    ));

    // Add default categories
    final defaultCategories = [
      'Electronics',
      'Clothing',
      'Food & Beverages',
      'Books',
      'Home & Garden'
    ];
    for (String categoryName in defaultCategories) {
      _categories.add(app_category.Category(
        id: _nextCategoryId++,
        name: categoryName,
        createdAt: DateTime.now(),
      ));
    }
  }

  // Category operations
  Future<int> insertCategory(app_category.Category category) async {
    final newCategory = app_category.Category(
      id: _nextCategoryId++,
      name: category.name,
      createdAt: category.createdAt,
    );
    _categories.add(newCategory);
    return newCategory.id!;
  }

  Future<List<app_category.Category>> getCategories() async {
    return List.from(_categories);
  }

  Future<void> updateCategory(app_category.Category category) async {
    final index = _categories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      _categories[index] = category;
    }
  }

  Future<void> deleteCategory(int id) async {
    _categories.removeWhere((c) => c.id == id);
  }

  // Product operations
  Future<int> insertProduct(Product product) async {
    final newProduct = product.copyWith(id: _nextProductId++);
    _products.add(newProduct);
    return newProduct.id!;
  }

  Future<List<Product>> getProducts() async {
    return List.from(_products);
  }

  Future<void> updateProduct(Product product) async {
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _products[index] = product;
    }
  }

  Future<void> deleteProduct(int id) async {
    _products.removeWhere((p) => p.id == id);
  }

  // Customer operations
  Future<int> insertCustomer(Customer customer) async {
    final newCustomer = Customer(
      id: _nextCustomerId++,
      name: customer.name,
      phone: customer.phone,
      email: customer.email,
      address: customer.address,
      createdAt: customer.createdAt,
    );
    _customers.add(newCustomer);
    return newCustomer.id!;
  }

  Future<List<Customer>> getCustomers() async {
    return List.from(_customers);
  }

  Future<void> updateCustomer(Customer customer) async {
    final index = _customers.indexWhere((c) => c.id == customer.id);
    if (index != -1) {
      _customers[index] = customer;
    }
  }

  Future<void> deleteCustomer(int id) async {
    _customers.removeWhere((c) => c.id == id);
  }

  // User operations
  Future<int> insertUser(User user) async {
    final newUser = User(
      id: _nextUserId++,
      name: user.name,
      email: user.email,
      phone: user.phone,
      userType: user.userType,
      createdAt: user.createdAt,
      lastLogin: user.lastLogin,
    );
    _users.add(newUser);
    return newUser.id!;
  }

  Future<List<User>> getUsers() async {
    return List.from(_users);
  }

  Future<void> updateUser(User user) async {
    final index = _users.indexWhere((u) => u.id == user.id);
    if (index != -1) {
      _users[index] = user;
    }
  }

  Future<void> deleteUser(int id) async {
    _users.removeWhere((u) => u.id == id);
  }

  // Invoice operations
  Future<int> insertInvoice(Invoice invoice) async {
    final newInvoice = Invoice(
      id: _nextInvoiceId++,
      invoiceNumber: invoice.invoiceNumber,
      customerId: invoice.customerId,
      invoiceDate: invoice.invoiceDate,
      totalAmount: invoice.totalAmount,
      items: invoice.items,
      createdAt: invoice.createdAt,
    );
    _invoices.add(newInvoice);
    return newInvoice.id!;
  }

  Future<int> insertInvoiceItem(InvoiceItem item) async {
    final newItem = InvoiceItem(
      id: _nextInvoiceItemId++,
      invoiceId: item.invoiceId,
      productId: item.productId,
      quantity: item.quantity,
      unitPrice: item.unitPrice,
      totalPrice: item.totalPrice,
    );
    _invoiceItems.add(newItem);
    return newItem.id!;
  }

  Future<List<Invoice>> getInvoices() async {
    return List.from(_invoices);
  }

  Future<String> generateInvoiceNumber() async {
    final count = _invoices.length;
    final year = DateTime.now().year;
    return 'INV-$year-${(count + 1).toString().padLeft(6, '0')}';
  }

  // Activity log operations
  Future<void> logActivity(int userId, String action, String? details) async {
    _activityLogs.add({
      'id': _nextLogId++,
      'userId': userId,
      'userName': _users.firstWhere((u) => u.id == userId).name,
      'action': action,
      'details': details,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getActivityLogs() async {
    return List.from(_activityLogs);
  }
}
