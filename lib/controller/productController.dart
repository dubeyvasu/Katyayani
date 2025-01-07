import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProductController {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  /// Adds a product to the Firestore collection
  Future<void> addProduct() async {
    final name = nameController.text.trim();
    final description = descriptionController.text.trim();
    final totalQuantity = int.tryParse(quantityController.text.trim()) ?? 0;
    final price = double.tryParse(priceController.text.trim()) ?? 0.0;

    if (name.isNotEmpty && description.isNotEmpty) {
      try {
        await FirebaseFirestore.instance.collection('products').add({
          'name': name,
          'description': description,
          'total_quantity': totalQuantity,
          'price': price,
        });

        // Clear input fields after adding the product
        clearFields();
      } catch (e) {
        debugPrint("Error adding product: $e");
      }
    } else {
      debugPrint("Name or description is empty");
    }
  }

  /// Clears input fields
  void clearFields() {
    nameController.clear();
    descriptionController.clear();
    quantityController.clear();
    priceController.clear();
  }
}
