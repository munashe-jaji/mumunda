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
    // Step 1: Get all approved exhibitors
    final QuerySnapshot exhibitorSnapshot = await FirebaseFirestore.instance
        .collection('exhibitors')
        .where('status', isEqualTo: 'approved')
        .get();

    final approvedEmails =
        exhibitorSnapshot.docs.map((doc) => doc['email'] as String).toSet();

    // Step 2: Get all products
    final QuerySnapshot productSnapshot =
        await FirebaseFirestore.instance.collection('products').get();

    final List<Map<String, dynamic>> products = productSnapshot.docs
        .where((doc) => approvedEmails.contains(doc['email']))
        .map((doc) {
      return {
        'image': doc['image'],
        'name': doc['name'],
        'description': doc['description'],
        'price': doc['price'],
        'seller': doc['exhibitor'], // renamed field
        'quantity': doc['quantity'],
        'category': doc.data().containsKey('category')
            ? doc['category']
            : 'Uncategorized',
        'contact': doc.data().containsKey('contact') ? doc['contact'] : 'N/A',
        'ownerType': 'Exhibitor',
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
      backgroundColor:
          const Color(0xFFF1FDF3), // Light greenish-white background
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32), // Darker green
        title: const Text('Marketplace'),
      ),
      body: Column(
        children: [
          // Category Dropdown
          Container(
            color: const Color(0xFFB9F6CA), // Soft green background
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
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedCategory = newValue!;
                      });
                    },
                    items: categories.map((String category) {
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

          // Product Cards
          Expanded(
            child: filteredProducts.isEmpty
                ? const Center(
                    child: Text(
                      'No products found.',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return Card(
                        color: Colors.white,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Image and Info Row
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: product['image'] != null
                                        ? Image.network(
                                            product['image'],
                                            height: 80,
                                            width: 80,
                                            fit: BoxFit.cover,
                                          )
                                        : Container(
                                            height: 80,
                                            width: 80,
                                            color: Colors.grey[300],
                                            child: const Icon(
                                                Icons.image_not_supported),
                                          ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product['name'] ?? 'No Name',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          product['description'] ??
                                              'No Description',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 16,
                                runSpacing: 4,
                                children: [
                                  Text('💲 Price: \$${product['price']}'),
                                  Text('📦 Qty: ${product['quantity']}'),
                                  Text('👤 ${product['ownerType']}'),
                                  Text('📞 ${product['contact']}'),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => DiscussionForum(
                                              productOwner: product['seller']),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.forum),
                                    label: const Text('Discuss'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green[700],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              DirectChatScreen(
                                            contact: product['contact'],
                                            ownerType: product['ownerType'],
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.message),
                                    label: const Text('Message'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.green[800],
                                    ),
                                  ),
                                ],
                              )
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
