// ignore_for_file: avoid_print
import 'dart:io';

void main() async {
  print('🚀 Biography Release Helper');
  print('---------------------------');

  final pubspecFile = File('pubspec.yaml');
  if (!await pubspecFile.exists()) {
    print('❌ Error: pubspec.yaml not found.');
    return;
  }

  String content = await pubspecFile.readAsString();
  final versionRegex = RegExp(r'version: (\d+\.\d+\.\d+)\+(\d+)');
  final match = versionRegex.firstMatch(content);

  if (match == null) {
    print('❌ Error: Could not find version in pubspec.yaml.');
    return;
  }

  String currentVersion = match.group(1)!;
  int currentBuildNumber = int.parse(match.group(2)!);

  print('Current Version: $currentVersion+$currentBuildNumber');

  // Increment build number
  int newBuildNumber = currentBuildNumber + 1;
  // Simple version bump logic (e.g., 1.0.1 -> 1.0.1+2, or ask user?)
  // For now, let's keep version same but bump build number, OR ask user.
  
  print('Enter new version (e.g., 1.0.2) or press ENTER to keep $currentVersion:');
  String? inputVersion = stdin.readLineSync();
  String newVersion = inputVersion != null && inputVersion.isNotEmpty 
      ? inputVersion 
      : currentVersion;

  print('Updating to: $newVersion+$newBuildNumber');

  // Replace in content
  String newContent = content.replaceFirst(
    'version: $currentVersion+$currentBuildNumber',
    'version: $newVersion+$newBuildNumber',
  );

  await pubspecFile.writeAsString(newContent);
  print('✅ Updated pubspec.yaml');

  print('🔨 Building APK...');
  var result = await Process.run('flutter', ['build', 'apk', '--release'], runInShell: true);
  
  if (result.exitCode != 0) {
    print('❌ Build Failed:');
    print(result.stderr);
    return;
  }

  print('✅ Build Success!');
  print('APK Path: build/app/outputs/flutter-apk/app-release.apk');
  
  print('\n---------------------------');
  print('NEXT STEPS FOR AUTOMATION:');
  print('1. Upload the APK to Firebase Storage.');
  print('2. Copy the Download URL.');
  print('3. Update Firestore (app_config/updates):');
  print('   latest_version: $newVersion');
  print('   apk_url: <YOUR_NEW_URL>');
  print('---------------------------');
  
  print('Press ENTER to exit.');
  stdin.readLineSync();
}
