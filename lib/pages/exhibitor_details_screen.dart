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
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchExhibitorDetails();
  }

  Future<void> fetchExhibitorDetails() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.exhibitorId)
          .get();
      setState(() {
        exhibitor = doc.data() as Map<String, dynamic>?;
        isLoading = false;
      });
    } catch (e) {
      // Handle error
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(exhibitor?['name'] ?? 'Exhibitor Details'),
      ),
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/exhibitorsbc.jpg', // Path to your background image
              fit: BoxFit.cover,
            ),
          ),
          // Semi-transparent overlay
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5), // Adjust opacity as needed
            ),
          ),
          // Page content
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : exhibitor == null
                  ? const Center(child: Text('No details available', style: TextStyle(color: Colors.white)))
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ListView(
                        children: [
                          exhibitor!['logo'] != null &&
                                  exhibitor!['logo'].isNotEmpty
                              ? Image.network(exhibitor!['logo'])
                              : const Text('No Logo', style: TextStyle(color: Colors.white)),
                          const SizedBox(height: 16),
                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    exhibitor!['name'] ?? 'No Name',
                                    style: const TextStyle(
                                        fontSize: 24, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      const Icon(Icons.email,
                                          color: Colors.lightGreen),
                                      const SizedBox(width: 8),
                                      Text(
                                        exhibitor!['email'] ?? 'No Email',
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      const Icon(Icons.contact_page,
                                          color: Colors.lightGreen),
                                      const SizedBox(width: 8),
                                      Text(
                                        exhibitor!['contact'] ?? 'No Contact',
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      const Icon(Icons.description,
                                          color: Colors.lightGreen),
                                      const SizedBox(width: 8),
                                      Text(
                                        exhibitor!['description'] ??
                                            'No Description',
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on,
                                          color: Colors.lightGreen),
                                      const SizedBox(width: 8),
                                      Text(
                                        exhibitor!['location'] ?? 'No Location',
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
        ],
      ),
    );
  }
}