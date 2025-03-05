import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'auth_service.dart';

class SecuritySettingsPage extends StatefulWidget {
  const SecuritySettingsPage({super.key});

  @override
  _SecuritySettingsPageState createState() => _SecuritySettingsPageState();
}

class _SecuritySettingsPageState extends State<SecuritySettingsPage> {
  bool _is2FAEnabled = false;

  void _changePassword() {
    TextEditingController passwordController = TextEditingController();
    TextEditingController confirmPasswordController = TextEditingController();
    String? errorMessage;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Şifre Değiştir"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: "Yeni Şifre"),
                  ),
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: true,
                    decoration:
                        const InputDecoration(labelText: "Yeni Şifreyi Onayla"),
                  ),
                  if (errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("İptal"),
                ),
                TextButton(
                  onPressed: () async {
                    if (passwordController.text.isEmpty ||
                        confirmPasswordController.text.isEmpty) {
                      setDialogState(() {
                        errorMessage = "Lütfen tüm alanları doldurun.";
                      });
                      return;
                    }

                    if (passwordController.text !=
                        confirmPasswordController.text) {
                      setDialogState(() {
                        errorMessage = "Şifreler uyuşmuyor!";
                      });
                      return;
                    }

                    try {
                      User? user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        await user
                            .updatePassword(passwordController.text.trim());
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Şifre başarıyla değiştirildi!")),
                        );
                      }
                    } catch (e) {
                      setDialogState(() {
                        errorMessage =
                            "Şifre değiştirme işlemi sırasında bir hata oluştu: ${e.toString()}";
                      });
                    }
                  },
                  child: const Text("Kaydet"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Güvenlik Ayarları")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text("Şifre Değiştir"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _changePassword,
            ),
          ],
        ),
      ),
    );
  }
}
