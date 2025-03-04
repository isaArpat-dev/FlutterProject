import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Kullanıcı bilgilerini kaydetme
  Future<void> saveUser(String userId, Map<String, dynamic> userData) async {
    await _db.collection('users').doc(userId).set(userData);
  }

  // Kullanıcı bilgilerini okuma
  Future<DocumentSnapshot> getUser(String userId) async {
    return await _db.collection('users').doc(userId).get();
  }

  // Kullanıcı bilgilerini güncelleme
  Future<void> updateUser(String userId, Map<String, dynamic> userData) async {
    await _db.collection('users').doc(userId).update(userData);
  }

  // Kullanıcı bilgilerini silme
  Future<void> deleteUser(String userId) async {
    await _db.collection('users').doc(userId).delete();
  }

  // Diğer kişi isimleri ve IBAN'ları kaydetme
  Future<void> saveContact(
      String userId, Map<String, dynamic> contactData) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('contacts')
        .add(contactData);
  }

  // Diğer kişi isimleri ve IBAN'ları okuma
  Future<QuerySnapshot> getContacts(String userId) async {
    return await _db
        .collection('users')
        .doc(userId)
        .collection('contacts')
        .get();
  }

  // Diğer kişi isimleri ve IBAN'ları güncelleme
  Future<void> updateContact(
      String userId, String contactId, Map<String, dynamic> contactData) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('contacts')
        .doc(contactId)
        .update(contactData);
  }

  // Diğer kişi isimleri ve IBAN'ları silme
  Future<void> deleteContact(String userId, String contactId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('contacts')
        .doc(contactId)
        .delete();
  }

  // Hesap hareketlerini kaydetme
  Future<void> saveTransaction(
      String userId, Map<String, dynamic> transactionData) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .add(transactionData);
  }

  // Hesap hareketlerini okuma
  Future<QuerySnapshot> getTransactions(String userId) async {
    return await _db
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .get();
  }

  // Hesap hareketlerini güncelleme
  Future<void> updateTransaction(String userId, String transactionId,
      Map<String, dynamic> transactionData) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .doc(transactionId)
        .update(transactionData);
  }

  // Hesap hareketlerini silme
  Future<void> deleteTransaction(String userId, String transactionId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .doc(transactionId)
        .delete();
  }
}
