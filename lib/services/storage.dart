import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pic.dart';

class StorageService {
  static const key = 'fav_pics';

  Future<List<Pic>> loadFavs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(key) ?? [];
    return raw
        .map((e) => Pic.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveFavs(List<Pic> list) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = list.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(key, raw);
  }
}
