import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_service.dart';
import 'firestore_service.dart';
import 'transfer_page.dart';

class RegisteredUsersPage extends StatefulWidget {
  const RegisteredUsersPage({super.key});

  @override
  _RegisteredUsersPageState createState() => _RegisteredUsersPageState();
}

class _RegisteredUsersPageState extends State<RegisteredUsersPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ibanController = TextEditingController();
  List<Map<String, dynamic>> _registeredUsers = [];

  @override
  void initState() {
    super.initState();
    final authService = Provider.of<AuthService>(context, listen: false);
    final firestoreService =
        Provider.of<FirestoreService>(context, listen: false);
    _fetchRegisteredUsers(authService.user!.uid, firestoreService);

    // Dinleyiciler ekleyerek butonun aktif/pasif olmasını sağlayalım
    _nameController.addListener(_updateButtonState);
    _ibanController.addListener(_updateButtonState);
  }

  void _updateButtonState() {
    setState(() {});
  }

  Future<void> _fetchRegisteredUsers(
      String userId, FirestoreService firestoreService) async {
    final users = await firestoreService.fetchRegisteredUsers(userId);
    setState(() {
      _registeredUsers = users;
    });
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
    final authService = Provider.of<AuthService>(context);
    final firestoreService = Provider.of<FirestoreService>(context);

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
                      await firestoreService.addUser(
                        authService.user!.uid,
                        _nameController.text.trim(),
                        _ibanController.text.trim(),
                      );
                      _nameController.clear();
                      _ibanController.clear();
                      _fetchRegisteredUsers(
                          authService.user!.uid, firestoreService);
                    },
              child: const Text('Kullanıcı Ekle'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _registeredUsers.length,
                itemBuilder: (context, index) {
                  final user = _registeredUsers[index];
                  return ListTile(
                    title: Text(user['name']!),
                    subtitle: Text(user['iban']!),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        await firestoreService.removeUser(
                            authService.user!.uid, user['docId']!);
                        setState(() {
                          _registeredUsers.removeAt(index);
                        });
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
