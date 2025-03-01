import 'package:flutter/material.dart';

class PaymentsPage extends StatelessWidget {
  const PaymentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ödeme İşlemleri")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Fatura Ödeme",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: Icon(Icons.electric_bolt, color: Colors.orange),
              title: Text("Elektrik Faturası"),
              trailing: ElevatedButton(
                onPressed: () {},
                child: const Text("Öde"),
              ),
            ),
            ListTile(
              leading: Icon(Icons.wifi, color: Colors.blue),
              title: Text("İnternet Faturası"),
              trailing: ElevatedButton(
                onPressed: () {},
                child: const Text("Öde"),
              ),
            ),
            ListTile(
              leading: Icon(Icons.water_drop, color: Colors.blueAccent),
              title: Text("Su Faturası"),
              trailing: ElevatedButton(
                onPressed: () {},
                child: const Text("Öde"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
