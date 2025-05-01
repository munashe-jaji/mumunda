import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});
  static String id = 'marketplace_screen';

  @override
  _MarketplaceScreenState createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
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
        'contact': doc['contact'],
        'ownerType': doc['ownerType'], // Farmer or Exhibitor
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
        title: const Text('Marketplace'),
      ),
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/vegetables.jpg', // Path to your background image
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
          Column(
            children: [
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
                  items: categories
                      .map<DropdownMenuItem<String>>((String category) {
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
                            Row(
                              children: [
                                product['image'] != null
                                    ? Image.network(
                                        product['image'],
                                        height: 80,
                                        width: 80,
                                        fit: BoxFit.cover,
                                      )
                                    : const Icon(Icons.image_not_supported),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product['name'] ?? 'No Name',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        product['description'] ??
                                            'No Description',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
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
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () {
                                    // Navigate to discussion forum
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DiscussionForum(
                                          productOwner: product['seller'],
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.forum),
                                  label: const Text('Discuss'),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    // Direct communication functionality
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DirectChatScreen(
                                          contact: product['contact'],
                                          ownerType: product['ownerType'],
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.message),
                                  label: const Text('Message'),
                                ),
                              ],
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
        ],
      ),
    );
  }
}

class DiscussionForum extends StatelessWidget {
  final String productOwner;

  const DiscussionForum({super.key, required this.productOwner});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discussion Forum'),
      ),
      body: Center(
        child: Text('Discussion forum for $productOwner'),
      ),
    );
  }
}

class DirectChatScreen extends StatelessWidget {
  final String contact;
  final String ownerType;

  const DirectChatScreen(
      {super.key, required this.contact, required this.ownerType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Direct Chat'),
      ),
      body: Center(
        child: Text('Chat with $ownerType at $contact'),
      ),
    );
  }
}