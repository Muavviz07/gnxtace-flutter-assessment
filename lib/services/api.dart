import 'dart:io';
import 'package:dio/dio.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/pic.dart';

class ApiService {
  final Dio dio;
  static const apiKey = '58207894-4abbfe3f8e4a304341f26db29';
  static const baseUrl = 'https://pixabay.com/api/';

  ApiService({Dio? client}) : dio = client ?? Dio();

  Future<List<Pic>> fetchPics({int page = 1, String q = '', String cat = ''}) async {
    final params = <String, dynamic>{
      'key': apiKey,
      'image_type': 'photo',
      'per_page': 20,
      'page': page,
      'safesearch': 'true',
    };
    if (q.trim().isNotEmpty) {
      params['q'] = Uri.encodeComponent(q.trim());
    }
    if (cat.trim().isNotEmpty && cat.toLowerCase() != 'all') {
      params['category'] = cat.toLowerCase().trim();
    }

    final res = await dio.get(baseUrl, queryParameters: params);
    final data = res.data as Map<String, dynamic>;
    final hits = data['hits'] as List? ?? [];
    return hits.map((e) => Pic.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<bool> reqPermission() async {
    if (!Platform.isAndroid && !Platform.isIOS) return true;
    if (Platform.isAndroid) {
      final p1 = await Permission.photos.request();
      if (p1.isGranted || p1.isLimited) return true;
      final p2 = await Permission.storage.request();
      if (p2.isGranted) return true;
      return false;
    }
    if (Platform.isIOS) {
      final p = await Permission.photos.request();
      return p.isGranted || p.isLimited;
    }
    return true;
  }

  Future<bool> downloadPic(String url, {void Function(int received, int total)? onProg}) async {
    final ok = await reqPermission();
    if (!ok) return false;
    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/pic_${DateTime.now().millisecondsSinceEpoch}.jpg';
    await dio.download(url, path, onReceiveProgress: onProg);
    await Gal.putImage(path);
    return true;
  }
}
