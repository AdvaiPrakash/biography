import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/activity_log_service.dart';

class AdminLogScreen extends StatelessWidget {
  const AdminLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Activity Logs', style: GoogleFonts.anekMalayalam()),
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: ActivityLogService().getLogs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No logs found'));
          }
          
          final logs = snapshot.data!;
          return ListView.builder(
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              final timestamp = DateTime.tryParse(log['timestamp']) ?? DateTime.now();
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blueGrey.withOpacity(0.1),
                  child: Icon(Icons.history, color: Colors.blueGrey),
                ),
                title: Text(log['action'] ?? 'Unknown Action'),
                subtitle: Text('${log['userName']} (${log['userType']}) - ${log['description']}'),
                trailing: Text(
                  '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}\n${timestamp.day}/${timestamp.month}',
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
