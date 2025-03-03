import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'splash_screen.dart';
import 'theme_provider.dart';
import 'registered_users_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isDarkMode = prefs.getBool('isDarkMode') ?? false;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider(isDarkMode)),
        ChangeNotifierProvider(create: (context) => RegisteredUsersProvider()),
      ],
      child: const BankingApp(),
    ),
  );
}

class BankingApp extends StatelessWidget {
  const BankingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: themeProvider.isDarkMode
              ? ThemeProvider.darkTheme
              : ThemeProvider.lightTheme,
          home: const SplashScreen(),
        );
      },
    );
  }
}
