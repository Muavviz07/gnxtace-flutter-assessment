import 'package:flutter/foundation.dart';
import '../models/pic.dart';
import '../services/storage.dart';

class FavsProvider extends ChangeNotifier {
  final StorageService storage;
  List<Pic> favs = [];
  bool loaded = false;

  FavsProvider({StorageService? storageService})
      : storage = storageService ?? StorageService();

  Future<void> init() async {
    favs = await storage.loadFavs();
    loaded = true;
    notifyListeners();
  }

  bool isFav(int id) => favs.any((p) => p.id == id);

  Future<void> toggle(Pic pic) async {
    if (isFav(pic.id)) {
      favs.removeWhere((p) => p.id == pic.id);
    } else {
      favs.insert(0, pic);
    }
    notifyListeners();
    await storage.saveFavs(favs);
  }

  Future<void> remove(int id) async {
    favs.removeWhere((p) => p.id == id);
    notifyListeners();
    await storage.saveFavs(favs);
  }
}
