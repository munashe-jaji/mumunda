import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  static String id = 'marketplace_screen';

  @override
  _MarketplaceScreenState createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  List<Map<String, dynamic>> allProducts = [];
  final List<String> categories = [
    'All',
    'Vegetables',
    'Fruits',
    'Farm Implements'
  ];

  String selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      final exhibitorSnapshot = await FirebaseFirestore.instance
          .collection('exhibitors')
          .where('status', isEqualTo: 'approved')
          .get();

      final approvedNames =
          exhibitorSnapshot.docs.map((doc) => doc['name'] as String).toSet();

      final productSnapshot =
          await FirebaseFirestore.instance.collection('products').get();

      final List<Map<String, dynamic>> products = productSnapshot.docs
          .where((doc) => approvedNames.contains(doc['exhibitor']))
          .map((doc) {
        final data = doc.data();

        return {
          'id': doc.id,
          'image': data['image'],
          'name': data['name'],
          'price': data['price'],
          'description': data['description'],
          'exhibitor': data['exhibitor'],
          'quantity': data['quantity'],
          'contact': data['contact'],
          'category': data['category'],
        };
      }).toList();

      setState(() {
        allProducts = products;
      });
    } catch (e) {
      print('Error fetching products: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredProducts = selectedCategory == 'All'
        ? allProducts
        : allProducts.where((p) => p['category'] == selectedCategory).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF1FDF3),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        title: const Text('Marketplace'),
      ),
      body: Column(
        children: [
          Container(
            color: const Color(0xFFB9F6CA),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.filter_list, color: Colors.green),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButton<String>(
                    value: selectedCategory,
                    isExpanded: true,
                    iconEnabledColor: Colors.green[800],
                    dropdownColor: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    onChanged: (newValue) {
                      setState(() {
                        selectedCategory = newValue!;
                      });
                    },
                    items: categories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredProducts.isEmpty
                ? const Center(child: Text('No products found.'))
                : ListView.builder(
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(10),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: product['image'] != null
                                ? Image.network(
                                    product['image'],
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 60,
                                        height: 60,
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.broken_image),
                                      );
                                    },
                                  )
                                : const Icon(Icons.image_not_supported),
                          ),
                          title: Text(product['name'] ?? 'No Name'),
                          subtitle: Text('Price: \$${product['price']}'),
                          trailing: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ProductDetailsScreen(product: product),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[700],
                            ),
                            child: const Text('View'),
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

// -----------------------------------------
// ✅ Simple ProductDetailsScreen for View
// -----------------------------------------
class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({super.key, required this.product});

  final Map<String, dynamic> product;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product['name'] ?? 'Product Details'),
        backgroundColor: Colors.green[800],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            product['image'] != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      product['image'],
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image, size: 100),
                    ),
                  )
                : const Icon(Icons.image_not_supported, size: 100),
            const SizedBox(height: 16),
            Text(
              product['name'] ?? 'No Name',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('Price: \$${product['price'] ?? 'N/A'}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Quantity: ${product['quantity'] ?? 'N/A'}'),
            const SizedBox(height: 10),
            Text('Category: ${product['category'] ?? 'N/A'}'),
            const SizedBox(height: 10),
            Text('Exhibitor: ${product['exhibitor'] ?? 'N/A'}'),
            const SizedBox(height: 10),
            Text('Contact: ${product['contact'] ?? 'N/A'}'),
            const SizedBox(height: 10),
            Text('Description: ${product['description'] ?? 'N/A'}'),
          ],
        ),
      ),
    );
  }
}
