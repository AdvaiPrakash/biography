import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> checkForUpdate(BuildContext context) async {
    try {
      // 1. Get current app version
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String currentVersion = packageInfo.version;
      
      // 2. Get latest version info from Firestore
      DocumentSnapshot doc = await _firestore
          .collection('app_config')
          .doc('updates')
          .get();

      if (!doc.exists) {
        await _createDefaultConfig(currentVersion);
        return;
      }

      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      String latestVersion = data['latest_version'] ?? currentVersion;
      String apkUrl = data['apk_url'] ?? '';

      // 3. Compare versions
      if (_isUpdateAvailable(currentVersion, latestVersion)) {
        if (context.mounted) {
          _showUpdateDialog(context, latestVersion, apkUrl);
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
        if (i >= currentParts.length) return true; // Latest has more parts
        if (latestParts[i] > currentParts[i]) return true;
        if (latestParts[i] < currentParts[i]) return false;
    }
    return false;
  }

  void _showUpdateDialog(BuildContext context, String version, String url) {
    showDialog(
      context: context,
      barrierDismissible: false, // Force user decision
      builder: (context) => AlertDialog(
        title: const Text('Update Available'),
        content: Text(
            'A new version ($version) of the App is available. Please update to continue.'),
        actions: [
          // Optional: 'Later' button if you want to allow skipping
          TextButton(
            onPressed: () => Navigator.pop(context),
             child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () {
               _launchUpdateUrl(url);
            },
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
