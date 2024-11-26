import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mime_type/mime_type.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Utility class for downloading files
class FileDownloaderUtils {
  /// Key for folder uri in shared preferences
  static const String _folderUriKey = 'folderAccessUri';

  /// Downloads a file with Dio
  static Future<String?> downloadFile2(
      {required String url,
      required String messageId,
      required void Function(double?) onDownloadProgress,
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
          onDownloadProgress.call(received / total * 100);
        }
      });

      // Validate file existence
      final file = File(filePath);
      if (file.existsSync()) {
        if (Platform.isAndroid) {
          // Save the file to external storage
          _saveFileToExternalStorage(
              sourceFile: file, fileName: title, messageId: messageId);
        }

        return filePath;
      } else {
        return null;
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to download file.');
      return null;
    }
  }

  /// Get folder uri from shared preferences
  static Future<String?> _getFolderUriFromSharedPreferences() async {
    // Get the folderUri from persistent storage (e.g., SharedPreferences or Hive)
    final pref = await SharedPreferences.getInstance();
    final folderUri = pref.getString(_folderUriKey);
    return folderUri;
  }

  /// Get folder uri from shared preferences
  static Future<void> _saveFolderUriToSharedPreferences(String value) async {
    // Get the folderUri from persistent storage (e.g., SharedPreferences or Hive)
    final pref = await SharedPreferences.getInstance();
    await pref.setString(_folderUriKey, value);
  }

  /// Get the folder uri by selecting a folder
  static Future<void> _saveFileToExternalStorage(
      {required File sourceFile,
      required String fileName,
      required String messageId}) async {
    if (!await FlutterFileDialog.isPickDirectorySupported()) {
      Fluttertoast.showToast(
          msg: 'This feature is not supported on this device');
      return;
    }

    var folderUri = await _getFolderUriFromSharedPreferences();

    if (folderUri != null) {
      FlutterFileDialog.saveFileToDirectory(
          directory: DirectoryLocation(folderUri),
          mimeType: mime(sourceFile.path),
          data: File(sourceFile.path).readAsBytesSync(),
          fileName: fileName);
      return;
    }

    // Select a folder
    folderUri = (await FlutterFileDialog.pickDirectory())?.toString();

    if (folderUri == null) {
      return;
    }

    // Save it to persistent storage
    await _saveFolderUriToSharedPreferences(folderUri.toString());
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
