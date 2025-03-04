import 'package:flutter/material.dart';

class TransferPage extends StatefulWidget {
  const TransferPage({super.key});

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

  void _sendMoney() {
    String iban = _ibanController.text;
    String amount = _amountController.text;

    if (iban.isNotEmpty && amount.isNotEmpty) {
      // Burada işlem detaylarını kaydedebiliriz
      print(
          '$_selectedCategory kategorisinde $amount TL, IBAN: $iban adresine gönderildi.');
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
