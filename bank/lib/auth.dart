import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  User? get user => _user;

  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  // Kullanıcı Kaydı
  Future<String?> signUp(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return null; // Başarılı olduysa hata mesajı döndürme
    } on FirebaseAuthException catch (e) {
      return e.message; // Firebase hata mesajını döndür
    } catch (e) {
      return e.toString(); // Diğer hataları döndür
    }
  }

  // Kullanıcı Girişi
  Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString(); // Diğer hataları döndür
    }
  }

  // Çıkış Yapma
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _user = null;
      notifyListeners();
    } catch (e) {
      throw Exception('Sign out failed: ${e.toString()}');
    }
  }

  // Kullanıcı Durumu Kontrolü
  bool isAuthenticated() {
    return _user != null;
  }
}
