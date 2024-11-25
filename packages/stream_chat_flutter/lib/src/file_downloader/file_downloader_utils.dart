import 'dart:io';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';

/// Utility class for downloading files
class FileDownloaderUtils {
  /// Downloads a file with Dio
  static Future<String?> downloadFile2(
      {required String url,
      required String messageId,
      required String title}) async {
    try {
      // Determine the save path
      Directory? saveDir;

      // Scoped Storage - Use app-specific directory

      if (Platform.isAndroid) {
        saveDir = await getExternalStorageDirectory();
      }
      if (Platform.isIOS) {
        saveDir = await getApplicationDocumentsDirectory();
      }

      final filePath = '${saveDir?.path}/$messageId/$title';

      // Download the file
      final dio = Dio();
      await dio.download(url, filePath, onReceiveProgress: (received, total) {
        if (total != -1) {
          print(
              'Download Progress: ${(received / total * 100).toStringAsFixed(0)}%');
        }
      });

      // Validate file existence
      final file = File(filePath);
      if (file.existsSync()) {
        print('File downloaded successfully: $filePath');
        return filePath;
      } else {
        print('File download failed');
        return null;
      }
    } catch (e) {
      print('Error downloading file: $e');
      Fluttertoast.showToast(msg: 'Failed to download file.');
      return null;
    }
  }

  /// Get the saved file path
  static Future<String> getSavedFilePath(
      {required String fileName, required String messageId}) async {
    Directory? documentsDir;
    if (Platform.isAndroid) {
      documentsDir = await getExternalStorageDirectory();
    }
    if (Platform.isIOS) {
      documentsDir = await getApplicationDocumentsDirectory();
    }
    final filePath = '${documentsDir?.path}/$messageId/$fileName';
    return filePath;
  }

  /// Check if file exists
  static Future<bool> doesFileExist({
    required String attachmentTitle,
    required String messageId,
  }) async {
    Directory? documentsDir;
    if (Platform.isAndroid) {
      documentsDir = await getExternalStorageDirectory();
    }
    if (Platform.isIOS) {
      documentsDir = await getApplicationDocumentsDirectory();
    }
    final filePath = '${documentsDir?.path}/$messageId/$attachmentTitle';
    final file = File(filePath);

    if (file.existsSync()) {
      return true;
    }
    return false;
  }
}
