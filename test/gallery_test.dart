import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_gallery/models/pic.dart';
import 'package:infinite_gallery/providers/gallery_provider.dart';

void main() {
  group('Pic Model Tests', () {
    test('Pic correctly parses from and to json', () {
      final json = {
        'id': 12345,
        'webformatURL': 'https://example.com/thumb.jpg',
        'largeImageURL': 'https://example.com/full.jpg',
        'user': 'photographer_sam',
        'tags': 'mountain, nature',
        'likes': 42,
        'downloads': 100,
        'views': 500,
      };

      final pic = Pic.fromJson(json);

      expect(pic.id, 12345);
      expect(pic.url, 'https://example.com/thumb.jpg');
      expect(pic.fullUrl, 'https://example.com/full.jpg');
      expect(pic.user, 'photographer_sam');
      expect(pic.tags, 'mountain, nature');
      expect(pic.likes, 42);
      expect(pic.downloads, 100);
      expect(pic.views, 500);

      final out = pic.toJson();
      expect(out['id'], 12345);
      expect(out['webformatURL'], 'https://example.com/thumb.jpg');
    });

    test('Pic equality based on id', () {
      final p1 = Pic(
        id: 1,
        url: 'u1',
        fullUrl: 'f1',
        user: 'a',
        tags: 't',
        likes: 0,
        downloads: 0,
        views: 0,
      );
      final p2 = Pic(
        id: 1,
        url: 'u2',
        fullUrl: 'f2',
        user: 'b',
        tags: 't',
        likes: 1,
        downloads: 1,
        views: 1,
      );
      expect(p1, equals(p2));
    });
  });

  group('GalleryProvider State Tests', () {
    test('Initial state values are correct', () {
      final prov = GalleryProvider();
      expect(prov.pics, isEmpty);
      expect(prov.loading, isFalse);
      expect(prov.loadingMore, isFalse);
      expect(prov.hasMore, isTrue);
      expect(prov.err, isNull);
      expect(prov.page, 1);
      expect(prov.cat, 'all');
      expect(prov.query, '');
    });

    test('setCategory updates category filter', () {
      final prov = GalleryProvider();
      prov.setCategory('nature');
      expect(prov.cat, 'nature');
    });
  });
}
