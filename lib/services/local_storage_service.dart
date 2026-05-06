import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/file_model.dart';

class LocalStorageService {
  static const String _key = 'smart_file_data';

  Future<List<FileItem>> loadFiles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_key);
      if (jsonString == null || jsonString.isEmpty) return [];
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((j) => FileItem.fromJson(j)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveFiles(List<FileItem> files) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = files.map((f) => f.toJson()).toList();
    await prefs.setString(_key, json.encode(jsonList));
  }
}
