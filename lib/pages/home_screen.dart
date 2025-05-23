import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mis/pages/exhibitors_screen.dart';
import 'package:mis/pages/login_screen.dart';
import 'package:mis/pages/marketplace_screen.dart';
import 'package:mis/services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  final String email;

  const HomeScreen({super.key, required this.email});
  static String id = 'home_screen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      const HomeScreenContent(),
      MarketplaceScreen(),
      const ExhibitorsScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 100,
            ),
            TextButton.icon(
              onPressed: () async {
                await AuthService().signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              icon:
                  const Icon(Icons.logout, color: Color.fromARGB(255, 1, 0, 0)),
              label: const Text(
                'Logout',
                style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
              ),
            ),
          ],
        ),
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Marketplace',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Exhibitors',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        showUnselectedLabels: true,
      ),
    );
  }
}

class HomeScreenContent extends StatefulWidget {
  const HomeScreenContent({super.key});

  @override
  _HomeScreenContentState createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> {
  final PageController _pageController = PageController();
  Timer? _timer;
  final Color primaryGreen = const Color(0xFF2E7D32);

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF1FDF3),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Welcome Card
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 3,
            color: primaryGreen,
            child: const Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'Welcome to Mumunda!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Explore the best of Mashonaland West’s agriculture innovation.',
                    style: TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Search Bar
          TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase().trim();
              });
            },
            decoration: InputDecoration(
              hintText: 'Search events by name, location, or description...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          const Text(
            '📅 Upcoming Events',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          // Events List
          FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance
                .collection('events')
                .orderBy('date')
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No events available.'));
              }

              final now = DateTime.now();

              final events = snapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final name = data['name']?.toString().toLowerCase() ?? '';
                final location =
                    data['location']?.toString().toLowerCase() ?? '';
                final description =
                    data['description']?.toString().toLowerCase() ?? '';

                // Search filter
                final matchesSearch = name.contains(_searchQuery) ||
                    location.contains(_searchQuery) ||
                    description.contains(_searchQuery);

                // Date filter (upcoming only)
                final dateField = data['date'];
                DateTime? eventDate;

                if (dateField is Timestamp) {
                  eventDate = dateField.toDate();
                } else if (dateField is String) {
                  try {
                    eventDate = DateTime.parse(dateField);
                  } catch (_) {
                    eventDate = null;
                  }
                }

                return matchesSearch &&
                    (eventDate == null || eventDate.isAfter(now));
              }).toList();

              if (events.isEmpty) {
                return const Center(
                    child: Text('No matching upcoming events found.'));
              }

              return Column(
                children: events.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = data['name'] ?? 'Unnamed Event';
                  final location = data['location'] ?? 'Unknown Location';
                  final description = data['description'] ?? 'No description';
                  String dateStr = 'No Date';
                  final dateField = data['date'];
                  if (dateField is Timestamp) {
                    dateStr = dateField.toDate().toString().split(' ')[0];
                  } else if (dateField is String) {
                    dateStr = dateField;
                  }

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            description,
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '📍 $location',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          Text(
                            '🗓️ $dateStr',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
