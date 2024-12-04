import 'package:flutter/material.dart';
import 'cartscreen.dart'; // Import the CartScreen
import 'modelclass.dart'; // Import the Product model

// Global cart list to hold added products
List<Product> cartList = [];

class ProductDetail extends StatelessWidget {
  final Product product; // Product model for product details

  ProductDetail({required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.productName), // Display product name in the AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            Center(
              child: Image.network(
                product.image,
                width: 200,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16.0),
            // Product name
            Text(
              product.productName,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            // Product details
            Text(
              product.productDetails,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16.0),
            // Product prices
            Text(
              'Price: ₹${product.price}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Wholesale Price: ₹${product.wholesalePrice}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Minimum Order Quantity: ${product.minimumOrderQuantity}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16.0),
            // Add to Cart button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Add the current product to the cart
                  if (!cartList.contains(product)) {
                    cartList.add(product); // Add product if it's not already in the cart
                  }
                  // Navigate to the CartScreen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CartScreen(cartProducts: cartList),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  backgroundColor: Colors.teal,
                ),
                child: const Text('Add to Cart'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
