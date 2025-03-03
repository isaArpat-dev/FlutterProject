import 'package:flutter/material.dart';

class RegisteredUsersProvider extends ChangeNotifier {
  final List<Map<String, String>> _registeredUsers = [];

  List<Map<String, String>> get registeredUsers => _registeredUsers;

  void addUser(String name, String iban) {
    _registeredUsers.add({"name": name, "iban": iban});
    notifyListeners();
  }

  void removeUser(int index) {
    _registeredUsers.removeAt(index);
    notifyListeners();
  }
}
