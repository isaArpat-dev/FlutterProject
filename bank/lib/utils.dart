import 'package:flutter/material.dart';

IconData getCategoryIcon(String category) {
  switch (category) {
    case 'Bireysel Ödeme':
      return Icons.person;
    case 'Fatura Ödemesi':
      return Icons.receipt;
    case 'Kira Ödemesi':
      return Icons.home;
    case 'Market Alışverişi':
      return Icons.shopping_cart;
    default:
      return Icons.attach_money; // Varsayılan ikon
  }
}
