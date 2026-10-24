import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favs_provider.dart';
import '../providers/gallery_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/bottom_loader.dart';
import '../widgets/pic_tile.dart';
import 'favs.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollCtrl = ScrollController();
  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _timer;

  static const List<String> cats = [
    'all',
    'nature',
    'travel',
    'animals',
    'architecture',
    'food',
    'fashion',
    'sports',
    'places',
    'backgrounds',
  ];

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GalleryProvider>().load();
      context.read<FavsProvider>().init();
    });
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 400) {
      context.read<GalleryProvider>().fetchMore();
    }
  }

  void _onSearchChanged(String val) {
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 500), () {
      context.read<GalleryProvider>().search(val);
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _searchCtrl.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<GalleryProvider>();
    final favCount = context.watch<FavsProvider>().favs.length;
    final themeProv = context.watch<ThemeProvider>();
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    if (prov.moreErr != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load more images. Check internet connection.'),
            duration: Duration(seconds: 3),
          ),
        );
        context.read<GalleryProvider>().clearMoreErr();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pixabay Gallery',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(
              themeProv.isDark ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: themeProv.toggle,
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.favorite, color: Colors.redAccent),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FavsScreen()),
                  );
                },
              ),
              if (favCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$favCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
            child: TextField(
              controller: _searchCtrl,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search photos...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          context.read<GalleryProvider>().search('');
                          setState(() {});
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: cats.length,
              itemBuilder: (ctx, idx) {
                final c = cats[idx];
                final sel = prov.cat == c;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(
                      c[0].toUpperCase() + c.substring(1),
                      style: TextStyle(
                        color: sel ? Colors.white : null,
                        fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    selected: sel,
                    selectedColor: Theme.of(context).colorScheme.primary,
                    onSelected: (_) {
                      context.read<GalleryProvider>().setCategory(c);
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: _buildFeed(context, prov, isLandscape),
          ),
        ],
      ),
    );
  }

  Widget _buildFeed(BuildContext context, GalleryProvider prov, bool isLandscape) {
    if (prov.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (prov.err != null && prov.pics.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off, size: 56, color: Colors.grey),
              const SizedBox(height: 12),
              const Text(
                'Could not load images',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'Please check your network and try again.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: prov.refresh,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (prov.pics.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.image_search, size: 56, color: Colors.grey),
            const SizedBox(height: 12),
            const Text(
              'No images found',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Try searching with a different keyword.',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ],
        ),
      );
    }

    final totalCount = prov.pics.length + (prov.hasMore ? 1 : 0);

    return RefreshIndicator(
      onRefresh: prov.refresh,
      child: GridView.builder(
        controller: _scrollCtrl,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(8),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isLandscape ? 3 : 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 0.75,
        ),
        itemCount: totalCount,
        itemBuilder: (ctx, idx) {
          if (idx == prov.pics.length) {
            return const BottomLoader();
          }
          final pic = prov.pics[idx];
          return PicTile(pic: pic);
        },
      ),
    );
  }
}
