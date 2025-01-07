import 'package:cloud_firestore/cloud_firestore.dart';


class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Creates an order and updates inventory
  Future<String> createOrder({
    required String customerName,
    required String contactInfo,
    required List<Map<String, dynamic>> cartItems,
  }) async {
    final batch = _firestore.batch(); // To ensure atomic operations

    try {
      // Validate stock availability
      for (final item in cartItems) {
        final productId = item['product']['id'];
        final orderedQuantity = item['quantity'];

        final productDoc = await _firestore.collection('products').doc(productId).get();

        if (!productDoc.exists) {
          return 'Product with ID $productId does not exist.';
        }

        final currentStock = productDoc['total_quantity'] as int;

        if (orderedQuantity > currentStock) {
          return 'Insufficient stock for ${productDoc['name']}.';
        }

        // Subtract ordered quantity from inventory
        final newQuantity = currentStock - orderedQuantity;
        batch.update(_firestore.collection('products').doc(productId), {
          'total_quantity': newQuantity,
        });
      }

      // Save order to Firebase
      final orderData = {
        'customer_name': customerName,
        'contact_info': contactInfo,
        'cart_items': cartItems,
        'order_date': Timestamp.now(),
        'total_price': cartItems.fold(
            0.0,
            (sum, item) => sum +
                (item['product']['price'] as double) *
                    (item['quantity'] as int)),
      };

      final orderDoc = _firestore.collection('orders').doc();
      batch.set(orderDoc, orderData);

      // Commit batch updates
      await batch.commit();
      return 'Order placed successfully!';
    } catch (e) {
      return 'Failed to place order: $e';
    }
  }
}
