import 'package:flutter/material.dart';
import 'homepage.dart';

class PinLoginScreen extends StatefulWidget {
  const PinLoginScreen({super.key});

  @override
  _PinLoginScreenState createState() => _PinLoginScreenState();
}

class _PinLoginScreenState extends State<PinLoginScreen> {
  final TextEditingController _pinController = TextEditingController();
  final String correctPin = "1234"; // Burada gerçek kayıtlı PIN kullanılacak

  void _loginWithPin() {
    if (_pinController.text == correctPin) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Hatalı PIN!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("PIN ile Giriş")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Lütfen PIN'inizi girin",
                style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
              decoration: const InputDecoration(labelText: "PIN"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loginWithPin,
              child: const Text("Giriş Yap"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Şifre ile Giriş Yap"),
            ),
          ],
        ),
      ),
    );
  }
}
