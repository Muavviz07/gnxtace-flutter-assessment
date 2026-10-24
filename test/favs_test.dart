import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_gallery/models/pic.dart';
import 'package:infinite_gallery/providers/favs_provider.dart';
import 'package:infinite_gallery/services/storage.dart';

class FakeStorage extends StorageService {
  List<Pic> stored = [];

  @override
  Future<List<Pic>> loadFavs() async => List.from(stored);

  @override
  Future<void> saveFavs(List<Pic> list) async {
    stored = List.from(list);
  }
}

void main() {
  group('FavsProvider Tests', () {
    late FakeStorage fakeStorage;
    late FavsProvider prov;

    setUp(() {
      fakeStorage = FakeStorage();
      prov = FavsProvider(storageService: fakeStorage);
    });

    test('Loads favorites on init', () async {
      final sample = Pic(
        id: 99,
        url: 'u',
        fullUrl: 'f',
        user: 'usr',
        tags: 'tg',
        likes: 10,
        downloads: 5,
        views: 20,
      );
      fakeStorage.stored = [sample];

      await prov.init();

      expect(prov.loaded, isTrue);
      expect(prov.favs.length, 1);
      expect(prov.isFav(99), isTrue);
    });

    test('Toggle adds then removes from favorites', () async {
      final sample = Pic(
        id: 101,
        url: 'u',
        fullUrl: 'f',
        user: 'usr',
        tags: 'tg',
        likes: 1,
        downloads: 1,
        views: 1,
      );

      await prov.toggle(sample);
      expect(prov.isFav(101), isTrue);
      expect(prov.favs.length, 1);
      expect(fakeStorage.stored.length, 1);

      await prov.toggle(sample);
      expect(prov.isFav(101), isFalse);
      expect(prov.favs.isEmpty, isTrue);
      expect(fakeStorage.stored.isEmpty, isTrue);
    });

    test('Remove deletes favorite by id', () async {
      final p1 = Pic(
        id: 1,
        url: 'u',
        fullUrl: 'f',
        user: 'a',
        tags: 't',
        likes: 0,
        downloads: 0,
        views: 0,
      );
      final p2 = Pic(
        id: 2,
        url: 'u',
        fullUrl: 'f',
        user: 'b',
        tags: 't',
        likes: 0,
        downloads: 0,
        views: 0,
      );

      await prov.toggle(p1);
      await prov.toggle(p2);
      expect(prov.favs.length, 2);

      await prov.remove(1);
      expect(prov.isFav(1), isFalse);
      expect(prov.isFav(2), isTrue);
      expect(prov.favs.length, 1);
    });
  });
}
