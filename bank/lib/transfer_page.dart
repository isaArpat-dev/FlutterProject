import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth.dart';
import 'firestore.dart';

class TransferPage extends StatefulWidget {
  final String? initialIban;

  const TransferPage({super.key, this.initialIban});

  @override
  _TransferPageState createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  final TextEditingController _ibanController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  String _selectedCategory = 'Bireysel Ödeme';

  final List<String> _categories = [
    'Bireysel Ödeme',
    'Fatura Ödemesi',
    'Kira Ödemesi',
    'Market Alışverişi',
    'Diğer'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialIban != null) {
      _ibanController.text = widget.initialIban!;
    }
  }

  void _sendMoney() async {
    String iban = _ibanController.text;
    double amount = double.tryParse(_amountController.text) ?? 0.0;

    if (iban.isNotEmpty && amount > 0) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final firestoreService =
          Provider.of<FirestoreService>(context, listen: false);

      try {
        // Gönderen kullanıcının IBAN'ını al
        final senderSnapshot =
            await firestoreService.getUser(authProvider.user!.uid);
        final senderIban = senderSnapshot['iban'];

        // Gönderen ve alıcı IBAN'ları aynıysa işlemi gerçekleştirme
        if (iban == senderIban) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Kendinize para gönderemezsiniz.')),
          );
          return;
        }

        // Para transferi işlemi
        await firestoreService.transferMoney(
          authProvider.user!.uid,
          iban,
          amount,
          _selectedCategory,
        );

        // İşlem başarılı olduğunda kullanıcıya bildirim göster
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  '$_selectedCategory kategorisinde $amount TL, IBAN: $iban adresine gönderildi.')),
        );

        // Formu temizle
        _ibanController.clear();
        _amountController.clear();
        setState(() {
          _selectedCategory = 'Bireysel Ödeme';
        });
      } catch (e) {
        // Hata durumunda kullanıcıya bildirim göster
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Para transferi sırasında bir hata oluştu: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Para Transferi")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Alıcı Bilgileri",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _ibanController,
              decoration: const InputDecoration(
                labelText: "Alıcı IBAN",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: "Tutar (₺)",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Ödeme Türü",
              ),
              items: _categories.map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCategory = newValue!;
                });
              },
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _sendMoney,
                child: const Text("Gönder"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
