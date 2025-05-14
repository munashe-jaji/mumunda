import 'package:flutter/material.dart';
import 'package:mis/pages/login_screen.dart';
import 'package:mis/services/auth_service.dart';
import 'dart:async';
import 'package:mis/pages/exhibitors_screen.dart';
import 'package:mis/pages/map_screen.dart';
import 'package:mis/pages/marketplace_screen.dart';

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
      const MapScreen(),
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
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await AuthService().signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
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
            icon: Icon(Icons.map),
            label: 'Map',
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

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      int nextPage = (_pageController.page?.round() ?? 0) + 1;
      if (nextPage > 2) nextPage = 0;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF1FDF3),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Carousel
          SizedBox(
            height: 160,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: PageView(
                controller: _pageController,
                children: const [
                  BannerCard(text: '🎤 Guest Speaker: Sir Manango'),
                  BannerCard(text: '🛠 Workshop: Trade Show Insights'),
                  BannerCard(text: '🤖 AI in Farming Exhibition'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Search Bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Search products, exhibitors, or workshops...',
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

          // Welcome card
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 3,
            color: primaryGreen,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: const [
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

          // Featured Products
          const Text(
            '🌟 Featured Products',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildHorizontalList([
            'Maize Seeds',
            'Organic Tomatoes',
            'Irrigation Pipe',
          ]),

          const SizedBox(height: 20),

          // Popular Products
          const Text(
            '🔥 Popular Products',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildHorizontalList([
            'Fresh Carrots',
            'Cattle Feed',
            'Solar Water Pump',
          ]),

          const SizedBox(height: 20),

          // Popular Exhibitors
          const Text(
            '👨‍🌾 Popular Exhibitors',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildHorizontalList([
            'GreenGrow Ltd',
            'FarmTech Zim',
            'EcoHarvest Co',
          ]),
        ],
      ),
    );
  }

  Widget _buildHorizontalList(List<String> items) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          return Container(
            width: 160,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: Center(
              child: Text(
                items[index],
                style: const TextStyle(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
      ),
    );
  }
}

class BannerCard extends StatelessWidget {
  final String text;

  const BannerCard({required this.text, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF66BB6A),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
