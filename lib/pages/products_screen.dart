import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  _ProductsScreenState createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
      ),
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/fruits.jpg', // Path to your background image
              fit: BoxFit.cover,
            ),
          ),
          // Semi-transparent overlay
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5), // Adjust opacity for text visibility
            ),
          ),
          // Page content
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('products').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text(
                    'No products available',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }
              final products = snapshot.data!.docs;
              return ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index].data() as Map<String, dynamic>;
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.all(10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product['name'] ?? 'No Name',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Price: \$${product['price'] ?? 'N/A'}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Quantity: ${product['quantity'] ?? 'N/A'}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Owner Type: ${product['ownerType'] ?? 'N/A'}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Contact: ${product['contact'] ?? 'N/A'}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
