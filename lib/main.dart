import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/favs_provider.dart';
import 'providers/gallery_provider.dart';
import 'providers/theme_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GalleryProvider()),
        ChangeNotifierProvider(create: (_) => FavsProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const App(),
    ),
  );
}
