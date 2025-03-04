import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'splash_screen.dart';
import 'theme_provider.dart';
import 'registered_users_provider.dart';
import 'auth.dart';
import 'firestore.dart'; // Firestore Service import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform, // Firebase başlatma
    );
  } catch (e) {
    // Firebase başlatma hatası
    print('Firebase initialization error: $e');
  }

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isDarkMode = prefs.getBool('isDarkMode') ?? false;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider(isDarkMode)),
        ChangeNotifierProvider(create: (context) => RegisteredUsersProvider()),
        ChangeNotifierProvider(
            create: (context) => AuthProvider()), // Firebase Auth
        Provider(create: (context) => FirestoreService()), // Firestore Service
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
