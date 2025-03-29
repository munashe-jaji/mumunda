import 'package:flutter/material.dart';

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

  final List<Map<String, dynamic>> allProducts = [
    {
      'image': 'https://via.placeholder.com/150',
      'name': 'Organic Tomatoes',
      'description': 'Freshly harvested, pesticide-free tomatoes',
      'price': '\$2 per kg',
      'seller': 'GreenFarm Ltd.',
      'quantity': '20 bags available',
      'category': 'Vegetables',
    },
    {
      'image': 'https://via.placeholder.com/150',
      'name': 'Fresh Apples',
      'description': 'Crisp and juicy apples',
      'price': '\$3 per kg',
      'seller': 'Apple Orchard',
      'quantity': '50 bags available',
      'category': 'Fruits',
    },
    {
      'image': 'https://via.placeholder.com/150',
      'name': 'Tractor',
      'description': 'High-performance farm tractor',
      'price': 'Contact for price',
      'seller': 'Farm Equipment Co.',
      'quantity': '5 units available',
      'category': 'Farm Implements',
    },
  ];

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
                    trailing: Column(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.favorite_border),
                          onPressed: () {
                            // Implement add to wishlist functionality
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.message),
                          onPressed: () {
                            // Implement inquire functionality
                          },
                        ),
                      ],
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
