import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  bool isDark = false;

  ThemeMode get mode => isDark ? ThemeMode.dark : ThemeMode.light;

  void toggle() {
    isDark = !isDark;
    notifyListeners();
  }
}
