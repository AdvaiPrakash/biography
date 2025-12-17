import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/poster_model.dart';
import '../models/product_model.dart';
import '../models/customer_model.dart';
import '../models/order_model.dart';
import '../models/invoice_model.dart';
import '../models/category_model.dart';
import '../models/user_model.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final CollectionReference _postersCollection = FirebaseFirestore.instance
      .collection('posters');

  // Insert a poster
  Future<String> insertPoster(PosterModel poster) async {
    final docRef = await _postersCollection.add(poster.toMap());
    return docRef.id;
  }

  // Update a poster
  Future<void> updatePoster(String docId, PosterModel poster) async {
    await _postersCollection.doc(docId).update(poster.toMap());
  }

  // Delete a poster
  Future<void> deletePoster(String docId) async {
    await _postersCollection.doc(docId).delete();
  }

  // Get all posters
  Future<List<PosterModelFirestore>> getAllPosters() async {
    final snapshot = await _postersCollection
        .orderBy('updatedAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => PosterModelFirestore.fromFirestore(doc))
        .toList();
  }

  // Search posters by title
  Future<List<PosterModelFirestore>> searchPosters(String query) async {
    final snapshot = await _postersCollection
        .orderBy('title')
        .startAt([query])
        .endAt(['$query\uf8ff'])
        .get();
    return snapshot.docs
        .map((doc) => PosterModelFirestore.fromFirestore(doc))
        .toList();
  }

  // Get poster by id
  Future<PosterModelFirestore?> getPosterById(String docId) async {
    final doc = await _postersCollection.doc(docId).get();
    if (doc.exists) {
      return PosterModelFirestore.fromFirestore(doc);
    }
    return null;
  }

  // Products Collection
  final CollectionReference _productsCollection = FirebaseFirestore.instance
      .collection('products');

  // Insert a product
  Future<String> insertProduct(ProductModel product) async {
    final docRef = await _productsCollection.add(product.toMap());
    return docRef.id;
  }

  // Update a product
  Future<void> updateProduct(String docId, ProductModel product) async {
    await _productsCollection.doc(docId).update(product.toMap());
  }

  // Delete a product
  Future<void> deleteProduct(String docId) async {
    await _productsCollection.doc(docId).delete();
  }

  // Get all products
  Future<List<ProductModel>> getAllProducts() async {
    final snapshot = await _productsCollection
        .orderBy('updatedAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => ProductModel.fromFirestore(doc))
        .toList();
  }

  // Search products by title
  Future<List<ProductModel>> searchProducts(String query) async {
    final snapshot = await _productsCollection
        .orderBy('title')
        .startAt([query])
        .endAt(['$query\uf8ff'])
        .get();
    return snapshot.docs
        .map((doc) => ProductModel.fromFirestore(doc))
        .toList();
  }

  // Get product by id
  Future<ProductModel?> getProductById(String docId) async {
    final doc = await _productsCollection.doc(docId).get();
    if (doc.exists) {
      return ProductModel.fromFirestore(doc);
    }
    return null;
  }
  
  // Update Product Stock
  Future<void> updateProductStock(String docId, int quantityChange) async {
    final docRef = _productsCollection.doc(docId);
    
    return FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) throw Exception('Product not found');
      
      final currentStockStr = snapshot.get('stockQuantity') as String? ?? '0';
      int currentStock = int.tryParse(currentStockStr) ?? 0;
      
      int newStock = currentStock + quantityChange;
      if (newStock < 0) newStock = 0; // Prevent negative stock for now
      
      transaction.update(docRef, {'stockQuantity': newStock.toString()});
    });
  }

  // Customers Collection
  final CollectionReference _customersCollection = FirebaseFirestore.instance
      .collection('customers');

  // Get all customers
  Future<List<CustomerModel>> getAllCustomers() async {
    final snapshot = await _customersCollection
        .orderBy('joinedAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => CustomerModel.fromFirestore(doc))
        .toList();
  }

  // Add customer (for seeding/demo)
  Future<void> addCustomer(CustomerModel customer) async {
    await _customersCollection.add(customer.toMap());
  }

  // Orders Collection
  final CollectionReference _ordersCollection = FirebaseFirestore.instance
      .collection('orders');

  // Get all orders
  Future<List<OrderModel>> getAllOrders() async {
    final snapshot = await _ordersCollection
        .orderBy('date', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => OrderModel.fromFirestore(doc))
        .toList();
  }

  // Add order
  Future<void> addOrder(OrderModel order) async {
    await _ordersCollection.add(order.toMap());
  }

  // Invoices Collection
  final CollectionReference _invoicesCollection = FirebaseFirestore.instance
      .collection('invoices');

  // Get all invoices
  Future<List<InvoiceModel>> getAllInvoices() async {
    final snapshot = await _invoicesCollection
        .orderBy('dueDate', descending: false)
        .get();
    return snapshot.docs
        .map((doc) => InvoiceModel.fromFirestore(doc))
        .toList();
  }

  // Add invoice
  Future<void> addInvoice(InvoiceModel invoice) async {
    await _invoicesCollection.add(invoice.toMap());
  }

  // App Config
  Future<Map<String, dynamic>?> getAppConfig() async {
    final doc =
        await FirebaseFirestore.instance.collection('app_config').doc('updates').get();
    return doc.data();
  }

  Future<void> updateAppConfig(String version, String url) async {
    await FirebaseFirestore.instance.collection('app_config').doc('updates').set({
      'latest_version': version,
      'apk_url': url,
    }, SetOptions(merge: true));
  }

  // Categories Collection
  final CollectionReference _categoriesCollection = FirebaseFirestore.instance
      .collection('categories');

  Future<List<CategoryModel>> getAllCategories() async {
    final snapshot = await _categoriesCollection.orderBy('name').get();
    return snapshot.docs.map((doc) => CategoryModel.fromFirestore(doc)).toList();
  }

  Future<void> addCategory(CategoryModel category) async {
    await _categoriesCollection.add(category.toMap());
  }

  Future<void> updateCategory(String id, CategoryModel category) async {
    await _categoriesCollection.doc(id).update(category.toMap());
  }

  Future<void> deleteCategory(String id) async {
    await _categoriesCollection.doc(id).delete();
  }

  // Check product dependency on category
  Future<List<ProductModel>> getProductsByCategory(String categoryName) async {
    final snapshot = await _productsCollection
        .where('category', isEqualTo: categoryName)
        .get();
    return snapshot.docs.map((doc) => ProductModel.fromFirestore(doc)).toList();
  }

  // Users Collection
  final CollectionReference _usersCollection = FirebaseFirestore.instance
      .collection('users');

  Future<List<UserModel>> getAllUsers() async {
    final snapshot = await _usersCollection.orderBy('name').get();
    return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
  }

  Future<void> addUser(UserModel user) async {
    await _usersCollection.add(user.toMap());
  }

  Future<void> updateUser(String id, UserModel user) async {
    await _usersCollection.doc(id).update(user.toMap());
  }

  Future<void> deleteUser(String id) async {
    await _usersCollection.doc(id).delete();
  }

  // Simple Auth Check (Insecure for production, but fits requirement structure)
  Future<UserModel?> loginUser(String username, String password) async {
    // Checking against email or name for "username"
    // Ideally use email
    final snapshot = await _usersCollection.get();
    for (var doc in snapshot.docs) {
      final user = UserModel.fromFirestore(doc);
      // Check email or name matches username, and password matches
      if ((user.email == username || user.name == username) && user.password == password) {
        return user;
      }
    }
    return null;
  }

  // Invoice Number Counter
  Future<String> getNextInvoiceNumber() async {
    final docRef = FirebaseFirestore.instance.collection('app_config').doc('counters');
    
    return FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      
      int currentCount = 0;
      if (snapshot.exists && snapshot.data()!.containsKey('invoice_count')) {
        currentCount = snapshot.data()!['invoice_count'] as int;
      }
      
      final nextCount = currentCount + 1;
      transaction.set(docRef, {'invoice_count': nextCount}, SetOptions(merge: true));
      
      // Format: INV-YYYY-XXXXXX
      final year = DateTime.now().year;
      final formattedCount = nextCount.toString().padLeft(6, '0');
      return 'INV-$year-$formattedCount';
    });
  }
  // Dashboard Metrics
  Future<Map<String, dynamic>> getDashboardMetrics() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    
    // Get Orders/Invoices for calculation
    final ordersSnapshot = await _ordersCollection.get();
    final productsSnapshot = await _productsCollection.get();
    
    double todaySales = 0;
    double totalSales = 0;
    int itemsLowStock = 0;
    double potentialStockValue = 0;
    
    // Order Metrics
    for (var doc in ordersSnapshot.docs) {
      final order = OrderModel.fromFirestore(doc);
      totalSales += order.totalAmount;
      if (order.date.isAfter(startOfDay)) {
        todaySales += order.totalAmount;
      }
    }
    
    // Product Metrics
    for (var doc in productsSnapshot.docs) {
      final product = ProductModel.fromFirestore(doc);
      int stock = int.tryParse(product.stockQuantity) ?? 0;
      double price = double.tryParse(product.price.replaceAll('₹', '')) ?? 0.0;
      
      potentialStockValue += stock * price;
      if (stock < 5) {
        itemsLowStock++;
      }
    }
    
    return {
      'todaySales': todaySales,
      'totalSales': totalSales,
      'itemsLowStock': itemsLowStock,
      'stockValue': potentialStockValue,
      'recentOrderCount': ordersSnapshot.docs.length, // Just total for now
    };
  }
}

class PosterModelFirestore extends PosterModel {
  final String docId;

  PosterModelFirestore({
    required this.docId,
    super.id,
    required super.title,
    required super.price,
    required super.unit,
    super.offerPrice,
    required super.description,
    super.imageBase64,
    super.createdAt,
    super.updatedAt,
  });

  factory PosterModelFirestore.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PosterModelFirestore(
      docId: doc.id,
      id: data['id'] as int?,
      title: data['title'] as String,
      price: data['price'] as String,
      unit: data['unit'] as String,
      offerPrice: data['offerPrice'] as String? ?? '',
      description: data['description'] as String,
      imageBase64: data['imageBase64'] as String?,
      createdAt: DateTime.parse(data['createdAt'] as String),
      updatedAt: DateTime.parse(data['updatedAt'] as String),
    );
  }
}
