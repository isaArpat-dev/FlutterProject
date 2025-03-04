import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisteredUsersProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final List<Map<String, String>> _registeredUsers = [];

  List<Map<String, String>> get registeredUsers => _registeredUsers;

  Future<void> fetchRegisteredUsers(String userId) async {
    final snapshot =
        await _db.collection('users').doc(userId).collection('contacts').get();
    _registeredUsers.clear();
    for (var doc in snapshot.docs) {
      _registeredUsers.add({
        "name": doc['name'],
        "iban": doc['iban'],
      });
    }
    notifyListeners();
  }

  Future<void> addUser(String userId, String name, String iban) async {
    final docRef =
        await _db.collection('users').doc(userId).collection('contacts').add({
      "name": name,
      "iban": iban,
    });
    _registeredUsers.add({"name": name, "iban": iban});
    notifyListeners();
  }

  Future<void> removeUser(String userId, int index) async {
    final docId =
        (await _db.collection('users').doc(userId).collection('contacts').get())
            .docs[index]
            .id;
    await _db
        .collection('users')
        .doc(userId)
        .collection('contacts')
        .doc(docId)
        .delete();
    _registeredUsers.removeAt(index);
    notifyListeners();
  }
}
