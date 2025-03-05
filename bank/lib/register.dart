import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_service.dart';
import 'login_screen.dart';
import 'firestore_service.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _register() async {
    if (_passwordController.text.trim() !=
        _confirmPasswordController.text.trim()) {
      setState(() {
        _errorMessage = "Şifreler uyuşmuyor!";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      String? error = await authService.signUp(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (error != null) {
        setState(() {
          _isLoading = false;
          _errorMessage = error;
        });
      } else {
        // Kullanıcı kaydı başarılı olduğunda Firestore'a kaydet
        final firestoreService =
            Provider.of<FirestoreService>(context, listen: false);
        try {
          final iban = await generateUniqueIban(); // Benzersiz IBAN oluşturma
          final cardNumber = generateCardNumber(); // Kart numarası oluşturma
          final expiryDate =
              generateExpiryDate(); // Son kullanma tarihi oluşturma
          await firestoreService.saveUser(authService.user!.uid, {
            'name': _nameController.text.trim(),
            'email': _emailController.text.trim(),
            'balance': 15000.0, // Başlangıç bakiyesi
            'lastTransaction': null, // Başlangıçta son işlem yok
            'iban': iban, // Oluşturulan IBAN
            'cardNumber': cardNumber, // Oluşturulan kart numarası
            'expiryDate': expiryDate, // Oluşturulan son kullanma tarihi
          });

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        } catch (e) {
          setState(() {
            _isLoading = false;
            _errorMessage =
                "Firestore'a kaydedilirken bir hata oluştu: ${e.toString()}";
          });
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Kayıt sırasında bir hata oluştu: ${e.toString()}";
      });
    }
  }

  Future<String> generateUniqueIban() async {
    final random = Random();
    String iban = '';
    bool isUnique = false;

    while (!isUnique) {
      final uniqueNumber =
          random.nextInt(999999999); // 0 ile 999999999 arasında rastgele sayı
      iban = 'TR' + uniqueNumber.toString().padLeft(24, '0');

      // Firestore'da IBAN'ın benzersiz olup olmadığını kontrol et
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('iban', isEqualTo: iban)
          .get();

      if (snapshot.docs.isEmpty) {
        isUnique = true;
      }
    }

    return iban;
  }

  String generateCardNumber() {
    // Kart numarasının son 2 rakamını rastgele oluşturma
    final random = Random();
    final lastTwoDigits =
        random.nextInt(90) + 10; // 10 ile 99 arasında rastgele sayı
    return '**** **** **** $lastTwoDigits';
  }

  String generateExpiryDate() {
    // Son kullanma tarihini belirleme (bulunduğumuz yılın 6 yıl ilerisinin 12. ayı)
    final now = DateTime.now();
    final expiryYear = now.year + 6;
    return '12/$expiryYear';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kayıt Ol")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Ad Soyad',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'E-posta',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Şifre',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Şifreyi Onayla',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _register,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    child: const Text('Kayıt Ol'),
                  ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: const Text('Zaten bir hesabınız var mı? Giriş yap'),
            ),
          ],
        ),
      ),
    );
  }
}
