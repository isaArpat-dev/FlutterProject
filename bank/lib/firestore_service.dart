import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Kayıtlı kullanıcı ekleme
  Future<void> addUser(String userId, String name, String iban) async {
    await _db.collection('users').doc(userId).collection('contacts').add({
      "name": name,
      "iban": iban,
    });
  }

  // Kayıtlı kullanıcı silme
  Future<void> removeUser(String userId, String docId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('contacts')
        .doc(docId)
        .delete();
  }

  // Kullanıcı bilgilerini kaydetme
  Future<void> saveUser(String userId, Map<String, dynamic> userData) async {
    await _db.collection('users').doc(userId).set(userData);
  }

  // Kullanıcı bilgilerini okuma
  Future<DocumentSnapshot> getUser(String userId) async {
    return await _db.collection('users').doc(userId).get();
  }

  // Kullanıcı bilgilerini dinleme
  Stream<DocumentSnapshot> getUserStream(String userId) {
    return _db.collection('users').doc(userId).snapshots();
  }

  // Kullanıcı işlemlerini getirme
  Future<QuerySnapshot> getUserTransactions(String userId) async {
    return await _db
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .get();
  }

  // Para transferi işlemi
  Future<void> transferMoney(String senderId, String receiverIban,
      double amount, String category) async {
    final senderRef = _db.collection('users').doc(senderId);

    await _db.runTransaction((transaction) async {
      final senderSnapshot = await transaction.get(senderRef);

      if (!senderSnapshot.exists) {
        throw Exception("Gönderen kullanıcı bulunamadı");
      }

      final senderBalance = senderSnapshot['balance'] as double;

      if (senderBalance < amount) {
        throw Exception("Yetersiz bakiye");
      }

      // Gönderen kullanıcının bakiyesini güncelle
      transaction.update(senderRef, {'balance': senderBalance - amount});

      // Gönderen kullanıcının işlem geçmişine ekle
      transaction.set(senderRef.collection('transactions').doc(), {
        'amount': -amount,
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'transfer',
        'category': category,
        'to': receiverIban,
      });

      // Gönderen kullanıcının son işlemini güncelle
      transaction.update(senderRef, {'lastTransaction': '₺$amount gönderildi'});

      // Alıcı kullanıcının IBAN'ına göre kullanıcıyı bul ve bakiyesini güncelle
      final receiverSnapshot = await _db
          .collection('users')
          .where('iban', isEqualTo: receiverIban)
          .get();
      if (receiverSnapshot.docs.isNotEmpty) {
        final receiverRef = receiverSnapshot.docs.first.reference;
        final receiverBalance =
            receiverSnapshot.docs.first['balance'] as double;
        transaction.update(receiverRef, {'balance': receiverBalance + amount});

        // Alıcı kullanıcının işlem geçmişine ekle
        transaction.set(receiverRef.collection('transactions').doc(), {
          'amount': amount,
          'timestamp': FieldValue.serverTimestamp(),
          'type': 'transfer',
          'category': category,
          'from': senderId,
        });

        // Alıcı kullanıcının son işlemini güncelle
        transaction.update(receiverRef, {'lastTransaction': '₺$amount alındı'});
      } else {
        throw Exception("Alıcı IBAN bulunamadı");
      }
    });
  }

  // Kayıtlı kullanıcıları getirme
  Future<List<Map<String, dynamic>>> fetchRegisteredUsers(String userId) async {
    final snapshot =
        await _db.collection('users').doc(userId).collection('contacts').get();
    return snapshot.docs
        .map((doc) => {
              "docId": doc.id,
              "name": doc['name'],
              "iban": doc['iban'],
            })
        .toList();
  }

  // Kart bilgilerini güncelleme
  Future<void> updateCardInfo(String userId, String cardName,
      double transferLimit, bool isCardActive) async {
    await _db.collection('users').doc(userId).update({
      'cardName': cardName,
      'transferLimit': transferLimit,
      'isCardActive': isCardActive,
    });
  }
}
