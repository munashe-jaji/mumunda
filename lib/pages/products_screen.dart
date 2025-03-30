import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductsScreen extends StatefulWidget {
  final String userEmail;

  const ProductsScreen({super.key, required this.userEmail});
  static String id = 'products_screen';

  @override
  _ProductsScreenState createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  String selectedCategory = 'All';
  final List<String> categories = [
    'All',
    'Vegetables',
    'Fruits',
    'Farm Implements'
  ];

  List<Map<String, dynamic>> allProducts = [];

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    final QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('products').get();
    final List<Map<String, dynamic>> products = snapshot.docs.map((doc) {
      return {
        'image': doc['image'],
        'name': doc['name'],
        'description': doc['description'],
        'price': doc['price'],
        'seller': doc['seller'],
        'quantity': doc['quantity'],
        'category': doc['category'],
      };
    }).toList();

    setState(() {
      allProducts = products;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredProducts = selectedCategory == 'All'
        ? allProducts
        : allProducts
            .where((product) => product['category'] == selectedCategory)
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Logged in as: ${widget.userEmail}'),
          ),
          // Category Filters
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: selectedCategory,
              onChanged: (String? newValue) {
                setState(() {
                  selectedCategory = newValue!;
                });
              },
              items:
                  categories.map<DropdownMenuItem<String>>((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
            ),
          ),
          // Product Listings
          Expanded(
            child: ListView.builder(
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                final product = filteredProducts[index];
                return Card(
                  child: ListTile(
                    leading: Image.network(product['image']),
                    title: Text(product['name']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product['description']),
                        Text('Price: ${product['price']}'),
                        Text('Seller: ${product['seller']}'),
                        Text('Quantity: ${product['quantity']}'),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.message),
                      onPressed: () {
                        // Implement inquire functionality
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
