import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../services/firebase_service.dart';
import 'add_user_screen.dart';

class UsersScreen extends StatefulWidget {
  final User currentUser;

  const UsersScreen({super.key, required this.currentUser});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  List<User> _users = [];
  List<Map<String, dynamic>> _activityLogs = [];
  bool _isLoading = true;
  // Removed unused _selectedTab variable

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final users = await FirebaseService().getUsers();
      final logs = await FirebaseService().getActivityLogs();
      setState(() {
        _users = users;
        _activityLogs = logs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Error loading data: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _deleteUser(User user) async {
    if (user.id == widget.currentUser.id) {
      _showErrorSnackBar('Cannot delete your own account');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete "${user.name}"?'),
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
        await FirebaseService().deleteUser(user.id!);
        await FirebaseService().logActivity(
          widget.currentUser.id!,
          'Deleted user',
          'User: ${user.name}',
        );
        _loadData();
        _showErrorSnackBar('User deleted successfully');
      } catch (e) {
        _showErrorSnackBar('Error deleting user: $e');
      }
    }
  }

  Widget _buildUsersTab() {
    return Column(
      children: [
        Expanded(
          child: _users.isEmpty
              ? const Center(child: Text('No users found'))
              : ListView.builder(
                  itemCount: _users.length,
                  itemBuilder: (context, index) {
                    final user = _users[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: user.userType == UserType.admin
                              ? Colors.red.shade100
                              : Colors.blue.shade100,
                          child: Icon(
                            user.userType == UserType.admin
                                ? Icons.admin_panel_settings
                                : Icons.person,
                            color: user.userType == UserType.admin
                                ? Colors.red.shade800
                                : Colors.blue.shade800,
                          ),
                        ),
                        title: Text(user.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Email: ${user.email}'),
                            Text('Phone: ${user.phone}'),
                            Text(
                              'Type: ${user.userType.toString().split('.').last}',
                            ),
                            if (user.lastLogin != null)
                              Text(
                                'Last login: ${user.lastLogin.toString().split(' ')[0]}',
                              ),
                          ],
                        ),
                        trailing: user.id != widget.currentUser.id
                            ? PopupMenuButton(
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Text('Edit'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Delete'),
                                  ),
                                ],
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AddUserScreen(
                                          currentUser: widget.currentUser,
                                          user: user,
                                        ),
                                      ),
                                    ).then((_) => _loadData());
                                  } else if (value == 'delete') {
                                    _deleteUser(user);
                                  }
                                },
                              )
                            : null,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildActivityLogsTab() {
    return _activityLogs.isEmpty
        ? const Center(child: Text('No activity logs found'))
        : ListView.builder(
            itemCount: _activityLogs.length,
            itemBuilder: (context, index) {
              final log = _activityLogs[index];
              final timestamp = DateTime.parse(log['timestamp']);
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  leading: const Icon(Icons.history),
                  title: Text(log['action']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('User: ${log['userName']}'),
                      if (log['details'] != null)
                        Text('Details: ${log['details']}'),
                      Text('Time: ${timestamp.toString().split('.')[0]}'),
                    ],
                  ),
                ),
              );
            },
          );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Users & Logs'),
          backgroundColor: Colors.blue.shade600,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'Users'),
              Tab(text: 'Activity Logs'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(children: [_buildUsersTab(), _buildActivityLogsTab()]),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    AddUserScreen(currentUser: widget.currentUser),
              ),
            ).then((_) => _loadData());
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
