import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favs_provider.dart';
import '../widgets/pic_tile.dart';

class FavsScreen extends StatelessWidget {
  const FavsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favProvider = context.watch<FavsProvider>();
    final favs = favProvider.favs;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites (${favs.length})'),
      ),
      body: favs.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'No favorites yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tap the heart icon on any photo to save it here.',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isLandscape ? 3 : 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.75,
              ),
              itemCount: favs.length,
              itemBuilder: (ctx, idx) {
                final pic = favs[idx];
                return PicTile(pic: pic);
              },
            ),
    );
  }
}
