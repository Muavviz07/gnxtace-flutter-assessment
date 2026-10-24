import 'package:flutter/foundation.dart';
import '../models/pic.dart';
import '../services/api.dart';

class GalleryProvider extends ChangeNotifier {
  final ApiService api;
  List<Pic> pics = [];
  bool loading = false;
  bool loadingMore = false;
  bool hasMore = true;
  String? err;
  String? moreErr;
  int page = 1;
  String query = '';
  String cat = 'all';

  GalleryProvider({ApiService? apiService}) : api = apiService ?? ApiService();

  Future<void> load() async {
    loading = true;
    err = null;
    page = 1;
    hasMore = true;
    notifyListeners();
    try {
      final res = await api.fetchPics(page: 1, q: query, cat: cat);
      pics = res;
      hasMore = res.length >= 20;
    } catch (e) {
      err = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMore() async {
    if (loading || loadingMore || !hasMore) return;
    loadingMore = true;
    moreErr = null;
    notifyListeners();
    try {
      final next = page + 1;
      final res = await api.fetchPics(page: next, q: query, cat: cat);
      if (res.isEmpty) {
        hasMore = false;
      } else {
        page = next;
        pics.addAll(res);
        if (res.length < 20) {
          hasMore = false;
        }
      }
    } catch (e) {
      moreErr = e.toString();
    } finally {
      loadingMore = false;
      notifyListeners();
    }
  }

  void clearMoreErr() {
    moreErr = null;
    notifyListeners();
  }

  void setCategory(String val) {
    if (cat == val) return;
    cat = val;
    pics = [];
    load();
  }

  void search(String val) {
    if (query == val) return;
    query = val;
    pics = [];
    load();
  }

  Future<void> refresh() async {
    await load();
  }
}
