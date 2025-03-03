import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode;

  ThemeProvider(this._isDarkMode);

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  static ThemeData get lightTheme => ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      );

  static ThemeData get darkTheme => ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      );
}
