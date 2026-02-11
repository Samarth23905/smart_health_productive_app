import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'package:universal_html/html.dart' as html;

class DownloadService {
  /// Download file on mobile platforms (Android/iOS)
  static Future<void> downloadFileOnMobile(
    String filename,
    List<int> bytes, {
    String? mimeType,
  }) async {
    try {
      if (io.Platform.isAndroid) {
        await _downloadOnAndroid(filename, bytes);
      } else if (io.Platform.isIOS) {
        await _downloadOnIOS(filename, bytes);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Download file on Web platform
  static Future<void> downloadFileOnWeb(
    String filename,
    List<int> bytes,
  ) async {
    try {
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final link = html.AnchorElement(href: url)
        ..setAttribute('download', filename)
        ..click();
      html.Url.revokeObjectUrl(url);
    } catch (e) {
      rethrow;
    }
  }

  /// Universal download method that handles all platforms
  static Future<void> downloadFile(
    String filename,
    List<int> bytes, {
    String? mimeType,
  }) async {
    try {
      if (kIsWeb) {
        await downloadFileOnWeb(filename, bytes);
      } else {
        await downloadFileOnMobile(filename, bytes, mimeType: mimeType);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Download on Android
  static Future<void> _downloadOnAndroid(
    String filename,
    List<int> bytes,
  ) async {
    try {
      // Request storage permissions
      final PermissionStatus status = await Permission.storage.request();

      if (status.isDenied) {
        throw Exception('Storage permission denied');
      }

      // Try to get downloads directory, fallback to documents directory
      io.Directory? directory;

      try {
        directory = io.Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getApplicationDocumentsDirectory();
        }
      } catch (e) {
        directory = await getApplicationDocumentsDirectory();
      }

      // Create file
      final file = io.File('${directory.path}/$filename');
      await file.writeAsBytes(bytes);

      // Open file
      await OpenFile.open(file.path);
    } catch (e) {
      rethrow;
    }
  }

  /// Download on iOS
  static Future<void> _downloadOnIOS(
    String filename,
    List<int> bytes,
  ) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = io.File('${directory.path}/$filename');
      await file.writeAsBytes(bytes);

      // iOS: Open with available apps or share
      await OpenFile.open(file.path);
    } catch (e) {
      rethrow;
    }
  }

  /// Get file size in readable format
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
}
