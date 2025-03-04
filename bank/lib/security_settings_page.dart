import 'package:flutter/material.dart';

class SecuritySettingsPage extends StatefulWidget {
  const SecuritySettingsPage({super.key});

  @override
  _SecuritySettingsPageState createState() => _SecuritySettingsPageState();
}

class _SecuritySettingsPageState extends State<SecuritySettingsPage> {
  bool _pinCodeEnabled = false;
  String? _savedPin;

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
                  onPressed: () {
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

                    // Buraya şifre değiştirme işlemi eklenecek
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Şifre başarıyla değiştirildi!")),
                    );
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

  void _setPinCode() {
    TextEditingController pinController = TextEditingController();
    String? errorMessage;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("PIN Kodu Belirle"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: pinController,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    obscureText: true,
                    decoration:
                        const InputDecoration(labelText: "4 Haneli PIN"),
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
                  onPressed: () {
                    if (pinController.text.length != 4) {
                      setDialogState(() {
                        errorMessage = "PIN 4 haneli olmalıdır.";
                      });
                      return;
                    }

                    setState(() {
                      _savedPin = pinController.text;
                      _pinCodeEnabled = true;
                    });

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("PIN başarıyla ayarlandı!")),
                    );
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

  void _logout() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Çıkış Yap"),
          content: const Text("Hesabınızdan çıkış yapmak istiyor musunuz?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("İptal"),
            ),
            TextButton(
              onPressed: () {
                // Buraya çıkış işlemi eklenecek
                Navigator.pop(context);
                Navigator.pop(context); // Settings sayfasına geri dön
              },
              child: const Text("Çıkış Yap"),
            ),
          ],
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
            SwitchListTile(
              title: const Text("PIN Kodu Kullan"),
              subtitle: const Text("Hızlı giriş için PIN belirleyin"),
              value: _pinCodeEnabled,
              onChanged: (bool value) {
                if (value) {
                  _setPinCode();
                } else {
                  setState(() {
                    _pinCodeEnabled = false;
                    _savedPin = null;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("PIN kaldırıldı.")),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
