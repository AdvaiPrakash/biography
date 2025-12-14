import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io' show Platform;

class UpdateService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  UpdateService() {
    _initNotifications();
  }

  Future<void> _initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    // Note: For iOS you need to add DarwinInitializationSettings
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(initializationSettings);
  }

  Future<void> checkForUpdate(BuildContext context) async {
    try {
      // 1. Get current app version
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String currentVersion = packageInfo.version;

      // 2. Get latest version info from Firestore
      DocumentSnapshot doc =
          await _firestore.collection('app_config').doc('updates').get();

      if (!doc.exists) {
        await _createDefaultConfig(currentVersion);
        return;
      }

      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      String latestVersion = data['latest_version'] ?? currentVersion;
      String apkUrl = data['apk_url'] ?? '';

      // 3. Compare versions
      if (_isUpdateAvailable(currentVersion, latestVersion)) {
        // TRIGGER NOTIFICATION
        await _showUpdateNotification(latestVersion);
        
        if (context.mounted) {
          _showUpdateDialog(context, currentVersion, latestVersion, apkUrl);
        }
      }
    } catch (e) {
      debugPrint('Error checking for updates: $e');
    }
  }

  bool _isUpdateAvailable(String current, String latest) {
    if (current == latest) return false;

    List<int> currentParts = current.split('.').map(int.parse).toList();
    List<int> latestParts = latest.split('.').map(int.parse).toList();

    for (int i = 0; i < latestParts.length; i++) {
        if (i >= currentParts.length) return true;
        if (latestParts[i] > currentParts[i]) return true;
        if (latestParts[i] < currentParts[i]) return false;
    }
    return false;
  }

  Future<void> _showUpdateNotification(String version) async {
    // Request permissions first (Android 13+)
     if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidImplementation?.requestNotificationsPermission();
    }

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'update_channel',
      'App Updates',
      channelDescription: 'Notifications for new app updates',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    
    await _notificationsPlugin.show(
      0,
      'Update Available',
      'A new version ($version) is available to download.',
      platformChannelSpecifics,
    );
  }

  void _showUpdateDialog(
      BuildContext context, String currentVersion, String latestVersion, String url) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Update Available', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('A new version is available!'),
            const SizedBox(height: 12),
            Text('Current Version: $currentVersion', style: const TextStyle(color: Colors.grey)),
            Text('New Version: $latestVersion', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
             const Text('Please update to get the latest features.', style: TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () {
              _launchUpdateUrl(url);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00BF6D), foregroundColor: Colors.white),
            child: const Text('Update Now'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUpdateUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch $url');
    }
  }

  Future<void> _createDefaultConfig(String currentVersion) async {
    try {
      await _firestore.collection('app_config').doc('updates').set({
        'latest_version': currentVersion,
        'apk_url': 'https://example.com/app-release.apk',
      });
      debugPrint('Created default app_config/updates');
    } catch (e) {
      debugPrint('Error creating default config: $e');
    }
  }
}
