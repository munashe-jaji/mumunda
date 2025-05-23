import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mis/pages/exhibitor_details_screen.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});
  static String id = 'marketplace_screen';

  @override
  _MarketplaceScreenState createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  List<Map<String, dynamic>> allProducts = [];
  List<Map<String, dynamic>> displayedProducts = [];
  String searchQuery = '';
  bool isLoading = true;

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

      // Convert image paths to URLs in parallel
      final futures = productSnapshot.docs.map((doc) async {
        final data = doc.data();
        if (!approvedNames.contains(data['exhibitor'])) return null;

        if (data['image'] != null && data['image'].isNotEmpty) {
          try {
            final ref = FirebaseStorage.instance.ref(data['image']);
            final imageUrl = await ref.getDownloadURL();
            data['image'] = imageUrl;
          } catch (_) {
            data['image'] = null;
          }
        }

        return {
          'id': doc.id,
          'image': data['image'],
          'name': data['name'],
          'price': data['price'],
          'quantity': data['quantity'],
          'description': data['description'],
          'exhibitor': data['exhibitor'],
          'contact': data['contact'],
          'category': data['category'],
          'exhibitorId': data['exhibitorId'],
        };
      }).toList();

      final results = await Future.wait(futures);
      final validProducts = results.whereType<Map<String, dynamic>>().toList();

      setState(() {
        allProducts = validProducts;
        displayedProducts = validProducts;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching products: $e');
      setState(() => isLoading = false);
    }
  }

  void _searchProducts(String query) {
    setState(() {
      searchQuery = query;
      displayedProducts = allProducts
          .where((product) =>
              product['name']
                  ?.toString()
                  .toLowerCase()
                  .contains(query.toLowerCase()) ??
              false)
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1FDF3),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        title: const Text('Marketplace'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    onChanged: _searchProducts,
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: displayedProducts.isEmpty
                      ? const Center(child: Text('No products found.'))
                      : GridView.builder(
                          padding: const EdgeInsets.all(10),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.75,
                          ),
                          itemCount: displayedProducts.length,
                          itemBuilder: (context, index) {
                            final product = displayedProducts[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ProductDetailsScreen(product: product),
                                  ),
                                );
                              },
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 3,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: product['image'] != null
                                              ? CachedNetworkImage(
                                                  imageUrl: product['image'],
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                  placeholder: (context, url) =>
                                                      const Center(
                                                          child:
                                                              CircularProgressIndicator()),
                                                  errorWidget: (context, url,
                                                          error) =>
                                                      const Icon(
                                                          Icons.broken_image),
                                                )
                                              : const Icon(
                                                  Icons.image_not_supported,
                                                  size: 60),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        product['name'] ?? 'No Name',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.center,
                                      ),
                                      Text(
                                        'Price: \$${(product['price'] ?? 0).toStringAsFixed(2)}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      Text(
                                        'Qty: ${product['quantity'] ?? 0}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
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

class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({super.key, required this.product});
  final Map<String, dynamic> product;

  @override
  Widget build(BuildContext context) {
    final green = const Color(0xFF2E7D32); // Main green
    final lightGreen = const Color(0xFFE8F5E9); // Background highlight

    return Scaffold(
      appBar: AppBar(
        title: Text(product['name'] ?? 'Product Details'),
        backgroundColor: green,
        elevation: 0,
      ),
      backgroundColor: lightGreen,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Product Image
            product['image'] != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      product['image'],
                      height: 220,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image, size: 100),
                    ),
                  )
                : Container(
                    height: 220,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.grey[300],
                    ),
                    child: const Icon(Icons.image_not_supported,
                        size: 100, color: Colors.grey),
                  ),
            const SizedBox(height: 16),

            // Product Info Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: Colors.white,
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['name'] ?? 'No Name',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: green,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.attach_money, color: Colors.green),
                        Text(
                          '\$${(product['price'] ?? 0).toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.inventory_2_outlined,
                            color: Colors.green),
                        const SizedBox(width: 4),
                        Text(
                          'Quantity: ${product['quantity'] ?? 'N/A'}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Description Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: Colors.white,
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Description:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product['description'] ?? 'No description provided.',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Exhibitor Info Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: Colors.white,
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Exhibitor:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        final exhibitorId = product['exhibitorId'];
                        if (exhibitorId != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ExhibitorDetailsScreen(
                                exhibitorId: exhibitorId,
                              ),
                            ),
                          );
                        }
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.account_circle, color: Colors.green),
                          const SizedBox(width: 8),
                          Text(
                            product['exhibitor'] ?? 'Unknown',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_forward_ios,
                              size: 16, color: Colors.black54),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
