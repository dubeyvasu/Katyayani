

import 'package:agro/Screens/Product/productPage.dart';
import 'package:agro/controller/inventoryController.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/cartProvider.dart';


class CartPage extends StatelessWidget {
  final TextEditingController customerNameController = TextEditingController();
  final TextEditingController contactInfoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
 
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange, Colors.pink],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'Your Cart',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          return cartProvider.cartItems.isEmpty
              ? _buildEmptyCart(context)
              : Column(
                  children: [
                    Expanded(child: _buildCartList(cartProvider)),
                    _buildCustomerInfoForm(context, cartProvider),
                  ],
                );
        },
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Your Cart is Empty',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 10),
          const Text(
            'Add some items to your cart to get started!',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => ProductPage()),
                (Route<dynamic> route) => false, // Removes all previous routes
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text(
              'Shop Now',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartList(CartProvider cartProvider) {
    return ListView.builder(
      itemCount: cartProvider.cartItems.length,
      itemBuilder: (context, index) {
        final cartItem = cartProvider.cartItems[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.orangeAccent,
              child: Text(
                '${cartItem['quantity']}x',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(cartItem['product']['name']),
            subtitle: Text(
              'Price: ₹${cartItem['product']['price']}',
              style: const TextStyle(color: Colors.black87),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove, color: Colors.red),
                  onPressed: () {
                    if (cartItem['quantity'] > 1) {
                      cartProvider.updateQuantity(
                        cartItem['product']['id'],
                        cartItem['quantity'] - 1,
                      );
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.green),
                  onPressed: () {
                    final totalQuantity = cartItem['product']['quantity'] ?? 0;
                    final currentQuantity = cartItem['quantity'] ?? 0;

                    if (currentQuantity < totalQuantity) {
                      cartProvider.updateQuantity(
                        cartItem['product']['id'],
                        currentQuantity + 1,
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Cannot add more than available stock'),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCustomerInfoForm(BuildContext context, CartProvider cartProvider) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orangeAccent, Colors.pinkAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          TextField(
            controller: customerNameController,
            decoration: InputDecoration(
              labelText: 'Customer Name',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: contactInfoController,
            decoration: InputDecoration(
              labelText: 'Contact Info',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              final response = await _placeOrder(context, cartProvider);

              if (response == 'Order placed successfully!') {
                cartProvider.clearCart(); // Clear cart after successful order
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(response)),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(response)),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text(
              'Place Order',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<String> _placeOrder(BuildContext context, CartProvider cartProvider) async {
    // Validate customer details
    if (customerNameController.text.isEmpty || contactInfoController.text.isEmpty) {
      return 'Please fill out customer details.';
    }

    final orderService = OrderService(); // Instantiate the OrderService

    // Call createOrder to place the order
    final response = await orderService.createOrder(
      customerName: customerNameController.text,
      contactInfo: contactInfoController.text,
      cartItems: cartProvider.cartItems.map((item) {
        return {
          'product': item['product'],
          'quantity': item['quantity'],
        };
      }).toList(),
    );

    return response; // Return the response from createOrder
  }
}
