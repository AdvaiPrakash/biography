import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product.dart';
import '../models/category.dart' as app_category;
import '../models/customer.dart';
import '../models/user.dart' as app_user;
import '../models/invoice.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collections
  CollectionReference get _categoriesCollection =>
      _firestore.collection('categories');
  CollectionReference get _productsCollection =>
      _firestore.collection('products');
  CollectionReference get _customersCollection =>
      _firestore.collection('customers');
  CollectionReference get _usersCollection => _firestore.collection('users');
  CollectionReference get _invoicesCollection =>
      _firestore.collection('invoices');
  CollectionReference get _invoiceItemsCollection =>
      _firestore.collection('invoice_items');
  CollectionReference get _activityLogsCollection =>
      _firestore.collection('activity_logs');

  Future<void> initialize() async {
    // Initialize default data if needed
    await _initializeDefaultData();
  }

  Future<void> _initializeDefaultData() async {
    // Check if admin user exists
    final usersSnapshot = await _usersCollection
        .where('email', isEqualTo: 'admin@biography.com')
        .get();

    if (usersSnapshot.docs.isEmpty) {
      // Create default admin user
      await _usersCollection.add({
        'name': 'Admin',
        'email': 'admin@biography.com',
        'phone': '1234567890',
        'userType': 'admin',
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': null,
      });
    }

    // Check if categories exist
    final categoriesSnapshot = await _categoriesCollection.limit(1).get();

    if (categoriesSnapshot.docs.isEmpty) {
      // Add default categories
      final defaultCategories = [
        'Electronics',
        'Clothing',
        'Food & Beverages',
        'Books',
        'Home & Garden'
      ];
      for (String categoryName in defaultCategories) {
        await _categoriesCollection.add({
          'name': categoryName,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  // Category operations
  Future<String> insertCategory(app_category.Category category) async {
    final docRef = await _categoriesCollection.add({
      'name': category.name,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  Future<List<app_category.Category>> getCategories() async {
    final snapshot = await _categoriesCollection.orderBy('name').get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return app_category.Category(
        id: doc.id.hashCode, // Convert string ID to int for compatibility
        name: data['name'],
        createdAt:
            (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    }).toList();
  }

  Future<void> updateCategory(app_category.Category category) async {
    // Find document by name since we're using string IDs in Firestore
    final snapshot = await _categoriesCollection
        .where('name', isEqualTo: category.name)
        .get();
    if (snapshot.docs.isNotEmpty) {
      await snapshot.docs.first.reference.update({
        'name': category.name,
      });
    }
  }

  Future<void> deleteCategory(int id) async {
    // This is a simplified approach - in production, you'd want to store the Firestore document ID
    final snapshot = await _categoriesCollection.get();
    for (var doc in snapshot.docs) {
      if (doc.id.hashCode == id) {
        await doc.reference.delete();
        break;
      }
    }
  }

  // Product operations
  Future<String> insertProduct(Product product) async {
    final docRef = await _productsCollection.add({
      'name': product.name,
      'imagePath': product.imagePath,
      'price': product.price,
      'offerPrice': product.offerPrice,
      'categoryId': product.categoryId,
      'stock': product.stock,
      'barcode': product.barcode,
      'description': product.description,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  Future<List<Product>> getProducts() async {
    final snapshot = await _productsCollection.orderBy('name').get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Product(
        id: doc.id.hashCode,
        name: data['name'],
        imagePath: data['imagePath'],
        price: (data['price'] as num).toDouble(),
        offerPrice: data['offerPrice']?.toDouble(),
        categoryId: data['categoryId'],
        stock: (data['stock'] as num).toDouble(),
        barcode: data['barcode'],
        description: data['description'],
        createdAt:
            (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        updatedAt:
            (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    }).toList();
  }

  Future<void> updateProduct(Product product) async {
    final snapshot = await _productsCollection
        .where('barcode', isEqualTo: product.barcode)
        .get();
    if (snapshot.docs.isNotEmpty) {
      await snapshot.docs.first.reference.update({
        'name': product.name,
        'imagePath': product.imagePath,
        'price': product.price,
        'offerPrice': product.offerPrice,
        'categoryId': product.categoryId,
        'stock': product.stock,
        'barcode': product.barcode,
        'description': product.description,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> deleteProduct(int id) async {
    final snapshot = await _productsCollection.get();
    for (var doc in snapshot.docs) {
      if (doc.id.hashCode == id) {
        await doc.reference.delete();
        break;
      }
    }
  }

  // Customer operations
  Future<String> insertCustomer(Customer customer) async {
    final docRef = await _customersCollection.add({
      'name': customer.name,
      'phone': customer.phone,
      'email': customer.email,
      'address': customer.address,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  Future<List<Customer>> getCustomers() async {
    final snapshot = await _customersCollection.orderBy('name').get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Customer(
        id: doc.id.hashCode,
        name: data['name'],
        phone: data['phone'],
        email: data['email'],
        address: data['address'],
        createdAt:
            (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    }).toList();
  }

  Future<void> updateCustomer(Customer customer) async {
    final snapshot = await _customersCollection
        .where('phone', isEqualTo: customer.phone)
        .get();
    if (snapshot.docs.isNotEmpty) {
      await snapshot.docs.first.reference.update({
        'name': customer.name,
        'phone': customer.phone,
        'email': customer.email,
        'address': customer.address,
      });
    }
  }

  Future<void> deleteCustomer(int id) async {
    final snapshot = await _customersCollection.get();
    for (var doc in snapshot.docs) {
      if (doc.id.hashCode == id) {
        await doc.reference.delete();
        break;
      }
    }
  }

  // User operations
  Future<String> insertUser(app_user.User user) async {
    final docRef = await _usersCollection.add({
      'name': user.name,
      'email': user.email,
      'phone': user.phone,
      'userType': user.userType.toString().split('.').last,
      'createdAt': FieldValue.serverTimestamp(),
      'lastLogin':
          user.lastLogin != null ? Timestamp.fromDate(user.lastLogin!) : null,
    });
    return docRef.id;
  }

  Future<List<app_user.User>> getUsers() async {
    final snapshot = await _usersCollection.orderBy('name').get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return app_user.User(
        id: doc.id.hashCode,
        name: data['name'],
        email: data['email'],
        phone: data['phone'],
        userType: app_user.UserType.values.firstWhere(
          (e) => e.toString().split('.').last == data['userType'],
        ),
        createdAt:
            (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        lastLogin: (data['lastLogin'] as Timestamp?)?.toDate(),
      );
    }).toList();
  }

  Future<void> updateUser(app_user.User user) async {
    final snapshot =
        await _usersCollection.where('email', isEqualTo: user.email).get();
    if (snapshot.docs.isNotEmpty) {
      await snapshot.docs.first.reference.update({
        'name': user.name,
        'email': user.email,
        'phone': user.phone,
        'userType': user.userType.toString().split('.').last,
        'lastLogin':
            user.lastLogin != null ? Timestamp.fromDate(user.lastLogin!) : null,
      });
    }
  }

  Future<void> deleteUser(int id) async {
    final snapshot = await _usersCollection.get();
    for (var doc in snapshot.docs) {
      if (doc.id.hashCode == id) {
        await doc.reference.delete();
        break;
      }
    }
  }

  // Invoice operations
  Future<String> insertInvoice(Invoice invoice) async {
    final docRef = await _invoicesCollection.add({
      'invoiceNumber': invoice.invoiceNumber,
      'customerId': invoice.customerId,
      'invoiceDate': Timestamp.fromDate(invoice.invoiceDate),
      'totalAmount': invoice.totalAmount,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  Future<String> insertInvoiceItem(InvoiceItem item) async {
    final docRef = await _invoiceItemsCollection.add({
      'invoiceId': item.invoiceId,
      'productId': item.productId,
      'quantity': item.quantity,
      'unitPrice': item.unitPrice,
      'totalPrice': item.totalPrice,
    });
    return docRef.id;
  }

  Future<List<Invoice>> getInvoices() async {
    final snapshot =
        await _invoicesCollection.orderBy('createdAt', descending: true).get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Invoice(
        id: doc.id.hashCode,
        invoiceNumber: data['invoiceNumber'],
        customerId: data['customerId'],
        invoiceDate: (data['invoiceDate'] as Timestamp).toDate(),
        totalAmount: (data['totalAmount'] as num).toDouble(),
        items: [],
        createdAt:
            (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    }).toList();
  }

  Future<String> generateInvoiceNumber() async {
    final snapshot = await _invoicesCollection.get();
    final count = snapshot.docs.length;
    final year = DateTime.now().year;
    return 'INV-$year-${(count + 1).toString().padLeft(6, '0')}';
  }

  // Activity log operations
  Future<void> logActivity(int userId, String action, String? details) async {
    // Get user name
    final usersSnapshot = await _usersCollection.get();
    String userName = 'Unknown User';
    for (var doc in usersSnapshot.docs) {
      if (doc.id.hashCode == userId) {
        final data = doc.data() as Map<String, dynamic>;
        userName = data['name'];
        break;
      }
    }

    await _activityLogsCollection.add({
      'userId': userId,
      'userName': userName,
      'action': action,
      'details': details,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<List<Map<String, dynamic>>> getActivityLogs() async {
    final snapshot = await _activityLogsCollection
        .orderBy('timestamp', descending: true)
        .limit(50)
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {
        'id': doc.id,
        'userId': data['userId'],
        'userName': data['userName'],
        'action': data['action'],
        'details': data['details'],
        'timestamp':
            (data['timestamp'] as Timestamp?)?.toDate().toIso8601String() ??
                DateTime.now().toIso8601String(),
      };
    }).toList();
  }
}
