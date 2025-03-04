import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth.dart';
import 'registered_users_provider.dart';
import 'transfer_page.dart';

class RegisteredUsersPage extends StatefulWidget {
  const RegisteredUsersPage({super.key});

  @override
  _RegisteredUsersPageState createState() => _RegisteredUsersPageState();
}

class _RegisteredUsersPageState extends State<RegisteredUsersPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ibanController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final registeredUsersProvider =
        Provider.of<RegisteredUsersProvider>(context, listen: false);
    registeredUsersProvider.fetchRegisteredUsers(authProvider.user!.uid);

    // Dinleyiciler ekleyerek butonun aktif/pasif olmasını sağlayalım
    _nameController.addListener(_updateButtonState);
    _ibanController.addListener(_updateButtonState);
  }

  void _updateButtonState() {
    setState(() {});
  }

  @override
  void dispose() {
    _nameController.removeListener(_updateButtonState);
    _ibanController.removeListener(_updateButtonState);
    _nameController.dispose();
    _ibanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final registeredUsersProvider =
        Provider.of<RegisteredUsersProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Kayıtlı Kullanıcılar"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
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
              controller: _ibanController,
              decoration: const InputDecoration(
                labelText: 'IBAN',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _nameController.text.trim().isEmpty ||
                      _ibanController.text.trim().isEmpty
                  ? null
                  : () async {
                      await registeredUsersProvider.addUser(
                        authProvider.user!.uid,
                        _nameController.text.trim(),
                        _ibanController.text.trim(),
                      );
                      _nameController.clear();
                      _ibanController.clear();
                      setState(
                          () {}); // Butonun tekrar aktif olmasını sağlamak için
                    },
              child: const Text('Kullanıcı Ekle'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: registeredUsersProvider.registeredUsers.length,
                itemBuilder: (context, index) {
                  final user = registeredUsersProvider.registeredUsers[index];
                  return ListTile(
                    title: Text(user['name']!),
                    subtitle: Text(user['iban']!),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        await registeredUsersProvider.removeUser(
                            authProvider.user!.uid, index);
                      },
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TransferPage(
                            initialIban: user['iban']!,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
