import 'package:flutter/material.dart';




class CartProvider with ChangeNotifier {
  List<Map<String, dynamic>> _cartItems = [];
  String customerName = '';
  String contactInfo = '';

  List<Map<String, dynamic>> get cartItems => _cartItems;

  // Method to add or update the product quantity in the cart
  void updateQuantity(String productId, int quantity) {
    final index = _cartItems.indexWhere((item) => item['product']['id'] == productId);
    if (index != -1) {
      _cartItems[index]['quantity'] = quantity;
      notifyListeners();
    }
  }

  /// Checks if a product is in the cart
  bool isInCart(String productId) {
    return _cartItems.any((item) => item['product']['id'] == productId);
  }
  // Method to add an item to the cart
  void addToCart(Map<String, dynamic> product) {
    final index = _cartItems.indexWhere((item) => item['product']['id'] == product['id']);
    if (index == -1) {
      _cartItems.add({'product': product, 'quantity': 1});
    } else {
      _cartItems[index]['quantity'] += 1;
    }
    notifyListeners();
  }

  // Method to clear the cart
  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  // Method to update customer info
  void updateCustomerInfo(String name, String contact) {
    customerName = name;
    contactInfo = contact;
    notifyListeners();
  }

  // Method to clear customer info
  void clearCustomerInfo() {
    customerName = '';
    contactInfo = '';
    notifyListeners();
  }
}
