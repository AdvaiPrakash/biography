import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ActivityLogService {
  final CollectionReference _logsCollection = FirebaseFirestore.instance.collection('activity_logs');

  Future<void> logAction({
    required String action,
    required String description,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userName = prefs.getString('userName') ?? 'Unknown';
      final userType = prefs.getString('userType') ?? 'Unknown';

      await _logsCollection.add({
        'action': action,
        'description': description,
        'userName': userName,
        'userType': userType,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error logging action: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getLogs() async {
    final snapshot = await _logsCollection.orderBy('timestamp', descending: true).limit(50).get();
    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }
}
