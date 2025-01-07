import 'package:agro/Screens/Product/cartPage.dart';
import 'package:agro/Screens/orderSummary.dart';
import 'package:agro/controller/productController.dart';
import 'package:agro/provider/cartProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class ProductPage extends StatelessWidget {
  final ProductController _productController = ProductController();

  ProductPage({Key? key}) : super(key: key);

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
          'Product Page',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        actions: [
           IconButton(
            icon: const Icon(Icons.person_outline, size: 28, color: Colors.white),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) =>  OrderSummaryScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart, size: 28, color: Colors.white),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) =>  CartPage()));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildAddProductForm(),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Available Products',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal),
                ),
              ),
            ),
            const SizedBox(height: 10),
            _buildProductList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAddProductForm() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orangeAccent, Colors.pinkAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add New Product',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 10),
          _buildTextField('Product Name', _productController.nameController),
          const SizedBox(height: 10),
          _buildTextField('Description', _productController.descriptionController),
          const SizedBox(height: 10),
          _buildTextField('Total Quantity', _productController.quantityController,
              inputType: TextInputType.number),
          const SizedBox(height: 10),
          _buildTextField('Price', _productController.priceController, inputType: TextInputType.number),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: _productController.addProduct,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Add Product',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {TextInputType? inputType}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      keyboardType: inputType,
    );
  }

  Widget _buildProductList(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('products').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final products = snapshot.data!.docs;

        return ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            final productId = product.id;
            final isAddedToCart = context.watch<CartProvider>().isInCart(productId);

            return _buildProductCard(context, product, productId, isAddedToCart);
          },
        );
      },
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    QueryDocumentSnapshot product,
    String productId,
    bool isAddedToCart,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 6,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 3,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                      image: const DecorationImage(
                        image: AssetImage('lib/Images/food.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      product['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                product['description'],
                style: const TextStyle(fontSize: 16, color: Colors.black54, height: 1.5),
              ),
              const SizedBox(height: 2),
              Text(
                'Quantity: ${product['total_quantity']}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
              ),
              const SizedBox(height: 2),
              Text(
                'Price: ₹${product['price']}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
              ),
              const Divider(color: Colors.grey, thickness: 0.8),
             Align(
  alignment: Alignment.centerRight,
  child: ElevatedButton.icon(
    onPressed: isAddedToCart || product['total_quantity'] == 0
        ? null
        : () {
            context.read<CartProvider>().addToCart({
              'id': productId,
              'name': product['name'],
              'price': product['price'],
              'quantity': product['total_quantity'],
            });
          },
    icon: isAddedToCart
        ? const Icon(Icons.check, color: Colors.white)
        : const Icon(Icons.add_shopping_cart, color: Colors.white),
    label: Text(
      isAddedToCart ? 'Added to Cart' : 'Add to Cart',
      style: const TextStyle(fontSize: 14, color: Colors.white),
    ),
    style: ElevatedButton.styleFrom(
      backgroundColor: isAddedToCart || product['total_quantity'] == 0
          ? Colors.grey
          : Colors.teal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
),

            ],
          ),
        ),
      ),
    );
  }
}
