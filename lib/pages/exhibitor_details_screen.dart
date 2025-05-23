import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ExhibitorDetailsScreen extends StatefulWidget {
  final String exhibitorId;

  const ExhibitorDetailsScreen({super.key, required this.exhibitorId});

  @override
  _ExhibitorDetailsScreenState createState() => _ExhibitorDetailsScreenState();
}

class _ExhibitorDetailsScreenState extends State<ExhibitorDetailsScreen> {
  Map<String, dynamic>? exhibitor;
  List<Map<String, dynamic>> exhibitorProducts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchExhibitorDetails();
  }

  Future<void> fetchExhibitorDetails() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.exhibitorId)
          .get();

      final exhibitorData = doc.data();

      if (exhibitorData != null) {
        final email = exhibitorData['email'];

        final productsSnapshot = await FirebaseFirestore.instance
            .collection('products')
            .where('email', isEqualTo: email)
            .get();

        final products = productsSnapshot.docs
            .map((doc) => doc.data())
            .cast<Map<String, dynamic>>()
            .toList();

        setState(() {
          exhibitor = exhibitorData;
          exhibitorProducts = products;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint('Error fetching exhibitor or products: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final exhibitorName = exhibitor?['name'] ?? 'Exhibitor Details';
    return Scaffold(
      appBar: AppBar(
        title: Text(exhibitorName),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/exhibitorsbc.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          ),
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : exhibitor == null
                  ? const Center(
                      child: Text(
                        'No details available',
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.all(16.0),
                      children: [
                        if (exhibitor!['logo'] != null &&
                            (exhibitor!['logo'] as String).isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Image.network(
                              exhibitor!['logo'],
                              height: 150,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.broken_image, size: 100),
                            ),
                          ),
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  exhibitor!['name'] ?? 'No Name',
                                  style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 16),
                                buildDetailRow(Icons.email,
                                    exhibitor!['email'] ?? 'No Email'),
                                buildDetailRow(Icons.contact_phone,
                                    exhibitor!['contact'] ?? 'No Contact'),
                                buildDetailRow(
                                    Icons.description,
                                    exhibitor!['description'] ??
                                        'No Description'),
                                buildDetailRow(Icons.location_on,
                                    exhibitor!['location'] ?? 'No Location'),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Products by this Exhibitor',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        const SizedBox(height: 12),
                        ...exhibitorProducts.map((product) => Card(
                              color: Colors.white.withOpacity(0.95),
                              elevation: 3,
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              child: ListTile(
                                leading: product['image'] != null &&
                                        (product['image'] as String)
                                            .trim()
                                            .isNotEmpty
                                    ? Image.network(
                                        product['image'],
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(Icons.broken_image),
                                      )
                                    : const Icon(Icons.image_not_supported),
                                title: Text(product['name'] ?? 'Unnamed'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        'Price: \$${(product['price'] ?? '').toString()}'),
                                    Text(
                                        'Qty: ${(product['quantity'] ?? '').toString()}'),
                                  ],
                                ),
                              ),
                            )),
                      ],
                    ),
        ],
      ),
    );
  }

  Widget buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.lightGreen),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 18),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
