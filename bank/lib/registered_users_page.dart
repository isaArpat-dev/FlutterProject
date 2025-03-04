import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'registered_users_provider.dart';
import 'utils.dart'; // getCategoryIcon fonksiyonu için

class RegisteredUsersPage extends StatelessWidget {
  const RegisteredUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kayıtlı Kullanıcılar")),
      body: Consumer<RegisteredUsersProvider>(
        builder: (context, provider, child) {
          return provider.registeredUsers.isEmpty
              ? const Center(child: Text("Henüz kayıtlı kullanıcı yok."))
              : ListView.builder(
                  itemCount: provider.registeredUsers.length,
                  itemBuilder: (context, index) {
                    final user = provider.registeredUsers[index];
                    return ListTile(
                      title: Text(user["name"]!),
                      subtitle: Text(user["iban"]!),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          provider.removeUser(index);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Kullanıcı silindi")),
                          );
                        },
                      ),
                      onTap: () {
                        _showTransferDialog(
                            context, user["name"]!, user["iban"]!);
                      },
                    );
                  },
                );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddUserDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddUserDialog(BuildContext context) {
    final nameController = TextEditingController();
    final ibanController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Yeni Kullanıcı Ekle"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "İsim"),
              ),
              TextField(
                controller: ibanController,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(labelText: "IBAN"),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("İptal")),
            TextButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    ibanController.text.isNotEmpty) {
                  Provider.of<RegisteredUsersProvider>(context, listen: false)
                      .addUser(nameController.text, ibanController.text);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Kullanıcı eklendi")),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text("Ekle"),
            ),
          ],
        );
      },
    );
  }

  void _showTransferDialog(BuildContext context, String name, String iban) {
    final amountController = TextEditingController();
    String selectedCategory = "Fatura Ödemesi"; // Varsayılan kategori
    List<String> categories = [
      "Fatura Ödemesi",
      "Online Alışveriş",
      "Market Alışverişi",
      "Kira Ödemesi",
      "Diğer"
    ];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("$name Kişisine Para Gönder"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Tutar"),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                items: categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Row(
                      children: [
                        Icon(getCategoryIcon(category), color: Colors.blue),
                        const SizedBox(width: 10),
                        Text(category),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    selectedCategory = value;
                  }
                },
                decoration: const InputDecoration(labelText: "Ödeme Türü"),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("İptal")),
            TextButton(
              onPressed: () {
                if (amountController.text.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          "$name kişisine ₺${amountController.text} gönderildi (${selectedCategory})"),
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text("Gönder"),
            ),
          ],
        );
      },
    );
  }
}
