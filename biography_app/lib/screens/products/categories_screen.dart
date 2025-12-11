import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../models/category.dart';
import '../../services/firebase_service.dart';

class CategoriesScreen extends StatefulWidget {
  final User currentUser;

  const CategoriesScreen({super.key, required this.currentUser});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  List<Category> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    try {
      final categories = await FirebaseService().getCategories();
      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Error loading categories: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _showAddCategoryDialog([Category? category]) async {
    final nameController = TextEditingController(text: category?.name ?? '');

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(category == null ? 'Add Category' : 'Edit Category'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Category Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, nameController.text),
            child: Text(category == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      try {
        if (category == null) {
          final newCategory = Category(name: result, createdAt: DateTime.now());
          await FirebaseService().insertCategory(newCategory);
          await FirebaseService().logActivity(
            widget.currentUser.id!,
            'Added new category',
            'Category: $result',
          );
          _showErrorSnackBar('Category added successfully');
        } else {
          final updatedCategory = Category(
            id: category.id,
            name: result,
            createdAt: category.createdAt,
          );
          await FirebaseService().updateCategory(updatedCategory);
          await FirebaseService().logActivity(
            widget.currentUser.id!,
            'Updated category',
            'Category: $result',
          );
          _showErrorSnackBar('Category updated successfully');
        }
        _loadCategories();
      } catch (e) {
        _showErrorSnackBar('Error saving category: $e');
      }
    }
  }

  Future<void> _deleteCategory(Category category) async {
    // Check if category is assigned to any product
    final products = await FirebaseService().getProducts();
    final hasProducts = products.any((p) => p.categoryId == category.id);

    if (hasProducts) {
      _showErrorSnackBar('Cannot delete category. It is assigned to products.');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await FirebaseService().deleteCategory(category.id!);
        await FirebaseService().logActivity(
          widget.currentUser.id!,
          'Deleted category',
          'Category: ${category.name}',
        );
        _loadCategories();
        _showErrorSnackBar('Category deleted successfully');
      } catch (e) {
        _showErrorSnackBar('Error deleting category: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _categories.isEmpty
              ? const Center(child: Text('No categories found'))
              : ListView.builder(
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade100,
                          child: Text(
                            category.name.substring(0, 1).toUpperCase(),
                            style: TextStyle(
                              color: Colors.blue.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(category.name),
                        subtitle: Text(
                          'Created: ${category.createdAt.toString().split(' ')[0]}',
                        ),
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                                value: 'edit', child: Text('Edit')),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ],
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showAddCategoryDialog(category);
                            } else if (value == 'delete') {
                              _deleteCategory(category);
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategoryDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
