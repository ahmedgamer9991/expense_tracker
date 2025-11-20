import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class dataPersistence {
  static Future<Directory?> addFolder() async {
    Directory? appDir = await getExternalStorageDirectory();
    var folderName = "Expense Tracker";
    if (appDir != null) {
      Directory appFolder = Directory("${appDir.path}/$folderName");
      if (!await appFolder.exists()) {
        await appFolder.create(recursive: true);
        print("\nfolder created!!\n");
      }
      print("\nfolder returned\n");
      return appFolder;
    } else {
      print("\nadd folder returned null\n");
      return null;
    }
  }

  static Future<File> initializeStorage() async {
    Directory? appfolder = await addFolder();
    print("\n\ncreating json in initializeStorage\n\n");
      return File("${appfolder?.path}/data.json");
  }

  static Future<void> saveTojson(Map items) async {
    // if (jsonFile == null) return;
    try {
      File jsonFile = await initializeStorage();
      final String jsonData = jsonEncode(items);
      await jsonFile.writeAsString(jsonData);
      print("\nohh it didn't find an issuse saving the json\n");
    } catch (e) {
      print("\noops error happend in saving the json\n");
    }
  }

  static Future<Map?> loadFromjson() async {
    try {
      File file = await initializeStorage();
      if (await file.exists()) {
        String items = await file.readAsString();
        return jsonDecode(items);
      }
    } catch (e) {
      print("Error loading data: $e");
    }
    return null;
  }
} 