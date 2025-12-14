import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/firestore_service.dart';
import 'models/customer_model.dart';
import 'package:flutter/services.dart' show rootBundle;

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<CustomerModel> _customers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    setState(() => _isLoading = true);
    try {
      final customers = await _firestoreService.getAllCustomers();
      setState(() {
        _customers = customers;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading customers: $e')),
        );
      }
    }
  }

  Future<void> _seedDemoData() async {
    setState(() => _isLoading = true);
    try {
      // 1. John Doe
      await _firestoreService.addCustomer(CustomerModel(
        name: 'John Doe',
        email: 'john.doe@example.com',
        phone: '+91 98765 43210',
        address: '123, Green Park, New Delhi, India',
        profileImageBase64: null, // Will use default placeholder
      ));
      
      // 2. Jane Smith
      await _firestoreService.addCustomer(CustomerModel(
        name: 'Jane Smith',
        email: 'jane.smith@example.com',
        phone: '+91 98123 45678',
        address: '456, Blue Hills, Mumbai, India',
         profileImageBase64: null,
      ));

      // 3. Robert Johnson
      await _firestoreService.addCustomer(CustomerModel(
        name: 'Robert Johnson',
        email: 'robert.j@example.com',
        phone: '+91 88776 65544',
        address: '789, Golden Avenue, Bangalore, India',
         profileImageBase64: null,
      ));

      await _loadCustomers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Demo customers added!')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error seeding data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FCF9),
      appBar: AppBar(
        title: Text('Customers', style: GoogleFonts.anekMalayalam()),
        backgroundColor: const Color(0xFF00BF6D),
        foregroundColor: Colors.white,
        actions: [
          if (_customers.isEmpty && !_isLoading)
            TextButton.icon(
              onPressed: _seedDemoData,
              icon: const Icon(Icons.add_circle_outline, color: Colors.white),
              label: const Text('Add Demo Data', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _customers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.people_outline, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        'No customers found',
                        style: GoogleFonts.anekMalayalam(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _seedDemoData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00BF6D),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Generate Demo Data'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _customers.length,
                  itemBuilder: (context, index) {
                    final customer = _customers[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ExpansionTile(
                        leading: CircleAvatar(
                            radius: 24,
                            backgroundColor: const Color(0xFF00BF6D).withOpacity(0.1),
                            backgroundImage: customer.profileImageBase64 != null
                                ? MemoryImage(base64Decode(customer.profileImageBase64!))
                                : null,
                            child: customer.profileImageBase64 == null
                                ? Text(
                                    customer.name[0].toUpperCase(),
                                    style: GoogleFonts.anekMalayalam(
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF00BF6D),
                                    ),
                                  )
                                : null,
                          ),
                        title: Text(
                          customer.name,
                          style: GoogleFonts.anekMalayalam(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Text(
                          customer.email,
                          style: GoogleFonts.anekMalayalam(
                            color: Colors.grey[600],
                          ),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Divider(),
                                _buildDetailRow(Icons.phone, 'Phone', customer.phone),
                                const SizedBox(height: 8),
                                _buildDetailRow(Icons.location_on, 'Address', customer.address),
                                const SizedBox(height: 8),
                                _buildDetailRow(Icons.calendar_today, 'Joined', 
                                  '${customer.joinedAt.day}/${customer.joinedAt.month}/${customer.joinedAt.year}'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.anekMalayalam(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.anekMalayalam(
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
