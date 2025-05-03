import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ExhibitorsScreen extends StatefulWidget {
  const ExhibitorsScreen({super.key});
  static String id = 'exhibitors_screen';

  @override
  _ExhibitorsScreenState createState() => _ExhibitorsScreenState();
}

class _ExhibitorsScreenState extends State<ExhibitorsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exhibitors'),
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
              color: Colors.black.withOpacity(0.3), // Adjust opacity as needed
            ),
          ),
          // Page content
          Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search for exhibitors...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                ),
              ),
              // Exhibitors list
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('exhibitors')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text(
                          'No exhibitors found.',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }

                    final exhibitors = snapshot.data!.docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final name = data['name']?.toUpperCase() ?? 'madhilo';
                      return name.contains(_searchQuery);
                    }).toList();

                    return ListView.builder(
                      itemCount: exhibitors.length,
                      itemBuilder: (context, index) {
                        final exhibitor =
                            exhibitors[index].data() as Map<String, dynamic>;
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
                                    exhibitor['logo'] != null
                                        ? Image.network(
                                            exhibitor['logo'],
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
                                            exhibitor['name'] ?? 'No Name',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            exhibitor['description'] ??
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
                                  'Contact: ${exhibitor['contact'] ?? 'N/A'}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Category: ${exhibitor['category'] ?? 'N/A'}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Location: ${exhibitor['location'] ?? 'N/A'}',
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
                                            builder: (context) =>
                                                DiscussionForum(
                                              exhibitorName:
                                                  exhibitor['name'] ?? 'N/A',
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
                                            builder: (context) =>
                                                DirectChatScreen(
                                              contact: exhibitor['contact'] ??
                                                  'N/A',
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
  final String exhibitorName;

  const DiscussionForum({super.key, required this.exhibitorName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Discussion Forum: $exhibitorName'),
      ),
      body: const Center(
        child: Text('Discussion forum content goes here.'),
      ),
    );
  }
}

class DirectChatScreen extends StatelessWidget {
  final String contact;

  const DirectChatScreen({super.key, required this.contact});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Direct Chat'),
      ),
      body: Center(
        child: Text('Chat with $contact'),
      ),
    );
  }
}