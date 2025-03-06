import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'auth_service.dart';
import 'firestore_service.dart';
import 'utils.dart'; // getCategoryIcon fonksiyonunu buraya ekledik.

class AccountDetailsPage extends StatefulWidget {
  const AccountDetailsPage({super.key});

  @override
  _AccountDetailsPageState createState() => _AccountDetailsPageState();
}

class _AccountDetailsPageState extends State<AccountDetailsPage> {
  bool isCardActive = true;
  String cardName = "Kartım";
  double transferLimit = 5000.00;

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final firestoreService = Provider.of<FirestoreService>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Hesap Detayları")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<DocumentSnapshot>(
          future: firestoreService.getUser(authService.user!.uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(child: Text('Bir hata oluştu'));
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text('Kullanıcı verisi bulunamadı'));
            }

            final userData = snapshot.data!.data() as Map<String, dynamic>;
            final cardNumber = userData['cardNumber'] ?? '**** **** **** 1234';
            final expiryDate = userData['expiryDate'] ?? '12/26';
            cardName = userData['cardName'] ?? cardName;
            transferLimit = userData['transferLimit'] ?? transferLimit;
            isCardActive = userData['isCardActive'] ?? isCardActive;

            return Column(
              children: [
                Center(
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 6,
                    color: isCardActive ? Colors.greenAccent[400] : Colors.grey,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            cardName,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            "Kart No: $cardNumber",
                            style: const TextStyle(
                                fontSize: 18, color: Colors.white),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Son Kullanma Tarihi: $expiryDate",
                            style: const TextStyle(
                                fontSize: 18, color: Colors.white),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Limit: ₺${transferLimit.toStringAsFixed(2)}",
                            style: const TextStyle(
                                fontSize: 18, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  "Hesap Hareketleri",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                Expanded(
                  child: FutureBuilder<QuerySnapshot>(
                    future: firestoreService
                        .getUserTransactions(authService.user!.uid),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                            child: Text("Henüz işlem bulunmamaktadır."));
                      }

                      return ListView(
                        children: snapshot.data!.docs.map((doc) {
                          String category = doc['category'];
                          double amount = doc['amount'];

                          return ListTile(
                            leading: Icon(getCategoryIcon(category),
                                size: 32, color: Colors.blue),
                            title: Text(category,
                                style: const TextStyle(fontSize: 18)),
                            subtitle: Text("₺${amount.toStringAsFixed(2)}",
                                style: const TextStyle(fontSize: 16)),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => _showCardSettingsDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Kart Ayarları",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        isCardActive = !isCardActive;
                      });

                      final authService =
                          Provider.of<AuthService>(context, listen: false);
                      final firestoreService =
                          Provider.of<FirestoreService>(context, listen: false);

                      await firestoreService.updateCardInfo(
                        authService.user!.uid,
                        cardName,
                        transferLimit,
                        isCardActive,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isCardActive ? Colors.redAccent : Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      isCardActive
                          ? "Kartı Devre Dışı Bırak"
                          : "Kartı Etkinleştir",
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showCardSettingsDialog(BuildContext context) {
    final nameController = TextEditingController(text: cardName);
    final limitController =
        TextEditingController(text: transferLimit.toString());
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Kart Ayarları"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Kart İsmi"),
              ),
              TextField(
                controller: limitController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Transfer Limiti"),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("İptal")),
            TextButton(
              onPressed: () async {
                final authService =
                    Provider.of<AuthService>(context, listen: false);
                final firestoreService =
                    Provider.of<FirestoreService>(context, listen: false);

                setState(() {
                  cardName = nameController.text;
                  transferLimit =
                      double.tryParse(limitController.text) ?? transferLimit;
                });

                await firestoreService.updateCardInfo(
                  authService.user!.uid,
                  cardName,
                  transferLimit,
                  isCardActive,
                );

                Navigator.pop(context);
              },
              child: const Text("Kaydet"),
            ),
          ],
        );
      },
    );
  }
}
