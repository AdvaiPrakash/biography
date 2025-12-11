import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/user.dart';
import '../services/firebase_service.dart';
import 'products/products_screen.dart';
import 'customers/customers_screen.dart';
import 'invoices/invoices_screen.dart';
import 'users/users_screen.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  final User currentUser;

  const DashboardScreen({super.key, required this.currentUser});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  Map<String, dynamic> _dashboardData = {};

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      final products = await FirebaseService().getProducts();
      final customers = await FirebaseService().getCustomers();
      final invoices = await FirebaseService().getInvoices();

      final today = DateTime.now();
      final todayInvoices = invoices.where((invoice) {
        return invoice.invoiceDate.year == today.year &&
            invoice.invoiceDate.month == today.month &&
            invoice.invoiceDate.day == today.day;
      }).toList();

      final lowStockProducts = products.where((p) => p.stock < 10).toList();
      final totalSales = invoices.fold<double>(
        0,
        (sum, invoice) => sum + invoice.totalAmount,
      );
      final todaySales = todayInvoices.fold<double>(
        0,
        (sum, invoice) => sum + invoice.totalAmount,
      );
      final stockValue = products.fold<double>(
        0,
        (sum, product) => sum + (product.price * product.stock),
      );

      setState(() {
        _dashboardData = {
          'totalProducts': products.length,
          'totalCustomers': customers.length,
          'totalInvoices': invoices.length,
          'todayInvoices': todayInvoices.length,
          'lowStockCount': lowStockProducts.length,
          'totalSales': totalSales,
          'todaySales': todaySales,
          'stockValue': stockValue,
          'recentInvoices': invoices.take(5).toList(),
        };
      });
    } catch (e) {
      print('Error loading dashboard data: $e');
    }
  }

  List<Widget> get _screens => [
        _buildDashboard(),
        ProductsScreen(currentUser: widget.currentUser),
        CustomersScreen(currentUser: widget.currentUser),
        InvoicesScreen(currentUser: widget.currentUser),
        if (widget.currentUser.userType == UserType.admin)
          UsersScreen(currentUser: widget.currentUser),
        ProfileScreen(currentUser: widget.currentUser),
      ];

  List<BottomNavigationBarItem> get _navItems {
    final items = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.dashboard),
        label: 'Dashboard',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.inventory),
        label: 'Products',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.people),
        label: 'Customers',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.receipt),
        label: 'Invoices',
      ),
    ];

    if (widget.currentUser.userType == UserType.admin) {
      items.add(
        const BottomNavigationBarItem(
          icon: Icon(Icons.admin_panel_settings),
          label: 'Users',
        ),
      );
    }

    items.add(
      const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
    );

    return items;
  }

  Widget _buildDashboard() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back, ${widget.currentUser.name}!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 20),
              _buildMetricsGrid(),
              const SizedBox(height: 20),
              _buildRecentInvoices(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildMetricCard(
          'Today\'s Sales',
          '₹${NumberFormat('#,##0.00').format(_dashboardData['todaySales'] ?? 0)}',
          Icons.today,
          Colors.green,
        ),
        _buildMetricCard(
          'Total Sales',
          '₹${NumberFormat('#,##0.00').format(_dashboardData['totalSales'] ?? 0)}',
          Icons.trending_up,
          Colors.blue,
        ),
        _buildMetricCard(
          'Total Products',
          '${_dashboardData['totalProducts'] ?? 0}',
          Icons.inventory,
          Colors.orange,
        ),
        _buildMetricCard(
          'Total Customers',
          '${_dashboardData['totalCustomers'] ?? 0}',
          Icons.people,
          Colors.purple,
        ),
        _buildMetricCard(
          'Low Stock Items',
          '${_dashboardData['lowStockCount'] ?? 0}',
          Icons.warning,
          Colors.red,
        ),
        _buildMetricCard(
          'Stock Value',
          '₹${NumberFormat('#,##0.00').format(_dashboardData['stockValue'] ?? 0)}',
          Icons.account_balance_wallet,
          Colors.teal,
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentInvoices() {
    final recentInvoices = _dashboardData['recentInvoices'] as List? ?? [];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Invoices',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (recentInvoices.isEmpty)
              const Text('No invoices yet')
            else
              ...recentInvoices.map(
                (invoice) => ListTile(
                  leading: const Icon(Icons.receipt),
                  title: Text(invoice.invoiceNumber),
                  subtitle: Text(
                    DateFormat('MMM dd, yyyy').format(invoice.invoiceDate),
                  ),
                  trailing: Text(
                    '₹${NumberFormat('#,##0.00').format(invoice.totalAmount)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: _navItems,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue.shade600,
      ),
    );
  }
}
