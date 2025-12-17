import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'saved_posters_screen.dart';
import 'product_list_screen.dart';
import 'customer_list_screen.dart';
import 'category_management_screen.dart';
import 'billing_screen.dart';

import 'admin_update_screen.dart';
import 'order_list_screen.dart';
import 'invoice_list_screen.dart';
import 'main.dart';

import 'user_management_screen.dart';
import 'admin_log_screen.dart';
import 'services/firestore_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _userType = 'Staff'; // Default to restricted

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userType = prefs.getString('userType') ?? 'Staff';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FCF9),
      appBar: AppBar(
        title: Text(
          'Dashboard',
          style: GoogleFonts.anekMalayalam(
             fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF00BF6D),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const SignInScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome Back',
                style: GoogleFonts.anekMalayalam(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D3E36),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Manage your biography content',
                style: GoogleFonts.anekMalayalam(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 20),
              // Metrics Section
              FutureBuilder<Map<String, dynamic>>(
                future: FirestoreService().getDashboardMetrics(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox.shrink();
                  final data = snapshot.data!;
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMetricItem(
                          'Today\'s Sales', 
                          '₹${(data['todaySales'] as double).toStringAsFixed(0)}', 
                          Colors.green
                        ),
                        _buildMetricItem(
                          'Low Stock', 
                          '${data['itemsLowStock']}', 
                          Colors.orange
                        ),
                        _buildMetricItem(
                          'Total Orders', 
                          '${data['recentOrderCount']}', 
                          Colors.blue
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 24,
                  crossAxisSpacing: 24,
                  children: [
                    _buildDashboardCard(
                      context,
                      title: 'Billing',
                      icon: Icons.receipt_long,
                      color: Colors.blueAccent,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BillingScreen(),
                        ),
                      ),
                    ),
                    _buildDashboardCard(
                      context,
                      title: 'Posters',
                      icon: Icons.image,
                      color: const Color(0xFF00BF6D),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SavedPostersScreen(),
                        ),
                      ),
                    ),
                    _buildDashboardCard(
                      context,
                      title: 'Products',
                      icon: Icons.shopping_bag,
                      color: const Color(0xFF2D3E36),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProductListScreen(),
                        ),
                      ),
                    ),
                    _buildDashboardCard(
                      context,
                      title: 'Categories',
                      icon: Icons.category,
                      color: Colors.brown,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CategoryManagementScreen(),
                        ),
                      ),
                    ),
                    _buildDashboardCard(
                      context,
                      title: 'Customers',
                      icon: Icons.people,
                      color: const Color(0xFF1E88E5), // Blue shade
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CustomerListScreen(),
                        ),
                      ),
                    ),
                    _buildDashboardCard(
                      context,
                      title: 'Orders',
                      icon: Icons.shopping_basket,
                      color: const Color(0xFFFF9800), // Orange
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const OrderListScreen(),
                        ),
                      ),
                    ),
                    _buildDashboardCard(
                      context,
                      title: 'Invoices',
                      icon: Icons.receipt,
                      color: const Color(0xFF9C27B0), // Purple
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const InvoiceListScreen(),
                        ),
                      ),
                    ),
                    if (_userType == 'Admin')
                      _buildDashboardCard(
                        context,
                        title: 'Users',
                        icon: Icons.manage_accounts,
                        color: Colors.blueGrey,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const UserManagementScreen(),
                          ),
                        ),
                      ),
                    _buildDashboardCard(
                      context,
                      title: 'App Updates',
                      icon: Icons.system_update,
                      color: Colors.pink,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminUpdateScreen(),
                        ),
                      ),
                    ),
                    if (_userType == 'Admin')
                      _buildDashboardCard(
                        context,
                        title: 'Logs',
                        icon: Icons.history,
                        color: Colors.blueGrey,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AdminLogScreen(),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.anekMalayalam(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: GoogleFonts.anekMalayalam(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shadowColor: color.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.8),
                color,
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 40, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: GoogleFonts.anekMalayalam(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
