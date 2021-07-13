import 'package:path_provider/path_provider.dart';
import 'dart:io';

class FileUtils {
  static Future<String> get localPath async {
    final directory = await getExternalStorageDirectory();

    return directory.path;
  }

  static Future<File> _localFile(String fileName) async {
    final path = await localPath;
    print('$path/$fileName.md');
    return File('$path/$fileName.md');
  }

  static Future<File> saveToFile(String fileName, String data) async {
    final file = await _localFile(fileName);
    return file.writeAsString(data);
  }

  static Future<String> readFromFile(String fileName) async {
    try {
      final file = await _localFile(fileName);
      String fileContents = await file.readAsString();
      print(fileContents);
      return fileContents;
    } catch (e) {
      return "Error reading file.";
    }
  }
}